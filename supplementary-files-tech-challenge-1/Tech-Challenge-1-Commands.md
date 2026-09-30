Commands

sudo dnf install docker -y
sudo dnf install git -y
git clone https://github.com/TayoLusi19/devops-code-challenge1.git

Make sure you start and enable Docker. 

# Must be in the same folder as the front and backend
docker build -t backend:v1 .
docker build -t frontend:v1 .

docker run -d --name backend-app -p 8080:8080 backend:v1
docker run -d --name frontend-app -p 3000:3000 frontend:v1

Make sure you change your CORS origin, success message, and URL points before you build your images. Remember, backticks for the Success message. 

{successMessage ? `SUCCESS: ${successMessage}` : null}

# Frontend Dockerfile
FROM node:16
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build
RUN npm install -g serve
EXPOSE 3000
CMD ["serve", "-s", "build"]

# Backend Dockerfile
FROM node:16
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
EXPOSE 8080
CMD ["npm", "start"]

