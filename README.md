# Railway VLESS Panel

A small standalone Railway deployment that exposes a web panel on the service's public HTTP/HTTPS endpoint (target port 8080), then routes three VLESS transports to Xray on localhost.

## Login
- username: `admin`
- password: `admin1323`

The password is not displayed in the UI. Change it after login.

## Railway
Deploy from this repository with the Dockerfile. The service listens on `0.0.0.0:8080`, so Railway's public domain should target port 8080. Railway provides HTTPS/SSL at the public domain. Railway documents that public services should bind to `0.0.0.0:$PORT` and that target ports map a domain to an internal listening port. https://docs.railway.com/networking/public-networking

No Railway volume is strictly required for first boot, but attach a Volume at `/app/data` if you want the generated UUIDs and changed password to survive redeploys.

## Generated profiles
After login, the panel generates:
- VLESS + WebSocket, path `/ws-vless`
- VLESS + HTTPUpgrade, path `/hu-vless`
- VLESS + XHTTP, path `/xhttp-vless`

TLS in the client URL is terminated by Railway's public HTTPS layer; Xray's internal listeners intentionally use `security: none`. Xray supports WebSocket and HTTPUpgrade behind reverse proxies, and XHTTP is a native Xray transport. See https://xtls.github.io/en/config/transports/websocket and https://xtls.github.io/en/config/transports/httpupgrade and https://xtls.github.io/config/transports/xhttp.html

## Important
A real client-side "real delay" result depends on the client reaching the Railway public domain, the Railway target port being 8080, and the Xray listener accepting the selected transport. The panel does not fake a ping result.
