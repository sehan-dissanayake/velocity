const { verifyToken } = require("../middleware/authMiddleware");
const { v4: uuidv4 } = require("uuid");
const mqtt = require("mqtt");
const db = require("../config/db");

class WebSocketManager {
  constructor(io) {
    this.io = io;
    this.userGroups = new Map(); // userId -> Set of group names
    console.log("WebSocketManager initialized");
    console.log("Setting up Socket.IO namespaces...");
    this.setupNamespaces();

    // MQTT connection
    this.mqttClient = mqtt.connect("mqtt://test.mosquitto.org");

    this.mqttClient.on("connect", () => {
      console.log("Connected to MQTT broker");
      this.mqttClient.subscribe("rfid-Velociti/scans");
    });

    this.mqttClient.on("message", (topic, message) => {
      if (topic === "rfid-Velociti/scans") {
        this.handleRfidScan(message.toString());
      }
    });
  }

  setupNamespaces() {
    // Notifications namespace
    const notificationsNamespace = this.io.of("/notifications");
    notificationsNamespace.use(this.authenticateSocket);

    notificationsNamespace.on("connection", (socket) => {
      const userId = socket.user.id.toString();
      console.log(`User ${userId} connected to notifications namespace`);

      // Handle subscription
      socket.on("subscribe", (data) => {
        const channels = data.channels || [];
        if (!this.userGroups.has(userId)) {
          this.userGroups.set(userId, new Set());
        }

        channels.forEach((channel) => {
          this.userGroups.get(userId).add(channel);
        });

        socket.emit("subscription_success", { channels });
        console.log(
          `User ${userId} subscribed to channels: ${channels.join(", ")}`
        );
      });

      // Handle mark_read
      socket.on("mark_read", (data) => {
        const notificationId = data.notification_id;
        // Here you would update the notification status in your database
        socket.emit("mark_read_success", { notification_id: notificationId });
      });

      // Handle ping
      socket.on("ping", (data) => {
        socket.emit("pong", { timestamp: new Date().toISOString() });
      });

      // Handle disconnect
      socket.on("disconnect", () => {
        console.log(`User ${userId} disconnected from notifications namespace`);
      });
    });

    // RFID namespace
    const rfidNamespace = this.io.of("/rfid");
    rfidNamespace.use(this.authenticateSocket);

    rfidNamespace.on("connection", (socket) => {
      const userId = socket.user.id.toString();
      console.log(`User ${userId} connected to RFID namespace`);

      // Handle ping
      socket.on("ping", (data) => {
        socket.emit("pong", { timestamp: new Date().toISOString() });
      });

      // Handle disconnect
      socket.on("disconnect", () => {
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
        return next(new Error("Authentication error"));
      }

      // Store user data in socket for later use
      socket.user = user;
      next();
    } catch (err) {
      next(new Error("Authentication error"));
    }
  }

  // Send notification to a specific user
  createNotification(
    userId,
    title,
    message,
    type = "info",
    metadata = {},
    actionUrl = null
  ) {
    userId = userId.toString();
    const notification = {
      id: uuidv4(),
      title,
      message,
      type,
      timestamp: new Date().toISOString(),
      metadata: metadata || {},
      read: false,
      action_url: actionUrl,
    };

    const namespace = this.io.of("/notifications");
    const sockets = namespace.sockets;

    let delivered = false;

    // Find sockets for this user
    for (const [id, socket] of sockets) {
      if (socket.user && socket.user.id.toString() === userId) {
        socket.emit("notification", notification);
        delivered = true;
        console.log(`Notification sent to user ${userId}`);
      }
    }

    return delivered;
  }

  // Send RFID event to a specific user
  createRfidEvent(
    userId,
    stationId,
    stationName,
    eventType,
    additionalData = {}
  ) {
    userId = userId.toString();
    const event = {
      user_id: userId,
      station_id: stationId,
      station_name: stationName,
      timestamp: new Date().toISOString(),
      event_type: eventType,
      additional_data: additionalData || {},
    };

    const namespace = this.io.of("/rfid");
    const sockets = namespace.sockets;

    let delivered = false;

    // Find sockets for this user
    for (const [id, socket] of sockets) {
      if (socket.user && socket.user.id.toString() === userId) {
        socket.emit("rfid_event", event);
        delivered = true;
        console.log(`RFID event sent to user ${userId}`);
      }
    }

    return delivered;
  }

  async handleRfidScan(scanData) {
    try {
      // Parse data and setup
      const { uid, reader_id } = JSON.parse(scanData);
      const currentDateTime = "2025-03-22 19:45:04";
      const currentUser = "ashiduDissanayake";
      const userId = 12;
      
      // Begin transaction directly on the pool
      await db.promise().query('START TRANSACTION');
      
      try {
        // Execute queries in transaction
        const [userRows] = await db.promise().query(
          "SELECT isLogged, balance FROM users WHERE id = ?", 
          [userId]
        );
        
        if (userRows.length === 0) {
          await db.promise().query('ROLLBACK');
          return { success: false, error: "User not found" };
        }
        
        // 2. Process user data
        let { isLogged, balance } = userRows[0];
        balance = parseFloat(balance) || 0; // Ensure balance is a number
        console.log(`User isLogged: ${isLogged}, balance: ${balance}`);
        
        // 3. Determine station and fare
        let message = "";
        let deduct = 0;
        let stationName = "";
        
        if (isLogged) {
          // User is exiting train
          isLogged = false;
          deduct = 150; // Fare charged when exiting
          stationName = "Galle";
          message = `Exited at ${stationName}. Fare: Rs. ${deduct}. Remaining balance: Rs. ${balance - deduct}`;
        } else {
          // User is entering train
          isLogged = true;
          deduct = 0; // No charge for entry
          stationName = "Angulana";
          message = `Boarded Udarata Manike train at ${stationName}`;
        }
        
        // 4. Calculate new balance (ensure it doesn't go negative)
        const newBalance = Math.max(balance - deduct, 0);
        
        // 5. Update user data
        await db.promise().query(
          "UPDATE users SET balance = ?, isLogged = ? WHERE id = ?",
          [newBalance, isLogged, userId]
        );
        
        // 6. Record transaction if fare was deducted
        if (deduct > 0) {
          await db.promise().query(
            "INSERT INTO transactions (user_id, type, amount, balance_after, transaction_date) VALUES (?, ?, ?, ?, NOW())",
            [userId, "transfer_sent", -deduct, newBalance]
          );
        }
        
        // 8. Commit transaction
        await db.promise().commit();
        
        // 9. Send notification
        this.createNotification(
          userId,
          "VeloCiti Travel Update",
          message,
          "travel",
          {
            uid,
            reader_id,
            station: stationName,
            fare: deduct,
            balance: newBalance,
            timestamp: currentDateTime,
            user: currentUser
          }
        );
        
        console.log(`Notification sent: ${message}, New Balance: Rs. ${newBalance}`);
        
        return {
          success: true,
          userId,
          isLogged,
          stationName,
          fare: deduct,
          newBalance,
          timestamp: currentDateTime
        };
        
      } catch (dbError) {
        // Roll back transaction in case of any error
        await db.promise().rollback();
        console.error("Database error in RFID scan:", dbError);
        return { success: false, error: dbError.message };
      } finally {
        // Always release db.promise()
        db.promise().release();
      }
      
    } catch (error) {
      console.error("Error processing RFID scan:", error);
      return { success: false, error: error.message };
    }
  }

  getUserFromReader(readerId) {
    return 12; // Return actual user ID
  }

  // Broadcast to all users in a group
  broadcastToGroup(group, message) {
    let recipients = 0;

    for (const [userId, groups] of this.userGroups.entries()) {
      if (groups.has(group)) {
        this.io
          .of("/notifications")
          .to(userId)
          .emit(message.type, message.data);
        recipients++;
      }
    }

    return recipients;
  }
}

module.exports = WebSocketManager;
