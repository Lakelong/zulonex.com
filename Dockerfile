FROM node:22-alpine AS build

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci

COPY . .

ARG PUBLIC_BUSINESS_LOGIN_URL=https://boss.zulonex.com
ENV PUBLIC_BUSINESS_LOGIN_URL=${PUBLIC_BUSINESS_LOGIN_URL}

RUN npm run build

FROM node:22-alpine AS runtime

WORKDIR /app

ENV NODE_ENV=production
ENV HOST=0.0.0.0
ENV PORT=8080
ENV LEADS_FILE=/app/data/leads.jsonl

COPY package.json package-lock.json ./
RUN npm ci --omit=dev && npm cache clean --force

COPY --from=build /app/dist ./dist

RUN mkdir -p /app/data

EXPOSE 8080

CMD ["npm", "start"]
