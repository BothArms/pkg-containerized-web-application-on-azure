import { createClient } from "redis";
import { ConnectResponse } from "./types";

export async function connectToRedis(): Promise<ConnectResponse> {
  const connectionData = {
    url: `redis://${process.env.REDIS_HOST}:${process.env.REDIS_PORT}`,
    password: process.env.REDIS_PASSWORD,
  };
  try {
    const client = createClient(connectionData);
    await client.connect();
  } catch (error) {
    return {
      success: false,
      data: connectionData,
      error: error,
    };
  }

  return {
    success: true,
    data: connectionData,
    error: null,
  };
}
