 # initialize vault server
  export VAULT_ADDR=http://127.0.0.1:8200

# start initialization with the default options by running the command below
  echo -e '\e[38;5;198m'"++++ Cleanup existing vault data"
  rm -rf ../data/*
  sleep 5
  echo -e '\e[38;5;198m'"++++ Vault init"
  vault operator init > /vault/init.file
  cat /vault/init.file

  echo -e '\e[38;5;198m'"++++ Auto unseal vault"
  for i in $(cat /vault/init.file | grep Unseal | cut -d " " -f4 | head -n 3); do vault operator unseal $i; done
  vault status
  # cat /vault/init.file
  # add vault ENV variables
  echo -e '\e[38;5;198m'"++++ export VAULT_TOKEN"
  export VAULT_TOKEN=$(grep 'Initial Root Token' /vault/init.file | cut -d ':' -f2 | tr -d ' ')
  echo -e '\e[38;5;198m'"++++ Vault http://localhost:8200/ui and enter the following codes displayed below"
  echo -e '\e[38;5;198m'"++++ Vault `grep Token /vault/init.file`"


