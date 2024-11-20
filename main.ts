import { App } from "cdktf";
import * as dotenv from "dotenv";
import { ContainerStack } from "./stacks/container-stack";
import { NetworkStack } from "./stacks/network-stack";

dotenv.config();

const app = new App();

new NetworkStack(app, "network");
new ContainerStack(app, "container");

app.synth();
