#!/bin/bash

<<EOF
2种方式
镜像仓库地址查询
❯ pwd
/home/cs/data/registry/harbor/registry
❯  find  docker/   -type  d  -name "current"  | sed  's|docker/registry/v2/repositories/||g;s|/_manifests/tags/|:|g;s|/current||g'

#该脚本针对{"version":"v2.0"}

EOF



version=$(curl https://k8s.org/api/version  -k)
#该脚本针对{"version":"v2.0"}
echo $version | grep -q '"version":"v2.0"' || { echo $version && exit 1;}

Address=k8s.org
URL=https://$Address
Projects=$URL/api/v2.0/projects

token="admin:cs123456"        #登录Harbor的用户密码
Images_File=harbor-images-`date '+%Y-%m-%d'`.txt   # 镜像清单文件
Tar_File=/backup/Harbor-backup/                 #镜像tar包存放路径
set -x
# 获取Harbor中所有的项目（Projects）
Project_List=$(curl -u $token  -H "Content-Type: application/json" -X GET  $Projects  -k  | python -m json.tool | grep name | awk '/"name": /' | awk -F '"' '{print $4}')

for Project in $Project_List;do
   # 循环获取项目下所有的镜像
    Image_Names=$(curl -u $token -H "Content-Type: application/json" -X GET $Projects/$Project/repositories -k | python -m json.tool | grep name | awk '/"name": /' | awk -F '"' '{print $4}')
    for Image in $Image_Names;do
        # 循环获取镜像的版本（tag)
        Image_Tags=$(curl -u $token  -H "Content-Type: application/json"   -X GET  $URL/v2/$Image/tags/list  -k |  awk -F '"'  '{print $8,$10,$12}')
        for Tag in $Image_Tags;do
            # 格式化输出镜像信息
            echo "$Address/$Image:$Tag"   >> harbor-images-`date '+%Y-%m-%d'`.txt
        done
    done
done
