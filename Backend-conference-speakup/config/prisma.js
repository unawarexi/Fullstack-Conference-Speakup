import pkg from "@prisma/client";
const { PrismaClient } = pkg;

import { PrismaPg } from "@prisma/adapter-pg";
import pg from "pg";

const globalForPrisma = globalThis;

const createPrismaClient = () => {
  if (!process.env.DATABASE_URL) {
    throw new Error("DATABASE_URL is not defined in environment variables");
  }

  const pool = new pg.Pool({
    connectionString: process.env.DATABASE_URL,
    max: 20,
    idleTimeoutMillis: 30000,
    connectionTimeoutMillis: 10000,
  });

  const adapter = new PrismaPg(pool);

  return new PrismaClient({
    adapter,
    log:
      process.env.NODE_ENV === "development"
        ? ["query", "info", "warn", "error"]
        : ["error"],
  });
};

export const prisma = globalForPrisma.prisma ?? createPrismaClient();

if (process.env.NODE_ENV !== "production") {
  globalForPrisma.prisma = prisma;
}

export const disconnectPrisma = async () => {
  try {
    await prisma.$disconnect();
    console.log("[Prisma] Disconnected successfully");
  } catch (e) {
    console.error("[Prisma] Disconnect error:", e);
  }
};