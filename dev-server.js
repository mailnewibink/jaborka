const http = require('http');
const fs = require('fs');
const path = require('path');

const DEFAULT_PORT = process.env.PORT || 3000;
const MIME_TYPES = {
    '.html': 'text/html; charset=UTF-8',
    '.css': 'text/css',
    '.js': 'application/javascript',
    '.png': 'image/png',
    '.jpg': 'image/jpeg',
    '.jpeg': 'image/jpeg',
    '.gif': 'image/gif',
    '.svg': 'image/svg+xml',
    '.ico': 'image/x-icon',
    '.json': 'application/json'
};

const DATA_FILE = path.join(__dirname, 'pricing.json');

const server = http.createServer((req, res) => {
    // Enable CORS for all requests
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

    if (req.method === 'OPTIONS') {
        res.writeHead(204);
        res.end();
        return;
    }

    let reqPath = req.url.split('?')[0];

    // API: /api/pricing (Handled by api/pricing.js for both local and Vercel)
    if (reqPath === '/api/pricing') {
        const pricingHandler = require('./api/pricing');
        let body = '';
        req.on('data', chunk => {
            body += chunk.toString();
        });
        req.on('end', async () => {
            try {
                req.body = body ? JSON.parse(body) : null;
            } catch (e) {
                req.body = null;
            }
            res.status = function(code) {
                res.statusCode = code;
                return res;
            };
            res.json = function(data) {
                res.writeHead(res.statusCode || 200, { 'Content-Type': 'application/json; charset=UTF-8' });
                res.end(JSON.stringify(data));
                return res;
            };
            try {
                await pricingHandler(req, res);
            } catch (err) {
                console.error('API handler error:', err);
                if (!res.headersSent) {
                    res.writeHead(500, { 'Content-Type': 'application/json' });
                    res.end(JSON.stringify({ error: err.message }));
                }
            }
        });
        return;
    }

    // Page routing: /admin -> admin.html
    if (reqPath === '/admin' || reqPath === '/admin/') {
        reqPath = '/admin.html';
    } else if (reqPath === '/' || reqPath === '') {
        reqPath = '/index.html';
    }

    const safePath = path.normalize(reqPath).replace(/^(\.\.[\/\\])+/, '');
    const filePath = path.join(__dirname, safePath);

    fs.readFile(filePath, (err, data) => {
        if (err) {
            if (err.code === 'ENOENT') {
                res.writeHead(404, { 'Content-Type': 'text/plain; charset=UTF-8' });
                res.end('404 Not Found');
            } else {
                res.writeHead(500, { 'Content-Type': 'text/plain; charset=UTF-8' });
                res.end('500 Internal Server Error');
            }
            return;
        }

        const ext = path.extname(filePath).toLowerCase();
        const contentType = MIME_TYPES[ext] || 'application/octet-stream';
        res.writeHead(200, { 'Content-Type': contentType });
        res.end(data);
    });
});

function start(port) {
    server.listen(port, '127.0.0.1', () => {
        console.log(`Server running at http://127.0.0.1:${port}/`);
        console.log(`Admin panel available at http://127.0.0.1:${port}/admin`);
    });
    server.on('error', (err) => {
        if (err.code === 'EADDRINUSE') {
            console.log(`Port ${port} in use, trying ${port + 1}...`);
            start(port + 1);
        } else {
            console.error('Server error:', err);
        }
    });
}

start(DEFAULT_PORT);
