{"https://www.cloudflare.com/": {"present": {"X-XSS-Protection": "1; mode=block", "X-Frame-Options": "SAMEORIGIN", "X-Content-Type-Options": "nosniff", "Strict-Transport-Security": "max-age=31536000; includeSubDomains"}, "missing": ["Content-Security-Policy", "Referrer-Policy", "Permissions-Policy", "Cross-Origin-Embedder-Policy", "Cross-Origin-Resource-Policy", "Cross-Origin-Opener-Policy"]}}
