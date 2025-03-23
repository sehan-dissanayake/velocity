const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const http = require('http');
const { Server } = require('socket.io');
const authRoutes = require('./routes/authRoutes');
const railwayRoutes = require('./routes/railwayRoutes');
const walletRoutes = require('./routes/walletRoutes')
const profileRoutes = require('./routes/profileRoutes');
const WebSocketManager = require('./services/websocketManager');

require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Create HTTP server
const server = http.createServer(app);

// Create Socket.IO server with CORS settings
const io = new Server(server, {
  cors: {
    origin: '*', // In production, restrict this to your frontend domain
    methods: ['GET', 'POST']
  }
});

// Initialize WebSocket manager
const websocketManager = new WebSocketManager(io);
// Make websocketManager accessible to routes
app.set('websocketManager', websocketManager);

// Middlewares
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// Routes
app.get('/', (req, res) => {
  res.send('Welcome to the API');
}
);

app.use('/api/auth', authRoutes);
app.use('/api/railway-stations', railwayRoutes);
app.use('/api/wallet', walletRoutes);
app.use('/api/profile', profileRoutes);

// In your API endpoint handlers (server.js)
app.post('/api/notification', (req, res) => {
    console.log(`Notification API endpoint called`);
    console.log(`Request body:`, req.body);
    
    const { user_id, title, message, type } = req.body;
    
    if (!user_id) {
      console.error('Missing user_id parameter');
      return res.status(400).json({ success: false, message: 'Missing user_id parameter' });
    }
    
    console.log(`Creating notification for User ${user_id}`);
    const manager = req.app.get('websocketManager');
    const success = manager.createNotification(
      user_id,
      title,
      message,
      type || 'info'
    );
    
    console.log(`Notification result: ${success ? 'delivered' : 'not delivered'}`);
    res.json({ success, message: success ? 'Notification sent' : 'User not connected' });
  });
  

// Demo route to test RFID event
app.post('/api/rfid', (req, res) => {
  console.log(req.body);
  const { user_id, station_id, station_name, event_type } = req.body;
  
  const manager = req.app.get('websocketManager');
  const success = manager.createRfidEvent(
    user_id,
    station_id,
    station_name,
    event_type || 'entry'
  );
  
  res.json({ success, message: success ? 'RFID event sent' : 'User not connected' });
});

// Start the server
server.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});