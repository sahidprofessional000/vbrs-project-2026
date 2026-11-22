import {
  WebSocketGateway,
  WebSocketServer,
  SubscribeMessage,
  OnGatewayConnection,
  OnGatewayDisconnect,
  ConnectedSocket,
  MessageBody,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { Logger } from '@nestjs/common';

@WebSocketGateway({
  cors: {
    origin: '*',
    credentials: true,
  },
})
export class EventsGateway implements OnGatewayConnection, OnGatewayDisconnect {
  @WebSocketServer()
  server: Server;

  private readonly logger = new Logger('EventsGateway');

  handleConnection(client: Socket) {
    this.logger.log(`Client connected to real-time events: ${client.id}`);
  }

  handleDisconnect(client: Socket) {
    this.logger.log(`Client disconnected: ${client.id}`);
  }

  @SubscribeMessage('join:mechanics')
  handleJoinMechanics(@ConnectedSocket() client: Socket) {
    client.join('mechanics:active');
    this.logger.log(`Client ${client.id} joined 'mechanics:active' room`);
    return { status: 'joined', room: 'mechanics:active' };
  }

  @SubscribeMessage('leave:mechanics')
  handleLeaveMechanics(@ConnectedSocket() client: Socket) {
    client.leave('mechanics:active');
    this.logger.log(`Client ${client.id} left 'mechanics:active' room`);
    return { status: 'left', room: 'mechanics:active' };
  }

  @SubscribeMessage('join:request')
  handleJoinRequest(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: { requestId: string },
  ) {
    if (data?.requestId) {
      const room = `request:${data.requestId}`;
      client.join(room);
      this.logger.log(`Client ${client.id} joined room '${room}'`);
      return { status: 'joined', room };
    }
  }

  @SubscribeMessage('leave:request')
  handleLeaveRequest(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: { requestId: string },
  ) {
    if (data?.requestId) {
      const room = `request:${data.requestId}`;
      client.leave(room);
      this.logger.log(`Client ${client.id} left room '${room}'`);
      return { status: 'left', room };
    }
  }

  /**
   * Broadcast status progression event to the isolated request room and active mechanics
   */
  broadcastStatusUpdate(serviceRequestId: string, payload: any) {
    if (this.server) {
      const room = `request:${serviceRequestId}`;
      this.server.to(room).emit('request:status_update', payload);
      // Also emit request:status for backward compatibility
      this.server.to(room).emit('request:status', payload);
      this.logger.log(`Broadcasted request:status_update to room '${room}': ${payload.status}`);
    }
  }

  /**
   * Broadcast real-time en-route mechanic telemetry to the specific request room
   */
  broadcastTrackingLocation(serviceRequestId: string, payload: any) {
    if (this.server) {
      const room = `request:${serviceRequestId}`;
      this.server.to(room).emit('mechanic:location_update', payload);
      this.logger.log(`Broadcasted mechanic:location_update to room '${room}'`);
    }
  }

  /**
   * Broadcast diagnostic quote, labor, and parts breakdown to the isolated request room
   */
  broadcastQuoteUpdate(serviceRequestId: string, payload: any) {
    if (this.server) {
      const room = `request:${serviceRequestId}`;
      this.server.to(room).emit('service:quote_update', payload);
      this.logger.log(`Broadcasted service:quote_update to room '${room}'`);
    }
  }

  /**
   * Broadcast proximity arrival alert when technician is on-scene (within 50 meters)
   */
  broadcastArrivalAlert(serviceRequestId: string, payload: any) {
    if (this.server) {
      const room = `request:${serviceRequestId}`;
      this.server.to(room).emit('service:arrival_alert', payload);
      this.logger.log(`Broadcasted service:arrival_alert to room '${room}'`);
    }
  }

  /**
   * Broadcast newly filed breakdown incident to all active online mechanics
   */
  broadcastNewDispatch(payload: any) {
    if (this.server) {
      this.server.to('mechanics:active').emit('dispatch:new', payload);
      this.logger.log(`Broadcasted dispatch:new for incident ${payload.id || payload.reportId}`);
    }
  }

  /**
   * Broadcast job acceptance to all technicians so they remove it from their queues,
   * and to the specific customer request room
   */
  broadcastDispatchAccepted(payload: {
    serviceRequestId: string;
    mechanicId: string;
    mechanicName?: string;
  }) {
    if (this.server) {
      // Notify active mechanics queue to clear claimed dispatch
      this.server.to('mechanics:active').emit('dispatch:accepted', payload);
      // Notify customer viewing the specific request
      this.server.to(`request:${payload.serviceRequestId}`).emit('request:status', {
        status: 'ACCEPTED',
        ...payload,
      });
      this.logger.log(`Broadcasted dispatch:accepted for request ${payload.serviceRequestId}`);
    }
  }

  /**
   * Broadcast status change of a mechanic (e.g. AVAILABLE vs OFFLINE)
   */
  broadcastMechanicStatus(payload: { mechanicId: string; status: string }) {
    if (this.server) {
      this.server.emit('mechanic:status', payload);
    }
  }

  /**
   * Broadcast location ping of an on-job or available mechanic
   */
  broadcastMechanicLocation(payload: {
    mechanicId: string;
    latitude: number;
    longitude: number;
    heading?: number;
    speed?: number;
  }) {
    if (this.server) {
      this.server.emit('mechanic:location', payload);
    }
  }
}
