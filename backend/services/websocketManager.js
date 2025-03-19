const { verifyToken } = require('../middleware/authMiddleware');
const { v4: uuidv4 } = require('uuid');

class WebSocketManager {
  constructor(io) {
    this.io = io;
    this.userGroups = new Map(); // userId -> Set of group names
    console.log('WebSocketManager initialized');
    console.log('Setting up Socket.IO namespaces...');
    this.setupNamespaces();
  }

  setupNamespaces() {
    // Notifications namespace
    const notificationsNamespace = this.io.of('/notifications');
    notificationsNamespace.use(this.authenticateSocket);
    
    notificationsNamespace.on('connection', (socket) => {
      const userId = socket.user.id.toString();
      console.log(`User ${userId} connected to notifications namespace`);
      
      // Handle subscription
      socket.on('subscribe', (data) => {
        const channels = data.channels || [];
        if (!this.userGroups.has(userId)) {
          this.userGroups.set(userId, new Set());
        }
        
        channels.forEach(channel => {
          this.userGroups.get(userId).add(channel);
        });
        
        socket.emit('subscription_success', { channels });
        console.log(`User ${userId} subscribed to channels: ${channels.join(', ')}`);
      });
      
      // Handle mark_read
      socket.on('mark_read', (data) => {
        const notificationId = data.notification_id;
        // Here you would update the notification status in your database
        socket.emit('mark_read_success', { notification_id: notificationId });
      });
      
      // Handle ping
      socket.on('ping', (data) => {
        socket.emit('pong', { timestamp: new Date().toISOString() });
      });
      
      // Handle disconnect
      socket.on('disconnect', () => {
        console.log(`User ${userId} disconnected from notifications namespace`);
      });
    });
    
    // RFID namespace
    const rfidNamespace = this.io.of('/rfid');
    rfidNamespace.use(this.authenticateSocket);
    
    rfidNamespace.on('connection', (socket) => {
      const userId = socket.user.id.toString();
      console.log(`User ${userId} connected to RFID namespace`);
      
      // Handle ping
      socket.on('ping', (data) => {
        socket.emit('pong', { timestamp: new Date().toISOString() });
      });
      
      // Handle disconnect
      socket.on('disconnect', () => {
        console.log(`User ${userId} disconnected from RFID namespace`);
      });
    });
  }

  // Socket.IO middleware to authenticate connections
  authenticateSocket(socket, next) {
    try {
      const token = socket.handshake.auth.token;
      const user = verifyToken(token);
      
      if (!user) {
        return next(new Error('Authentication error'));
      }
      
      // Store user data in socket for later use
      socket.user = user;
      next();
    } catch (err) {
      next(new Error('Authentication error'));
    }
  }

  // Send notification to a specific user
  createNotification(userId, title, message, type = 'info', metadata = {}, actionUrl = null) {
    userId = userId.toString();
    const notification = {
      id: uuidv4(),
      title,
      message,
      type,
      timestamp: new Date().toISOString(),
      metadata: metadata || {},
      read: false,
      action_url: actionUrl
    };
    
    const namespace = this.io.of('/notifications');
    const sockets = namespace.sockets;
    
    let delivered = false;
    
    // Find sockets for this user
    for (const [id, socket] of sockets) {
      if (socket.user && socket.user.id.toString() === userId) {
        socket.emit('notification', notification);
        delivered = true;
        console.log(`Notification sent to user ${userId}`);
      }
    }
    
    return delivered;
  }

  // Send RFID event to a specific user
  createRfidEvent(userId, stationId, stationName, eventType, additionalData = {}) {
    userId = userId.toString();
    const event = {
      user_id: userId,
      station_id: stationId,
      station_name: stationName,
      timestamp: new Date().toISOString(),
      event_type: eventType,
      additional_data: additionalData || {}
    };
    
    const namespace = this.io.of('/rfid');
    const sockets = namespace.sockets;
    
    let delivered = false;
    
    // Find sockets for this user
    for (const [id, socket] of sockets) {
      if (socket.user && socket.user.id.toString() === userId) {
        socket.emit('rfid_event', event);
        delivered = true;
        console.log(`RFID event sent to user ${userId}`);
      }
    }
    
    return delivered;
  }

  // Broadcast to all users in a group
  broadcastToGroup(group, message) {
    let recipients = 0;
    
    for (const [userId, groups] of this.userGroups.entries()) {
      if (groups.has(group)) {
        this.io.of('/notifications').to(userId).emit(message.type, message.data);
        recipients++;
      }
    }
    
    return recipients;
  }
}

module.exports = WebSocketManager;