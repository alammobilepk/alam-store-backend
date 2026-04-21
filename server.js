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
const helmet = require('helmet'); // Security enhancement

const app = express();

// --- CONFIGURATION ---
const PORT = process.env.PORT || 3000;
const JWT_SECRET = process.env.JWT_SECRET || 'ALAM_ULTIMATE_SECURE_2026';

// --- PROFESSIONAL MIDDLEWARE ---
app.use(helmet()); // Headers security ke liye
app.use(express.json());
app.use(cors());
app.use(morgan('dev')); 

// --- SECURITY: Rate Limiter ---
const authLimiter = rateLimit({
    windowMs: 15 * 60 * 1000, 
    max: 10, 
    message: { error: "Boht zyada requests. Thori dair baad koshish karein." }
});

// --- SUPABASE & MAIL INIT ---
const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_KEY);
const otpStore = new Map();

const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: { 
        user: process.env.GMAIL_USER, 
        pass: process.env.GMAIL_PASS 
    }
});

// Verification to ensure mail server is ready
transporter.verify((error) => {
    if (error) console.log("Mail Server Error:", error);
    else console.log("🚀 Mail Server is ready!");
});

// --- HELPER: Token Generator ---
const generateToken = (user) => jwt.sign({ id: user.id, email: user.email }, JWT_SECRET, { expiresIn: '90d' });

// --- ROUTES ---

// 1. HEALTH CHECK (Render ko batane ke liye ke server zinda hai)
app.get('/health', (req, res) => res.status(200).send('OK'));

// 2. SEND OTP
app.post('/api/auth/send-otp', authLimiter, async (req, res) => {
    const { email } = req.body;
    if (!email) return res.status(400).json({ error: "Email zaroori hai" });

    const otp = crypto.randomInt(100000, 999999).toString();
    otpStore.set(email, { otp, expires: Date.now() + 600000 });

    try {
        await transporter.sendMail({
            from: `"ALAM STORE" <${process.env.GMAIL_USER}>`,
            to: email,
            subject: 'Verification Code - ED Electronic Dukaan',
            html: `
            <div style="max-width: 400px; margin: auto; padding:20px; border:1px solid #e0e0e0; border-radius:15px; font-family: 'Poppins', sans-serif; color: #333;">
                <h2 style="color:#004AAD; text-align: center;">ALAM ENTERPRISES</h2>
                <p style="font-size: 16px;">Assalam-o-Alaikum,</p>
                <p>Aapka account verify karne ke liye verification code ye hai:</p>
                <div style="background:#f4f7ff; padding:20px; text-align:center; border-radius: 10px;">
                    <h1 style="color:#004AAD; letter-spacing:8px; margin:0;">${otp}</h1>
                </div>
                <p style="font-size: 12px; color: #777; margin-top: 20px;">Yeh code 10 minutes mein expire ho jayega. Agar aapne ye request nahi ki toh isay ignore karein.</p>
            </div>`
        });
        res.json({ success: true, message: "OTP Bhej diya gaya" });
    } catch (e) {
        console.error("Mail Error:", e);
        res.status(500).json({ error: "Mail system fail ho gaya" });
    }
});

// 3. REGISTER & AUTO-LOGIN
app.post('/api/auth/register', async (req, res) => {
    const { email, otp, password, phone, name } = req.body;
    const record = otpStore.get(email);

    if (!record || record.otp !== otp || Date.now() > record.expires) {
        return res.status(400).json({ error: "OTP galat hai ya expire ho chuka hai" });
    }

    try {
        const hashedPassword = await bcrypt.hash(password, 12);
        const { data, error } = await supabase
            .from('users')
            .insert([{ email, password: hashedPassword, phone_number: phone, full_name: name }])
            .select().single();

        if (error) throw error;

        otpStore.delete(email);
        res.status(201).json({ success: true, token: generateToken(data), user: data });
    } catch (err) {
        console.error("Reg Error:", err.message);
        res.status(400).json({ error: "Registration nakam. Shayad email pehle se mojud hai." });
    }
});

// 4. PROFESSIONAL LOGIN
app.post('/api/auth/login', async (req, res) => {
    const { email, password } = req.body;
    if (!email || !password) return res.status(400).json({ error: "Fields khali hain" });

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

// --- GLOBAL ERROR HANDLER ---
app.use((err, req, res, next) => {
    console.error(err.stack);
    res.status(500).json({ error: 'Kuch ghalat ho gaya! Server refresh karein.' });
});

// --- START SERVER ---
app.listen(PORT, '0.0.0.0', () => {
    console.log(`
    🚀 ELITE BACKEND LIVE
    📍 PORT: ${PORT}
    🛠️ ENVIRONMENT: ${process.env.NODE_ENV || 'development'}
    `);
});