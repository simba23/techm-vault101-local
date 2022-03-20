#!/bin/bash
export VAULT_ADDR="http://127.0.0.1:8200/"
export VAULT_HOME="${HOME}/vault"
export LOGFILE="${VAULT_HOME}/logs/perfout.log"
VAULT_INIT="${VAULT_HOME}/init.file"
VAULT_TOKEN=$(grep 'Initial Root Token' ${VAULT_INIT} | awk '{print $NF}')
echo $VAULT_TOKEN

rm -f ${LOGFILE}

echo "enable vault audit log....in the container /vault/logs/vault_audit.log"
vault audit enable file file_path=/vault/logs/vault_audit.log >>  ${LOGFILE} 2>&1

echo "vault login...."
vault login -no-print  $(grep 'Initial Root Token' ${VAULT_INIT} | awk '{print $NF}')

echo "vault secrets enable .... "
vault secrets enable -version=2 kv >>  ${LOGFILE} 2>&1
sleep 2

# exit

# for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25

for i in {1..10}
  do
    printf "."
#    vault kv put kv/$i-secret-10 id="$(uuidgen)" >> ${LOGFILE} 2>&1
#    echo "a-secret-${i}" 
    vault kv put kv/$i-secret-10 id="a-secret-${i}" >> ${LOGFILE} 2>&1
done
echo "generated 10 secrets"
sleep 2

for i in {1..25}
  do
    printf "."
    vault kv put kv/$i-secret-25 id="$(uuidgen)" >> ${LOGFILE} 2>&1
#    vault kv put kv/$i-secret-25 id="b-secret$i" >> ${LOGFILE} 2>&1
done
echo "generated 25 secrets"
sleep 2
for i in {1..50}
  do
    printf "."
    vault kv put kv/$i-secret-50 id="$(uuidgen)" >> ${LOGFILE} 2>&1
#    vault kv put kv/$i-secret-50 id="c-secret$i" >> ${LOGFILE} 2>&1
done
echo "generated 50 secrets"
sleep 2

for i in {1..10}
  do
    printf "."
    vault kv put kv/$i-secret-10 id="$(uuidgen)" >> ${LOGFILE} 2>&1
    #vault kv put kv/$i-secret-10 id="a-secret$i" >> ${LOGFILE} 2>&1
done
echo "updated first 10 secrets"
sleep 2


echo "Token and Leases: Created a sudo policy for tokens"

echo "write admin  policy..."
vault policy write admin - << EOT >>  ${LOGFILE} 2>&1
// Example admin policy: "admin"

# Manage auth methods broadly across Vault
path "auth/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
# Create, update, and delete auth methods
path "sys/auth/*"
{
  capabilities = ["create", "update", "delete", "sudo"]
}
# List auth methods
path "sys/auth"
{
  capabilities = ["read"]
}
# List existing policies
path "sys/policies/acl"
{
  capabilities = ["list"]
}
# Create and manage ACL policies
path "sys/policies/acl/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
# List, create, update, and delete key/value secrets
path "secret/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
# Manage secrets engines
path "sys/mounts/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
# List existing secrets engines.
path "sys/mounts"
{
  capabilities = ["read"]
}
# Read health checks
path "sys/health"
{
  capabilities = ["read", "sudo"]
}
EOT
echo "done."
sleep 2

echo "write sudo policy..."
vault policy write sudo - << EOT >>  ${LOGFILE} 2>&1
// Example policy: "sudo"
path "*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
EOT
echo "done."
sleep 2

echo "create 10 base policies...."
for i in {1..10}
  do
    printf "."
      vault policy write base-$i  - << EOT >>  ${LOGFILE} 2>&1
// Example policy: "base"
   path "secret/data/$i/training_*" {
       capabilities = ["create", "read"]
   }
   path "secret/data/$i/+/apikey" {
       capabilities = ["create", "read", "update", "delete"]
   }
EOT
done
echo "done."


sleep 2
echo "enable userpass auth method...."
vault auth enable userpass >>  ${LOGFILE} 2>&1
echo "done."

sleep 2
echo "create one perfuser user...."
echo "add a perfuser user with password vtl-password"
vault write auth/userpass/users/perfuser \
  password=vtl-password \
  token_ttl=1m \
  token_max_ttl=10m \
  token_policies=sudo >>  ${LOGFILE} 2>&1
echo "done."

sleep 2
echo "create 50 perftest# users...."
for i in {1..50}
do
printf "."
# echo "add a perfuser$i user with password vtl-password"
vault write auth/userpass/users/perfuser$i \
  password=vtl-password \
  token_ttl=1m \
  token_max_ttl=10m \
  token_policies=sudo >>  ${LOGFILE} 2>&1
done
echo "done."

sleep 2
echo "login to vault 10 times as the perfuser# user"
for i in {1..10}
  do
    printf "."
    vault login \
      -method=userpass \
      username=perfuser$i \
      password=vtl-password >> ${LOGFILE} 2>&1
done
echo "done."

sleep 2
echo "login to vault 25 times as the perfuser# user"
for i in {1..25}
  do
    printf "."
    vault login \
      -method=userpass \
      username=perfuser$i \
      password=vtl-password >> ${LOGFILE} 2>&1
done
echo "done."

sleep 2
echo "login to vault 50 times as the perfuser# user"
for i in {1..50}
  do
    printf "."
    vault login \
      -method=userpass \
      username=perfuser$i \
      password=vtl-password >> ${LOGFILE} 2>&1
done
echo "done."


sleep 2
echo "use the token auth method to create 25 tokens with default policy and no default TTL values"
for i in {1..25}
  do
    printf "."
    vault token create -policy=default >> ${LOGFILE} 2>&1
done
echo "done."


