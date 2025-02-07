--
-- Licensed to the Apache Software Foundation (ASF) under one or more
-- contributor license agreements.  See the NOTICE file distributed with
-- this work for additional information regarding copyright ownership.
-- The ASF licenses this file to You under the Apache License, Version 2.0
-- (the "License"); you may not use this file except in compliance with
-- the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

function rewrite_body(tag, timestamp, record)
    record["body"] = {text={text="fluentbit " .. record["body"]}}
    record["tags"] = {data={{key="level", value="INFO"}}}
    record["traceContext"] = {traceId=record["traceId"],traceSegmentId=record["traceSegmentId"],spanId=record["spanId"]}
    return 1, timestamp, record
end


function rewrite_access_log(tag, timestamp, record)
    local newRecord = {}
    newRecord["layer"] = "NGINX"
    newRecord["service"] = "nginx::local-openresty"
    newRecord["serviceInstance"] = "openresty-1-25"
    newRecord["body"] = { text = { text = record.log } }
    newRecord["tags"] = {data={{key="LOG_KIND", value="NGINX_ACCESS_LOG"}}}
    newRecord["traceContext"] = {traceId=record["traceId"],traceSegmentId=record["traceSegmentId"],spanId=record["spanId"]}
    return 1, timestamp, newRecord
end

function rewrite_error_log(tag, timestamp, record)
    local newRecord = {}
    newRecord["layer"] = "NGINX"
    newRecord["service"] = "nginx::local-openresty"
    newRecord["serviceInstance"] = "openresty-1-25"
    newRecord["body"] = { text = { text = record.log } }
    newRecord["tags"] = {data={{key="LOG_KIND", value="NGINX_ERROR_LOG"}}}
    newRecord["traceContext"] = {traceId=record["traceId"],traceSegmentId=record["traceSegmentId"],spanId=record["spanId"]}
    return 1, timestamp, newRecord
end
