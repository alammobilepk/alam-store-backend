// Isko top par hi rehne dein
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

// --- SECURITY & MIDDLEWARE ---
app.use(helmet());
app.use(express.json());
app.use(cors());

// --- SUPABASE SAFE INIT ---
// Hum yahan direct process.env check kar rahe hain
const supabaseUrl = process.env.SUPABASE_URL || "";
const supabaseKey = process.env.SUPABASE_KEY || "";

// Agar variables missing hain toh crash hone ke bajaye error return karega
let supabase;
if (supabaseUrl && supabaseKey) {
    supabase = createClient(supabaseUrl, supabaseKey);
}

// --- MAIL INIT ---
const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: { 
        user: process.env.GMAIL_USER, 
        pass: process.env.GMAIL_PASS 
    }
});

// --- ROUTES ---

// Health Check (Check karne ke liye ke server alive hai)
app.get('/api/health', (req, res) => {
    res.status(200).json({ 
        status: 'Live', 
        supabase_connected: !!supabase,
        env_check: supabaseUrl ? "URL Found" : "URL Missing" 
    });
});

// LOGIN
app.post('/api/auth/login', async (req, res) => {
    if (!supabase) return res.status(500).json({ error: "Database configuration missing on server" });
    
    const { email, password } = req.body;
    try {
        const { data: user, error } = await supabase.from('users').select('*').eq('email', email).single();
        if (error || !user) return res.status(404).json({ error: "Account nahi mila" });

        const isMatch = await bcrypt.compare(password, user.password);
        if (!isMatch) return res.status(401).json({ error: "Ghalat password" });

        const token = jwt.sign({ id: user.id }, 'ALAM_SECURE_2026', { expiresIn: '90d' });
        res.json({ success: true, token, user });
    } catch (e) {
        res.status(500).json({ error: "Server error" });
    }
});

// SEND OTP
app.post('/api/auth/send-otp', async (req, res) => {
    const { email } = req.body;
    if (!email) return res.status(400).json({ error: "Email zaroori hai" });

    const otp = crypto.randomInt(100000, 999999).toString();
    try {
        await transporter.sendMail({
            from: `"ALAM STORE" <${process.env.GMAIL_USER}>`,
            to: email,
            subject: 'Verification Code',
            html: `<h1>${otp}</h1>`
        });
        res.json({ success: true, message: "OTP sent" }); 
    } catch (e) {
        res.status(500).json({ error: "Mail failed" });
    }
});

// --- VERCEL EXPORT ---
module.exports = app;