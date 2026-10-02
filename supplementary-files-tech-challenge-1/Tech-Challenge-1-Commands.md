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

# Generic seige type of load test

for i in {1..250}
do
  (
    for j in {1..200}
    do
      curl -s \
      http://tech-challenge-1-alb-486707836.us-east-1.elb.amazonaws.com/ > /dev/null
    done
  ) &
done
wait



# Trust relationship updated for July 2026

{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::177989593957:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com",
          "token.actions.githubusercontent.com:sub": "repo:emvaugh2@131804156/Tech-Challenge-1@1398836559:ref:refs/heads/gitops"
        }
      }
    }
  ]
}
