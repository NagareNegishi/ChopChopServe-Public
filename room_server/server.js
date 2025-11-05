// Deployed on: chopchopserve-production.up.railway.app
// expects JSON bodies for POST requests

const express = require('express')
const rooms = new Map() // room_code -> ip + expiry time
const app = express()
// https://expressjs.com/en/guide/using-middleware.html
app.use(express.json()) // Run this function on every request before my route handlers
const port = 3000

// Simple test endpoint
app.get('/test', (req, res) => {
    res.json({ message: 'Server is working!' });
});

// Register a room code with an IP address
app.post('/register', (req, res) => {
    const { room_code, ip } = req.body;
    
    if (!room_code || !ip) {
        return res.status(400).json({ error: 'Missing room_code or ip' });
    }
    rooms.set(room_code.toUpperCase(), {
        ip: ip,
        expires: Date.now() + (60 * 60 * 1000) // 1 hour from now
    });
    console.log(`Registered: ${room_code} → ${ip}`);
    res.json({ success: true });
});

// Lookup an IP address by room code
app.get('/lookup/:code', (req, res) => {
    const code = req.params.code.toUpperCase();
    const entry = rooms.get(code);
    
    if (!entry) {
        return res.status(404).json({ error: 'Room code not found' });
    }
    if (Date.now() > entry.expires) {
        rooms.delete(code);
        return res.status(410).json({ error: 'Room code expired' });
    }
    res.json({ ip: entry.ip });
});

// Get all active room codes
app.get('/rooms', (req, res) => {
    const now = Date.now();
    const activeRooms = [];
    
    // Clean up expired rooms while building the list
    for (const [code, entry] of rooms) {
        if (now > entry.expires) {
            rooms.delete(code);
            console.log(`Expired: ${code}`);
        } else {
            activeRooms.push({
                room_code: code,
                ip: entry.ip,
                expires_in: Math.floor((entry.expires - now) / 1000) // seconds remaining
            });
        }
    }
    
    res.json({ rooms: activeRooms, count: activeRooms.length });
});

// Periodically clean up expired room codes
// https://developer.mozilla.org/en-US/docs/Web/API/Window/setInterval
setInterval(() => {
    const now = Date.now();
    for (const [code, entry] of rooms) {
        if (now > entry.expires) {
            rooms.delete(code);
            console.log(`Expired: ${code}`);
        }
    }
}, 180 * 60 * 1000); // Every 3 hours

// Start the server
app.listen(port, () => {
    console.log(`Server running on port ${port}`)
});


function test(){
    console.log("test")
}