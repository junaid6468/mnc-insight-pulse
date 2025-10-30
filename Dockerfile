# ---------- Stage 1: Build ----------
FROM node:18 AS build
WORKDIR /app

# Copy package files first for caching
COPY package*.json ./
RUN npm ci

# Copy all source code and build
COPY . .
RUN npm run build

# ---------- Stage 2: Serve with Nginx ----------
FROM nginx:alpine

# Remove default Nginx website and copy your built site
RUN rm -rf /usr/share/nginx/html/*
COPY --from=build /app/dist /usr/share/nginx/html

# Expose the default Nginx port
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]

