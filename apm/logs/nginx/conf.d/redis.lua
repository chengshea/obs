local clientIP = ngx.var.remote_addr
-- 如果有代理，获取 X-Forwarded-For 头部中的 IP
if clientIP == nil then
    clientIP = ngx.req.get_headers()["X-Forwarded-For"]
end

-- 连接到 Redis
local redis = require "resty.redis"
local red = redis.new()

local ok, err = red:connect("127.0.0.1", 9736)
if not ok then
    ngx.say("failed to connect to Redis: ", err)
    return
end

-- 填写Redis密码
local password = "cs123456"

-- 验证密码
local res, err = red:auth(password)
if not res then
    ngx.say("failed to authenticate: ", err)
    return
end


-- 查询 Redis 中的键值
local key = "ip_segment:" .. clientIP
local value, err = red:get(key)
if err then
    ngx.say("failed to get value from Redis: ", err)
    return
end

-- 检查值是否在网段内，这里以 192.168.1. 为例
local netmask = "192.168.1."
if string.sub(clientIP, 1, string.len(netmask)) == netmask then
    -- 如果 IP 在网段内，执行 @client2
    ngx.exec("@client2")
else
ngx.log(ngx.ERR,"=====",key," ",value,"=========") 
    -- 否则执行 @client1
    ngx.exec("@client1")
end

-- 关闭 Redis 连接
local ok, err = red:set_keepalive(10000, 100)
if not ok then
    ngx.say("failed to set Redis keepalive: ", err)
    return
end