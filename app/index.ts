import dotenv from "dotenv";
import express from "express";
import { connectToMySQL } from "./lib/mysql";
import { connectToPostgresql } from "./lib/postgresql";
import { connectToRedis } from "./lib/redis";

dotenv.config();

const app = express();

app.get("/", async function (req, res) {
  const [mysqlResponse, postgresqlResponse, redisResponse] = await Promise.all([
    connectToMySQL(),
    connectToPostgresql(),
    connectToRedis(),
  ]);
  const response = {
    mysql: mysqlResponse,
    postgresql: postgresqlResponse,
    redis: redisResponse,
  };
  res.send(response);
});

app.listen(3000);
