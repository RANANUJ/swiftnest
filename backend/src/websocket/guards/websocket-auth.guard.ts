import { Injectable } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { Socket } from 'socket.io';

@Injectable()
export class WebSocketAuthGuard {
  constructor(private jwtService: JwtService) {}

  async validateConnection(client: Socket): Promise<any> {
    try {
      const token = client.handshake.auth.authorization?.split(' ')[1] || 
                    client.handshake.auth.authorization ||
                    client.handshake.headers.authorization?.split(' ')[1];
      
      if (!token) {
        throw new Error('No token provided');
      }

      const user = await this.jwtService.verifyAsync(token);
      return user;
    } catch (error) {
      throw new Error(`Unauthorized: ${error.message}`);
    }
  }
}
