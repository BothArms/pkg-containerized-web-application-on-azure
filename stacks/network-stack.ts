import * as azurerm from "@cdktf/provider-azurerm";
import * as cdktf from "cdktf";
import { Construct } from "constructs";
import { DEFAULT_LOCATION } from "../const";
import { useAzureProvider } from "./lib/azure-provider";
import { createResourceGroup } from "./lib/resource-group";

export class NetworkStack extends cdktf.TerraformStack {
  public readonly vnet: azurerm.virtualNetwork.VirtualNetwork;
  public readonly publicSubnet: azurerm.subnet.Subnet;
  public readonly privateSubnet: azurerm.subnet.Subnet;
  public readonly nsg: azurerm.networkSecurityGroup.NetworkSecurityGroup;

  constructor(scope: Construct, id: string) {
    super(scope, id);

    useAzureProvider(this);

    const resourceGroup = createResourceGroup(this, {
      alias: "network",
      location: DEFAULT_LOCATION,
    });

    // Create vnet
    this.vnet = this.createVnet(resourceGroup);

    // Create public subnet
    this.publicSubnet = this.createSubnet(resourceGroup, this.vnet, "public", [
      "10.0.1.0/24",
    ]);

    // Create private subnet
    this.privateSubnet = this.createSubnet(
      resourceGroup,
      this.vnet,
      "private",
      ["10.0.2.0/24"]
    );

    // Create NSG
    this.nsg = this.createNsg(resourceGroup);
  }

  createVnet(resourceGroup: azurerm.resourceGroup.ResourceGroup) {
    return new azurerm.virtualNetwork.VirtualNetwork(this, "vnet", {
      name: "vnet",
      location: DEFAULT_LOCATION,
      resourceGroupName: resourceGroup.name,
      addressSpace: ["10.0.0.0/16"],
    });
  }

  createSubnet(
    resourceGroup: azurerm.resourceGroup.ResourceGroup,
    vnet: azurerm.virtualNetwork.VirtualNetwork,
    alias: string,
    addressPrefixes: string[]
  ) {
    return new azurerm.subnet.Subnet(this, `${alias}-subnet`, {
      name: `${alias}-subnet`,
      resourceGroupName: resourceGroup.name,
      virtualNetworkName: vnet.name,
      addressPrefixes: addressPrefixes,
    });
  }

  createNsg(resourceGroup: azurerm.resourceGroup.ResourceGroup) {
    return new azurerm.networkSecurityGroup.NetworkSecurityGroup(this, "nsg", {
      name: "nsg",
      location: DEFAULT_LOCATION,
      resourceGroupName: resourceGroup.name,
    });
  }
}
