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

// --- CONFIGURATION ---
const JWT_SECRET = process.env.JWT_SECRET || 'ALAM_SECURE_2026_ULTRA_KEY';

// --- SUPABASE INITIALIZATION ---
const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_KEY = process.env.SUPABASE_KEY;

let supabase;
if (SUPABASE_URL && SUPABASE_KEY) {
    supabase = createClient(SUPABASE_URL, SUPABASE_KEY);
} else {
    console.error("❌ CRITICAL: Supabase credentials missing!");
}

// --- MAIL CONFIG (Optimized for Vercel/Serverless) ---
const transporter = nodemailer.createTransport({
    service: 'gmail',
    host: 'smtp.gmail.com',
    port: 465,
    secure: true,
    pool: true, // Connection pooling for serverless
    auth: { 
        user: process.env.GMAIL_USER, 
        pass: process.env.GMAIL_PASS 
    },
    // Serverless timeout issues fix
    connectionTimeout: 10000, 
    greetingTimeout: 5000,
    socketTimeout: 15000
});

// --- ROUTES ---

// 1. HEALTH CHECK
app.get('/api/health', (req, res) => {
    res.status(200).json({ 
        status: 'Live', 
        database: !!supabase,
        mail_config: !!process.env.GMAIL_USER,
        timestamp: new Date().toISOString()
    });
});

// 2. SEND OTP
app.post('/api/auth/send-otp', async (req, res) => {
    const { email } = req.body;
    if (!email) return res.status(400).json({ error: "Email is required" });

    const otp = crypto.randomInt(100000, 999999).toString();
    
    const mailOptions = {
        from: `"ALAM STORE" <${process.env.GMAIL_USER}>`,
        to: email,
        subject: 'Verification Code - ALAM STORE',
        html: `
        <div style="font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; padding: 30px; border: 1px solid #e0e0e0; border-radius: 12px; max-width: 500px; margin: auto;">
            <div style="text-align: center; margin-bottom: 20px;">
                <h1 style="color: #004AAD; margin: 0;">ALAM STORE</h1>
                <p style="color: #666;">Official Verification Service</p>
            </div>
            <hr style="border: 0; border-top: 1px solid #eee;" />
            <p style="font-size: 16px; color: #333;">Aapka security code ye hai:</p>
            <div style="background: #f9f9f9; padding: 20px; text-align: center; border-radius: 8px; margin: 20px 0;">
                <span style="font-size: 32px; font-weight: bold; color: #004AAD; letter-spacing: 8px;">${otp}</span>
            </div>
            <p style="font-size: 14px; color: #999; text-align: center;">Ye code 10 minutes mein expire ho jayega. Kisi se share na karein.</p>
        </div>`
    };

    try {
        await transporter.sendMail(mailOptions);
        // Tip: For production, save this OTP in Supabase 'otp_verifications' table
        res.json({ success: true, message: "OTP sent successfully" }); 
    } catch (e) {
        console.error("Mail Error:", e.message);
        res.status(500).json({ 
            error: "Email delivery failed", 
            details: process.env.NODE_ENV === 'development' ? e.message : 'SMTP Config Error' 
        });
    }
});

// 3. LOGIN
app.post('/api/auth/login', async (req, res) => {
    if (!supabase) return res.status(500).json({ error: "Database not ready" });
    
    const { email, password } = req.body;
    if (!email || !password) return res.status(400).json({ error: "Email and password are required" });

    try {
        const { data: user, error } = await supabase
            .from('users')
            .select('*')
            .eq('email', email)
            .single();

        if (error || !user) return res.status(404).json({ error: "Account not found" });

        const isMatch = await bcrypt.compare(password, user.password);
        if (!isMatch) return res.status(401).json({ error: "Invalid credentials" });

        const token = jwt.sign(
            { id: user.id, email: user.email }, 
            JWT_SECRET, 
            { expiresIn: '90d' }
        );
        
        delete user.password;
        res.json({ success: true, token, user });
    } catch (e) {
        console.error("Login Error:", e.message);
        res.status(500).json({ error: "Internal server error" });
    }
});

// --- GLOBAL ERROR HANDLER ---
app.use((err, req, res, next) => {
    console.error(err.stack);
    res.status(500).json({ error: "Something went wrong on the server!" });
});

// --- VERCEL EXPORT ---
module.exports = app;