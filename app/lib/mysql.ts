import mysql from "mysql2/promise";
import { ConnectResponse } from "./types";

export async function connectToMySQL(): Promise<ConnectResponse> {
  const connectionData = {
    host: process.env.MYSQL_HOST,
    user: process.env.MYSQL_USER,
    password: process.env.MYSQL_PASSWORD,
    database: process.env.MYSQL_DATABASE,
    port: parseInt(process.env.MYSQL_PORT || "3306"),
    ssl: {},
  };
  try {
    const connection = await mysql.createConnection(connectionData);
    await connection.connect();
  } catch (error) {
    console.error("Error connecting to MySQL:", error);
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
