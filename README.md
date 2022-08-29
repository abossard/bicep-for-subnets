# Example how to create subnets with Bicep

## Ingredients:
- Folder `vnet`, that contains a deployment for a vnet including all subnets
- Folder `subnet`, that contains a mapping from Json to Subnet properties and also is able to deploy the last or all subnets from the json definition
- `subnets.json`, that contains the subnet definitions

Play through the scenario:
1. Run the main VNET deployment (since yeah, you need a VNET)
    ```bash
        az deployment sub create \
            --name "vnet_subnet_test" \
            --location "westeurope" \
            --template-file ./vnet/main.bicep \
            --confirm-with-what-if
    ```
1. Add a subnet to the end of the subnets.json
1. Deploy this additional subnet imperatively
    ```bash
        az deployment group create \
            -g "rg-vnet-test" \
            --name "add_subnet_test" \
            --template-file ./subnet/main.bicep \
            --confirm-with-what-if
    ```
1. Now you can either add more or also at any time execute step 1 again.