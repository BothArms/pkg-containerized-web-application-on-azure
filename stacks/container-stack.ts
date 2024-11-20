import * as azurerm from "@cdktf/provider-azurerm";
import * as cdktf from "cdktf";
import { Construct } from "constructs";
import { DEFAULT_LOCATION } from "../const";
import { useAzureProvider } from "./lib/azure-provider";
import { createResourceGroup } from "./lib/resource-group";

export class ContainerStack extends cdktf.TerraformStack {
  constructor(scope: Construct, id: string) {
    super(scope, id);

    useAzureProvider(this);

    const resourceGroup = createResourceGroup(this, {
      alias: "container",
      location: DEFAULT_LOCATION,
    });

    new azurerm.resourceProviderRegistration.ResourceProviderRegistration(
      this,
      "app-registration",
      {
        name: "Microsoft.App",
      }
    );

    const logAnalyticsWorkspace =
      new azurerm.logAnalyticsWorkspace.LogAnalyticsWorkspace(
        this,
        "container-law",
        {
          name: "container-law",
          location: resourceGroup.location,
          resourceGroupName: resourceGroup.name,
          sku: "PerGB2018",
          retentionInDays: 30,
        }
      );

    const containerAppEnvironment =
      new azurerm.containerAppEnvironment.ContainerAppEnvironment(
        this,
        "container-env",
        {
          name: "container-environment",
          location: resourceGroup.location,
          resourceGroupName: resourceGroup.name,
          logAnalyticsWorkspaceId: logAnalyticsWorkspace.id,
        }
      );

    new azurerm.containerApp.ContainerApp(this, "app", {
      name: "container-app",
      containerAppEnvironmentId: containerAppEnvironment.id,
      resourceGroupName: resourceGroup.name,
      revisionMode: "Multiple",

      template: {
        container: [
          {
            name: "first-container",
            image:
              "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest",
            cpu: 0.5,
            memory: "1Gi",
          },
        ],
      },

      ingress: {
        externalEnabled: true,
        targetPort: 80,
        trafficWeight: [
          {
            latestRevision: true,
            percentage: 100,
          },
        ],
      },
    });
  }
}
