// Vercel Serverless Function: /api/pricing
// Supports Supabase PostgreSQL cloud storage with automatic seeding and fallback to pricing.json

const fs = require('fs');
const path = require('path');

const SUPABASE_URL = process.env.SUPABASE_URL || 'https://ktepilhhldgtayetjmzv.supabase.co';
const SUPABASE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.SUPABASE_KEY || process.env.SUPABASE_ANON_KEY;

let defaultPricing = {};
try {
    defaultPricing = require('../pricing.json');
} catch (e) {
    defaultPricing = {};
}

function getLocalFallback() {
    return defaultPricing;
}

module.exports = async (req, res) => {
    // Enable CORS
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

    if (req.method === 'OPTIONS') {
        return res.status(204).end();
    }

    // 1. GET: Ambil data tarif
    if (req.method === 'GET') {
        if (!SUPABASE_KEY) {
            console.log('SUPABASE_KEY belum diset, menggunakan local fallback pricing.json');
            return res.status(200).json(getLocalFallback());
        }

        try {
            const url = `${SUPABASE_URL.replace(/\/$/, '')}/rest/v1/pricing_config?id=eq.main&select=data`;
            const response = await fetch(url, {
                headers: {
                    'apikey': SUPABASE_KEY,
                    'Authorization': `Bearer ${SUPABASE_KEY}`,
                    'Content-Type': 'application/json'
                }
            });

            if (!response.ok) {
                const errText = await response.text();
                throw new Error(`Supabase query status ${response.status}: ${errText}`);
            }

            const rows = await response.json();
            
            // Jika data sudah ada di Supabase, kembalikan data tersebut
            if (Array.isArray(rows) && rows.length > 0 && rows[0].data) {
                return res.status(200).json(rows[0].data);
            }

            // Jika tabel masih kosong, lakukan auto-seed dari pricing.json lokal
            console.log('Tabel Supabase masih kosong, melakukan seeding otomatis dari pricing.json...');
            const fallbackData = getLocalFallback();

            const seedUrl = `${SUPABASE_URL.replace(/\/$/, '')}/rest/v1/pricing_config`;
            await fetch(seedUrl, {
                method: 'POST',
                headers: {
                    'apikey': SUPABASE_KEY,
                    'Authorization': `Bearer ${SUPABASE_KEY}`,
                    'Content-Type': 'application/json',
                    'Prefer': 'resolution=merge-duplicates'
                },
                body: JSON.stringify({
                    id: 'main',
                    data: fallbackData,
                    updated_at: new Date().toISOString()
                })
            });

            return res.status(200).json(fallbackData);
        } catch (err) {
            console.error('Error saat fetch dari Supabase:', err.message);
            // Fallback aman ke file lokal jika jaringan bermasalah
            return res.status(200).json(getLocalFallback());
        }
    }

    // 2. POST: Simpan data tarif baru dari /admin
    if (req.method === 'POST') {
        const pricingData = req.body;
        if (!pricingData || typeof pricingData !== 'object' || Object.keys(pricingData).length === 0) {
            return res.status(400).json({ error: 'Payload tarif tidak valid' });
        }

        if (!SUPABASE_KEY) {
            // Jika di local tanpa Supabase key, tulis ke file lokal
            try {
                const filePath = path.join(process.cwd(), 'pricing.json');
                fs.writeFileSync(filePath, JSON.stringify(pricingData, null, 2), 'utf8');
                return res.status(200).json({ success: true, message: 'Tarif berhasil disimpan (local mode)!' });
            } catch (err) {
                return res.status(500).json({ error: 'Gagal menulis file: ' + err.message });
            }
        }

        try {
            const upsertUrl = `${SUPABASE_URL.replace(/\/$/, '')}/rest/v1/pricing_config`;
            const response = await fetch(upsertUrl, {
                method: 'POST',
                headers: {
                    'apikey': SUPABASE_KEY,
                    'Authorization': `Bearer ${SUPABASE_KEY}`,
                    'Content-Type': 'application/json',
                    'Prefer': 'resolution=merge-duplicates'
                },
                body: JSON.stringify({
                    id: 'main',
                    data: pricingData,
                    updated_at: new Date().toISOString()
                })
            });

            if (!response.ok) {
                const errText = await response.text();
                throw new Error(`Gagal menyimpan ke Supabase (${response.status}): ${errText}`);
            }

            return res.status(200).json({ success: true, message: 'Tarif berhasil disimpan ke Supabase cloud!' });
        } catch (err) {
            console.error('Error menyimpan ke Supabase:', err.message);
            return res.status(500).json({ error: 'Gagal menyimpan ke database: ' + err.message });
        }
    }

    return res.status(405).json({ error: 'Method not allowed' });
};
