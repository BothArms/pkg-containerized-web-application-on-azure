import * as azurerm from "@cdktf/provider-azurerm";
import { Construct } from "constructs";

export function createResourceGroup(
  scope: Construct,
  { alias, location }: { alias: string; location: string }
) {
  return new azurerm.resourceGroup.ResourceGroup(
    scope,
    `${alias}-resource-group`,
    {
      name: `${alias}-resource-group`,
      location,
    }
  );
}
