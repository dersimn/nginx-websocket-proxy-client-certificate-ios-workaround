local HMAC_SECRET = "hunter2"
local crypto = require "crypto"
 
function ComputeHmac(msg, expires)
  return crypto.hmac.digest("sha256", string.format("%s%d", msg, expires), HMAC_SECRET)
end
 
verify_status = ngx.var.ssl_client_verify
 
if verify_status == "SUCCESS" then
  client = crypto.digest("sha256", ngx.var.ssl_client_cert)
  expires = ngx.time() + 3600
 
  ngx.header["Set-Cookie"] = {
    string.format("AccessToken=%s; path=/", ComputeHmac(client, expires)),
    string.format("ClientId=%s; path=/", client),
    string.format("AccessExpires=%d; path=/", expires)
  }
  return
end
 
ngx.exit(ngx.HTTP_FORBIDDEN)
