# Azure Configuration Sample

Reference code for creating Azure Virtual Machines and configuring them using Ansible.

Prerequisites need to be either installed on the workstation, or accessed via Docker container:

```
docker run --rm -ti ghcr.io/andreyzher/azure-config-sample:main bash -il
```

## Build local Workstation Image

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

## Running Terraform

The sample Terraform code will reuse the Azure CLI credentials of the workstation, instead of handling it's own authentication.

1. To login on the workstation, run the command below and follow the prompts:

    ```
    az login
    ```

2. If this is the first time executing Terraform, run `terraform init` from the `tform` directory.

    > NOTE: The `terraform.tfstate` file must be persisted somewhere to share the state.
    > See [Terraform Documentation](https://www.terraform.io/language/settings/backends) for more information about the available backends.

3. Run the planning phase using:

    ```
    terraform plan -out=work
    ```

4. Inspect the output, and apply of the changes are as expected:

    ```
    terraform apply work
    ```
