import * as azurerm from "@cdktf/provider-azurerm";
import { Construct } from "constructs";

export function useAzureProvider(scope: Construct) {
  new azurerm.provider.AzurermProvider(scope, "azurerm", {
    features: [{}],
    subscriptionId: process.env.AZURE_SUBSCRIPTION_ID,
  });
}
