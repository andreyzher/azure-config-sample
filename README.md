# azure-config-sample

## Build Workstation Image

```
docker build --progress=plain -t azure-config-sample:latest .
```

> NOTE: If running without Docker BuildKit, or would prefer to see coloured output, omit the `--progress=plain` option

## Running Ansible Playbook

There are 2 options for running the playbook - remotely from a Workstation, or locally on the target environment. The latter requires Ansible to be present on the machine, which partly defeats the purpose.

### Local execution

```
cd ansible
ansible-playbook -c local -i localhost, playbook.yaml
```

### Remote execution

1. Copy `ansible/sample-inventory.yaml` to `ansible/inventory.yaml`:

    ```
    cp -v ansible/sample-inventory.yaml ansible/inventory.yaml
    ```

2. Update the file with the lists of required hosts and variables (especially the connection user and path to private key)

3. Run the Ansible Playbook:

    ```
    cd ansible
    ansible-playbook -i inventory.yaml playbook.yaml
    ```
