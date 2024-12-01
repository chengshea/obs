DOCKER_VAR_DIR = '/var/lib/docker/containers/'
DOCKER_CONTAINER_CONFIG_FILE = '/config.v2.json'

-- 定义正则表达式用于提取固定字段 容器名称 启动时间
DOCKER_CONTAINER_METADATA = {
  ['docker.container_name'] = '\"Name\":\"/?(.-)\"',
  ['docker.container_started'] = '\"StartedAt\":\"(.-)\"'
}

cache = {}

-- 从 config.v2.json 文件中获取容器元数据
function get_container_metadata_from_disk(container_id)
  local docker_config_file = DOCKER_VAR_DIR .. container_id .. DOCKER_CONTAINER_CONFIG_FILE
  local fl = io.open(docker_config_file, 'r')

  if not fl then
    return nil  -- 如果文件无法打开，返回 nil
  end

  -- 解析 JSON 文件并创建缓存记录
  local data = {}
  for line in fl:lines() do
    for key, regex in pairs(DOCKER_CONTAINER_METADATA) do
      local match = line:match(regex)  -- 使用正则表达式匹配
      if match then
        data[key] = match  -- 将匹配结果存入 data
      end
    end
  end
  fl:close()

  -- 如果 data 为空，则返回 nil
  return next(data) and data or nil  
end

-- 使用 Docker 元数据丰富日志记录
function encrich_with_docker_metadata(tag, timestamp, record)

  -- 从标签中获取容器 ID
  local container_id = tag:match'.*%.(.*)'  -- 提取容器 ID
  if not container_id then
    return 0, 0, 0  -- 如果无法提取 ID，则返回 0
  end

  -- 将 container_id 添加到记录中
  local new_record = record
  new_record['docker.container_id'] = container_id

  -- 检查缓存中是否存在容器的元数据
  local cached_data = cache[container_id]
  if not cached_data then
    cached_data = get_container_metadata_from_disk(container_id)  -- 从磁盘获取元数据
    if cached_data then
      cache[container_id] = cached_data  -- 将元数据缓存
    end
  end

  -- 如果找到了元数据，则丰富记录
  if cached_data then
    for key, _ in pairs(DOCKER_CONTAINER_METADATA) do
      new_record[key] = cached_data[key]  -- 将元数据添加到新记录中
    end
  end

  return 1, timestamp, new_record  -- 返回更新后的记录
end

--  forward模式
function remove_slash(tag, timestamp, record)
    local container_name = record["container_name"]
    if container_name then
        -- 去掉 container_name 中的 '/'
        container_name = string.gsub(container_name, "/", "")
        record["container_name"] = container_name
    end
    return 1, timestamp, record
end

--  Path_Key container_name
function path_name_and_topic_key(tag, timestamp, record)
    local path = record["container_name"]
    local prefix = record["topic_name"]
    local container_name = string.match(path, "([^/]+)-error%.log$")
    if container_name then
        --  topic_name 加前缀
        record["topic_name"] = prefix .. container_name
        record["container_name"] = container_name
    end
    return 1, timestamp, record
end


function add_topic_key(tag, timestamp, record)
    local container_name = record["container_name"]
    local prefix = record["topic_name"]
    if container_name then
        --  topic_name 加前缀
        record["topic_name"] = prefix .. record["container_name"]
    end
    return 1, timestamp, record
end



--   source.docker.2e36f6ee8bf17a3fce585d0eb02f039c60e14490bbf0aec109d8fa78904f31c3
function test_lua(tag, timestamp, record)
    record["container_name"] = tag
    return 1, timestamp, record
end
