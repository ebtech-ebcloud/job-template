#! /bin/bash

SSH_KEY_DIR=$(mktemp -d)

# 使用固定的随机种子生成密钥
# -N "" 表示无密码
# -C "" 表示无注释
# -f 指定输出文件
ssh-keygen -t rsa -b 2048 -N "" -C "" -f "${SSH_KEY_DIR}/id_rsa" <<<y >/dev/null 2>&1

# 设置 authorized_keys
cat "${SSH_KEY_DIR}/id_rsa.pub" > "${SSH_KEY_DIR}/authorized_keys"

# 创建或更新 ConfigMap
kubectl create configmap ssh-keys \
    --from-file=id_rsa="${SSH_KEY_DIR}/id_rsa" \
    --from-file=id_rsa.pub="${SSH_KEY_DIR}/id_rsa.pub" \
    --from-file=authorized_keys="${SSH_KEY_DIR}/authorized_keys" \
    -o yaml --dry-run=client | kubectl apply -f -

# 清理临时文件
rm -rf "${SSH_KEY_DIR}"