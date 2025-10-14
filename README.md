docker build -t speedtest:latest .

    location /speedtest/ {
        proxy_pass http://127.0.0.1:8085;
        proxy_http_version 1.1;
        proxy_request_buffering off;
        proxy_buffering off;
        proxy_read_timeout 300s;
        gzip off;
    }
