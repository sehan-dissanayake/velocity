const mysql = require('mysql2');
require('dotenv').config();
const fs = require('fs');
const path = require('path');

// Create connection
const connection = mysql.createConnection({
    host: process.env.DB_HOST,       
    user: process.env.DB_USER,      
    password: process.env.DB_PASSWORD, 
    database: process.env.DB_NAME,   
    port: process.env.DB_PORT,      
    ssl: process.env.DB_SSL === 'true' ? {
        // If you have a CA certificate file
        ca: process.env.DB_SSL_CA ? fs.readFileSync(path.resolve(process.env.DB_SSL_CA)) : undefined,
        rejectUnauthorized: true
      } : undefined,
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0,
});

// Connect to MySQL
connection.connect((err) => {
    if (err) {
        console.error('Error connecting to MySQL:', err);
        return;
    }
    console.log('Connected to MySQL database');
});

module.exports = connection;
