require('dotenv').config();
const express = require('express');
const nodemailer = require('nodemailer');
const crypto = require('crypto');
const { createClient } = require('@supabase/supabase-js');
const bcrypt = require('bcryptjs');
const cors = require('cors');
const jwt = require('jsonwebtoken');
const rateLimit = require('express-rate-limit');
const morgan = require('morgan');
const helmet = require('helmet');

const app = express();

// --- CONFIGURATION ---
const JWT_SECRET = process.env.JWT_SECRET || 'ALAM_ULTIMATE_SECURE_2026';

// --- MIDDLEWARE ---
app.use(helmet());
app.use(express.json());
app.use(cors());
if (process.env.NODE_ENV !== 'production') app.use(morgan('dev'));

// --- SUPABASE INIT ---
const supabase = createClient(
    process.env.SUPABASE_URL, 
    process.env.SUPABASE_KEY
);

// --- MAIL INIT ---
const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: { 
        user: process.env.GMAIL_USER, 
        pass: process.env.GMAIL_PASS 
    }
});

// Helper: Token Generator
const generateToken = (user) => jwt.sign({ id: user.id, email: user.email }, JWT_SECRET, { expiresIn: '90d' });

// --- ROUTES ---

// Health Check
app.get('/api/health', (req, res) => res.status(200).json({ status: 'Live', platform: 'Vercel' }));

// SEND OTP (Note: Vercel par Map() temporary hota hai, magar filhal kaam karega)
app.post('/api/auth/send-otp', async (req, res) => {
    const { email } = req.body;
    if (!email) return res.status(400).json({ error: "Email zaroori hai" });

    const otp = crypto.randomInt(100000, 999999).toString();
    
    // Supabase mein OTP save karna zyada professional hai (Vercel memory reset kar deta hai)
    // Magar fast fix ke liye hum email mein OTP bhej rahe hain
    try {
        await transporter.sendMail({
            from: `"ALAM STORE" <${process.env.GMAIL_USER}>`,
            to: email,
            subject: 'Verification Code - ALAM STORE',
            html: `<div style="font-family: sans-serif; text-align: center;">
                    <h2>ALAM ENTERPRISES</h2>
                    <p>Aapka code hai:</p>
                    <h1 style="color:#004AAD;">${otp}</h1>
                   </div>`
        });

        // Note: Production mein OTP ko Database mein save karein, server memory (Map) mein nahi
        res.json({ success: true, message: "OTP Bhej diya gaya", debug_otp: otp }); 
    } catch (e) {
        res.status(500).json({ error: "Mail system fail ho gaya" });
    }
});

// LOGIN
app.post('/api/auth/login', async (req, res) => {
    const { email, password } = req.body;
    try {
        const { data: user, error } = await supabase.from('users').select('*').eq('email', email).single();
        if (error || !user) return res.status(404).json({ error: "Account nahi mila" });

        const isMatch = await bcrypt.compare(password, user.password);
        if (!isMatch) return res.status(401).json({ error: "Ghalat password" });

        res.json({ success: true, token: generateToken(user), user });
    } catch (e) {
        res.status(500).json({ error: "Server error" });
    }
});

// --- VERCEL SPECIFIC EXPORT ---
// Vercel ko app.listen ki zaroorat nahi hoti, wo export mangta hai
module.exports = app;

// Local testing ke liye (Vercel par ye skip ho jayega)
if (process.env.NODE_ENV !== 'production') {
    const PORT = process.env.PORT || 3000;
    app.listen(PORT, () => console.log(`Local Server: http://localhost:${PORT}`));
}