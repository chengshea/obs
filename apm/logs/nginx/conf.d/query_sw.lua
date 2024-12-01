
function  query(uri)
    local http = require "resty.http"
    local httpc = http.new()

    -- 如果参数 uri 为空，则设置默认值
    if not uri or uri == "" then
        uri = "http://127.0.0.1:12800"
    end

    local  res, err = httpc:request_uri(uri, {
        method = "GET",
        headers = {
            ["User-Agent"] = "lua-resty-http"
        }
    })

  -- 确保在所有情况下都关闭 HTTP 客户端
    local status = nil
    if not res then
        ngx.log(ngx.ERR, "query failed: ", err)
    else
        if res.status >= 200 and res.status < 500 then
            status = res.status
        else
            ngx.log(ngx.ERR, "query returned status: ", res.status)
        end
    end

    httpc:close()
    return status
    
end


return { query = query }
