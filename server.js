require('dotenv').config();
const express = require('express');
const nodemailer = require('nodemailer');
const crypto = require('crypto');
const { createClient } = require('@supabase/supabase-js');
const bcrypt = require('bcryptjs');
const cors = require('cors');
const jwt = require('jsonwebtoken');
const helmet = require('helmet');

const app = express();

// --- PROFESSIONAL MIDDLEWARE ---
app.use(helmet());
app.use(express.json());
app.use(cors());

// --- STEP 2: SUPABASE & ENV VALIDATION ---
// Agar Dashboard se nahi mil raha, toh yahan apna URL/KEY paste kar sakte hain (Optional)
const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_KEY = process.env.SUPABASE_KEY;

let supabase;

if (!SUPABASE_URL || !SUPABASE_KEY) {
    console.error("❌ CRITICAL ERROR: Supabase Environment Variables are missing!");
} else {
    try {
        supabase = createClient(SUPABASE_URL, SUPABASE_KEY);
        console.log("✅ Supabase Client Initialized");
    } catch (err) {
        console.error("❌ Supabase Init Error:", err.message);
    }
}

// --- MAIL CONFIG ---
const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: { 
        user: process.env.GMAIL_USER, 
        pass: process.env.GMAIL_PASS 
    }
});

// --- ROUTES ---

// 1. HEALTH CHECK (Is se pata chalega ke Vercel ne variables uthaye ya nahi)
app.get('/api/health', (req, res) => {
    res.status(200).json({ 
        status: 'Live', 
        database_ready: !!supabase,
        checks: {
            url_present: !!SUPABASE_URL,
            key_present: !!SUPABASE_KEY,
            mail_ready: !!process.env.GMAIL_USER
        },
        timestamp: new Date().toISOString()
    });
});

// 2. SEND OTP
app.post('/api/auth/send-otp', async (req, res) => {
    const { email } = req.body;
    if (!email) return res.status(400).json({ error: "Email is required" });

    const otp = crypto.randomInt(100000, 999999).toString();
    
    try {
        await transporter.sendMail({
            from: `"ALAM STORE" <${process.env.GMAIL_USER}>`,
            to: email,
            subject: 'Verification Code - ALAM STORE',
            html: `
            <div style="font-family: Arial, sans-serif; padding: 20px; border: 1px solid #eee; border-radius: 10px;">
                <h2 style="color: #004AAD;">Verification Code</h2>
                <p>Aapka registration code niche diya gaya hai:</p>
                <h1 style="background: #f4f4f4; padding: 10px; text-align: center; letter-spacing: 5px;">${otp}</h1>
                <p>Ye code 10 minutes tak valid hai.</p>
            </div>`
        });
        res.json({ success: true, message: "OTP sent successfully" }); 
    } catch (e) {
        console.error("Mail Error:", e.message);
        res.status(500).json({ error: "Failed to send OTP. Check mail config." });
    }
});

// 3. LOGIN
app.post('/api/auth/login', async (req, res) => {
    if (!supabase) return res.status(500).json({ error: "Database not connected" });
    
    const { email, password } = req.body;
    if (!email || !password) return res.status(400).json({ error: "Missing fields" });

    try {
        const { data: user, error } = await supabase
            .from('users')
            .select('*')
            .eq('email', email)
            .single();

        if (error || !user) return res.status(404).json({ error: "User not found" });

        const isMatch = await bcrypt.compare(password, user.password);
        if (!isMatch) return res.status(401).json({ error: "Invalid password" });

        const token = jwt.sign({ id: user.id, email: user.email }, 'ALAM_SECURE_2026', { expiresIn: '90d' });
        
        // Security: Password delete kar dena response se pehle
        delete user.password;
        
        res.json({ success: true, token, user });
    } catch (e) {
        console.error("Login Error:", e.message);
        res.status(500).json({ error: "Server error during login" });
    }
});

// --- VERCEL EXPORT ---
module.exports = app;