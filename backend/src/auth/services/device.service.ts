import { Injectable, BadRequestException, InternalServerErrorException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { Device } from '../schemas/device.schema';
import { LoggerServiceImpl } from '../../common/logger/logger.service';

export interface DeviceInfo {
  name: string;
  ipAddress?: string;
  userAgent?: string;
  deviceId?: string;
  osType: string;
  osVersion?: string;
}

export interface ActiveDevice {
  id: string;
  name: string;
  osType: string;
  osVersion?: string;
  ipAddress?: string;
  isCurrent: boolean;
  lastSeenAt: Date;
  createdAt: Date;
}

@Injectable()
export class DeviceService {
  constructor(
    @InjectModel(Device.name) private deviceModel: Model<Device>,
    private logger: LoggerServiceImpl,
  ) {}

  /**
   * Register or update device on login
   */
  async registerDevice(userId: string, deviceInfo: DeviceInfo, makeCurrentDevice = true): Promise<string> {
    try {
      // Check if device already exists
      const existingDevice = deviceInfo.deviceId
        ? await this.deviceModel.findOne({
            userId: new Types.ObjectId(userId),
            deviceId: deviceInfo.deviceId,
            isActive: true,
          })
        : null;

      let device;

      if (existingDevice) {
        // Update existing device
        existingDevice.lastSeenAt = new Date();
        existingDevice.lastActivityAt = new Date();
        existingDevice.ipAddress = deviceInfo.ipAddress || existingDevice.ipAddress;
        existingDevice.userAgent = deviceInfo.userAgent || existingDevice.userAgent;

        if (makeCurrentDevice) {
          // Mark all other devices as not current
          await this.deviceModel.updateMany(
            { userId: new Types.ObjectId(userId), _id: { $ne: existingDevice._id } },
            { isCurrent: false },
          );
          existingDevice.isCurrent = true;
        }

        device = await existingDevice.save();
        this.logger.log(
          `[DeviceService] Device updated for user ${userId} - ${device.name}`,
          'registerDevice',
        );
      } else {
        // Create new device
        if (makeCurrentDevice) {
          // Mark all other devices as not current
          await this.deviceModel.updateMany(
            { userId: new Types.ObjectId(userId) },
            { isCurrent: false },
          );
        }

        device = await this.deviceModel.create({
          userId: new Types.ObjectId(userId),
          ...deviceInfo,
          isCurrent: makeCurrentDevice,
          lastSeenAt: new Date(),
          lastActivityAt: new Date(),
          isActive: true,
        });

        this.logger.log(
          `[DeviceService] New device registered for user ${userId} - ${device.name}`,
          'registerDevice',
        );
      }

      return device._id.toString();
    } catch (error) {
      this.logger.error(
        `[DeviceService] Error registering device: ${error.message}`,
        'registerDevice',
      );
      throw new InternalServerErrorException('Failed to register device');
    }
  }

  /**
   * Get all active devices for a user
   */
  async getActiveDevices(userId: string): Promise<ActiveDevice[]> {
    try {
      const devices = await this.deviceModel
        .find({
          userId: new Types.ObjectId(userId),
          isActive: true,
          revokedAt: null,
        })
        .sort({ createdAt: -1 })
        .exec();

      return devices.map((device) => ({
        id: device._id.toString(),
        name: device.name,
        osType: device.osType,
        osVersion: device.osVersion,
        ipAddress: device.ipAddress,
        isCurrent: device.isCurrent,
        lastSeenAt: device.lastSeenAt,
        createdAt: device.createdAt,
      }));
    } catch (error) {
      this.logger.error(
        `[DeviceService] Error getting active devices: ${error.message}`,
        'getActiveDevices',
      );
      throw new InternalServerErrorException('Failed to fetch devices');
    }
  }

  /**
   * Logout from specific device
   */
  async logoutFromDevice(userId: string, deviceId: string): Promise<{ message: string }> {
    try {
      const device = await this.deviceModel.findOne({
        _id: new Types.ObjectId(deviceId),
        userId: new Types.ObjectId(userId),
      });

      if (!device) {
        throw new BadRequestException('Device not found');
      }

      device.isActive = false;
      device.revokedAt = new Date();
      await device.save();

      this.logger.log(
        `[DeviceService] User ${userId} logged out from device ${device.name}`,
        'logoutFromDevice',
      );

      return { message: `Logged out from ${device.name}` };
    } catch (error) {
      if (error instanceof BadRequestException) throw error;

      this.logger.error(
        `[DeviceService] Error logging out from device: ${error.message}`,
        'logoutFromDevice',
      );
      throw new InternalServerErrorException('Failed to logout from device');
    }
  }

  /**
   * Logout from all devices
   */
  async logoutFromAllDevices(userId: string): Promise<{ message: string; devicesLoggedOut: number }> {
    try {
      const result = await this.deviceModel.updateMany(
        {
          userId: new Types.ObjectId(userId),
          isActive: true,
        },
        {
          isActive: false,
          revokedAt: new Date(),
        },
      );

      this.logger.log(
        `[DeviceService] User ${userId} logged out from all ${result.modifiedCount} devices`,
        'logoutFromAllDevices',
      );

      return {
        message: 'Logged out from all devices',
        devicesLoggedOut: result.modifiedCount,
      };
    } catch (error) {
      this.logger.error(
        `[DeviceService] Error logging out from all devices: ${error.message}`,
        'logoutFromAllDevices',
      );
      throw new InternalServerErrorException('Failed to logout from all devices');
    }
  }

  /**
   * Update device last activity
   */
  async updateDeviceActivity(userId: string, deviceId: string): Promise<void> {
    try {
      await this.deviceModel.updateOne(
        {
          _id: new Types.ObjectId(deviceId),
          userId: new Types.ObjectId(userId),
        },
        {
          lastActivityAt: new Date(),
          lastSeenAt: new Date(),
        },
      );
    } catch (error) {
      // Silent fail - activity tracking is non-critical
      this.logger.debug(
        `[DeviceService] Error updating device activity: ${error.message}`,
        'updateDeviceActivity',
      );
    }
  }

  /**
   * Get current device for user
   */
  async getCurrentDevice(userId: string): Promise<Device | null> {
    try {
      return await this.deviceModel.findOne({
        userId: new Types.ObjectId(userId),
        isCurrent: true,
        isActive: true,
      });
    } catch (error) {
      this.logger.debug(
        `[DeviceService] Error getting current device: ${error.message}`,
        'getCurrentDevice',
      );
      return null;
    }
  }

  /**
   * Cleanup old inactive devices
   */
  async cleanupInactiveDevices(daysOld = 30): Promise<{ deleted: number }> {
    try {
      const cutoffDate = new Date(Date.now() - daysOld * 24 * 60 * 60 * 1000);

      const result = await this.deviceModel.deleteMany({
        isActive: false,
        revokedAt: { $lt: cutoffDate },
      });

      this.logger.log(
        `[DeviceService] Cleaned up ${result.deletedCount} inactive devices`,
        'cleanupInactiveDevices',
      );

      return { deleted: result.deletedCount };
    } catch (error) {
      this.logger.error(
        `[DeviceService] Error cleaning up inactive devices: ${error.message}`,
        'cleanupInactiveDevices',
      );
      throw new InternalServerErrorException('Failed to cleanup devices');
    }
  }
}
