import { Pool } from "pg";
import { ConnectResponse } from "./types";

export async function connectToPostgresql(): Promise<ConnectResponse> {
  const connectionData = {
    user: process.env.POSTGRES_USER,
    password: process.env.POSTGRES_PASSWORD,
    host: process.env.POSTGRES_HOST,
    port: parseInt(process.env.POSTGRES_PORT || "5432"),
    database: process.env.POSTGRES_DATABASE,
    ssl: {},
  };
  try {
    const pool = new Pool(connectionData);
    await pool.connect();
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
