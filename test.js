fetch('http://localhost:3000/api/send-otp', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email: 'APNA_EMAIL_YAHA_LIKHEIN@gmail.com' })
})
.then(res => res.json())
.then(data => console.log(data))
.catch(err => console.log('Error:', err));