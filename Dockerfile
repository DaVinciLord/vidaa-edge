# Stage 1: Build de l'application Angular
FROM node:20-alpine AS builder

WORKDIR /app

# Copier les fichiers de configuration des dépendances
COPY package*.json ./
COPY nx.json ./
COPY project.json ./
COPY tsconfig*.json ./
COPY jest.config.ts ./
COPY jest.preset.js ./
COPY tailwind.config.js ./
COPY eslint.config.cjs ./

# Installer les dépendances
RUN npm ci

# Copier le code source
COPY . .

# Builder l'application pour la production
RUN npm run build:prod

# Stage 2: Image de production
FROM node:20-alpine AS production

WORKDIR /app

# Installer les dépendances de production
COPY package*.json ./
RUN npm ci --omit=dev && npm cache clean --force

# Copier le serveur API
COPY server/ ./server/

# Copier les fichiers buildés depuis le stage builder
COPY --from=builder /app/dist/vidaa-edge/browser ./dist/vidaa-edge/browser

# Créer le dossier scan-data pour les sessions
RUN mkdir -p scan-data

# Exposer le port
EXPOSE 3000

# Variables d'environnement
ENV NODE_ENV=production
ENV API_PORT=3000

# Démarrer le serveur
CMD ["node", "server/api-server.js"]
