vcl 4.1;

backend default {
    .host = "backend";
    .port = "8080";
    .connect_timeout = 5s;
    .first_byte_timeout = 60s;
    .between_bytes_timeout = 10s;
    .probe = {
        .url = "/api/data";
        .timeout = 5s;
        .interval = 10s;
        .window = 5;
        .threshold = 3;
    }
}

sub vcl_recv {
    # Add forwarded header
    if (req.http.X-Forwarded-For) {
        set req.http.X-Forwarded-For = req.http.X-Forwarded-For + ", " + client.ip;
    } else {
        set req.http.X-Forwarded-For = client.ip;
    }
    
    # Enable grace mode
    if (req.http.Cache-Control ~ "no-cache" || req.http.Pragma ~ "no-cache") {
        set req.hash_always_miss = true;
    }
    
    return (hash);
}

sub vcl_backend_response {
    # Enable grace mode: serve stale content for 2 hours if backend is down
    set beresp.grace = 2h;
    
    # Cache for 1 minute by default
    if (beresp.ttl <= 0s) {
        set beresp.ttl = 60s;
    }
    
    # Add header to indicate cache status
    set beresp.http.X-Cache-TTL = beresp.ttl;
    
    return (deliver);
}

sub vcl_deliver {
    # Add header to show if response came from cache
    if (obj.hits > 0) {
        set resp.http.X-Cache = "HIT";
        set resp.http.X-Cache-Hits = obj.hits;
    } else {
        set resp.http.X-Cache = "MISS";
    }
    
    # Add CORS headers for frontend
    set resp.http.Access-Control-Allow-Origin = "*";
    set resp.http.Access-Control-Allow-Methods = "GET, POST, PUT, DELETE, OPTIONS";
    set resp.http.Access-Control-Allow-Headers = "Content-Type";
    
    return (deliver);
}

sub vcl_backend_error {
    # Serve stale content if available (grace mode)
    if (bereq.is_bgfetch) {
        return (deliver);
    }
    
    return (deliver);
}
