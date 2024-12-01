#!/bin/bash

<<EOF

find ./ -type f   \( -name "*.yaml" -o -name "*.yml" \)  -exec grep -l '/mnt/' {} +

find "$base" -type f \( -name "*.yaml" -o -name "*.yml" \) -print0：find 命令搜索所有 .yaml 或 .yml 文件，并且 -print0 选项会将结果以 null 字符终止的方式输出，这样可以正确处理文件名中的空格和特殊字符。

xargs -0 grep -l '/mnt/'：xargs 命令将 find 命令的输出作为输入，并且 -0 选项告诉 xargs 使用 null 字符作为输入项的分隔符。这样可以确保 grep 命令正确处理文件名。

while read -r url; do ... done：这个循环读取 grep 命令的输出，每次读取一个文件名。-r 选项告诉 read 命令不要解释反斜杠，这在处理文件路径时很有用。

EOF


#定义需要处理的路径 源路径 目标路径

change(){
  local file="$1"
  local source="$2"
  local target="$3"

  if grep -q "$source" "$file"; then
    echo "源路径: $source 目标路径: $target 路径：$1"
    sed -n "s#$source#$target#g"p "$1"
    sed -i "s|$source|$target|g" "$file"
  fi

}

base=/home/cs/oss/k8s-1.26


eg(){
# 使用子 shell 和 here 文档来创建临时输入流
(
  cat <<'EOF'
  /mnt/lvm/oss/tdb /mnt/oss/db/tsdb
  /mnt/lvm/oss/clickhouse /mnt/oss/db/olap/clickhouse
  /mnt/oss/data-root /mnt/oss/docker-root
EOF
) | while IFS=' ' read -r source target; do
  # 查找所有 .yaml 和 .yml 文件，并检查是否包含指定的源路径，然后对它们执行 change 函数
  find "$base" -type f \( -name "*.yaml" -o -name "*.yml" \) -print0 | xargs -0 grep -l "$source" | while IFS= read -r url; do
    change "$url" "$source" "$target"
  done
done
}


eg2(){
# 定义源路径和目标路径的映射
map=(
  "/mnt/lvm/oss/tdb /mnt/oss/db/tsdb"
  "/mnt/lvm/oss/clickhouse /mnt/oss/db/olap/clickhouse"
  "/mnt/oss/data-root /mnt/oss/docker-root"
)


find $base -type f   \( -name "*.yaml" -o -name "*.yml" \)  -print0 | xargs -0 grep -l '/mnt/' | while read -r url; do
   for pair in "${map[@]}"; do
    IFS=' ' read -r source target <<< "$pair"
    change "$url" "$source" "$target"
  done
done

}


eg2
