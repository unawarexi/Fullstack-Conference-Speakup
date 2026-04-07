# ============================================================================
# SpeakUp — Dockerfile (Node.js Runtime)
# ============================================================================

# --------------------------------------------------------------------------
# Stage 1: Install dependencies
# --------------------------------------------------------------------------
FROM node:22-alpine AS deps

WORKDIR /app

COPY package.json package-lock.json* ./
COPY prisma ./prisma/

RUN npm ci --omit=dev

# --------------------------------------------------------------------------
# Stage 2: Generate Prisma Client
# --------------------------------------------------------------------------
FROM node:22-alpine AS build

WORKDIR /app

COPY package.json package-lock.json* ./
COPY prisma ./prisma/

RUN npm ci
RUN npx prisma generate

# --------------------------------------------------------------------------
# Stage 3: Production image
# --------------------------------------------------------------------------
FROM node:22-alpine AS production

WORKDIR /app

# Security: run as non-root user
RUN addgroup --system speakup && \
    adduser --system --ingroup speakup speakup

# Copy production dependencies
COPY --from=deps /app/node_modules ./node_modules

# Copy generated Prisma client
COPY --from=build /app/node_modules/.prisma ./node_modules/.prisma
COPY --from=build /app/node_modules/@prisma ./node_modules/@prisma

# Copy application code
COPY . .

# Remove unnecessary files
RUN rm -rf .git .github terraform k8s nginx .env* *.md

# Set ownership
RUN chown -R speakup:speakup /app

USER speakup

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=15s --retries=3 \
  CMD node -e "fetch('http://localhost:5000/health').then(r => r.ok ? process.exit(0) : process.exit(1)).catch(() => process.exit(1))"

EXPOSE 5000

ENV NODE_ENV=production
ENV PORT=5000

CMD ["node", "index.js"]