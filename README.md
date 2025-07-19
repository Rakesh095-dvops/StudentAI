# StudentAI

## Helpful Docker Compose Commands
### docker build command
```sh
docker build -t userdetails:latest .
docker build -t auth:latest .
docker build -t testfe:latest .
```
### docker-compose 
```sh
# Build and start all services
docker-compose up -d
docker-compose up -d --build
# Verify all containers are running
docker-compose ps

# View logs for all services
docker-compose logs -f

# Stop all services
docker-compose down

#Rebuild the Docker Images
#Run the following command to rebuild the Docker images:
docker-compose build testfe
# Debug the Build Context
docker build --no-cache -t testfe ./testfe
#Inspect the Container
docker-compose up -d testfe
docker exec -it testfe sh
ls /usr/src/app
# Check health status specifically
docker inspect --format='{{json .State.Health}}' testfe
#Clean Up Docker Cache
docker-compose down --rmi all --volumes --remove-orphans 
docker-compose build --no-cache
docker-compose up
```


## Backend API

### Authentication

- http://localhost:3001/auth/health
- http://localhost:3001/auth/organization
- http://localhost:3001/auth/user

#### Environment Variables

```sh
MONGO_URI=
JWT_TOKEN=
AWS_KEY_ID=
AWS_SECRET_KEY=
AWS_REGION=ap-south-1
SENDING_EMAIL_THROUGH=
PORT=3001
```

### userDetails API 

- http://localhost:3002/api/basicresume
- http://localhost:3002/api/organization
- http://localhost:3002/api/org/userDetails

#### Environment Variables

```sh
MONGO_URI=
JWT_TOKEN=
AWS_KEY_ID=
AWS_SECRET_KEY=
AWS_REGION=ap-south-1
SENDING_EMAIL_THROUGH=
AWS_BUCKET=studentai-bucket
PORT=3002
OPENAI_API_KEY=
OPENAI_ORG_ID=
OPENAI_API_BASE=https://api.openai.com/v1
```

### Notes: 
- Create a  OPENAPI key and get details using ***[https://platform.openai.com/](https://platform.openai.com/)***
- Create `AWS_SECRET_KEY` and `AWS_KEY_ID` using aws profile use own or create new use using IAM to create application specific user and create relevant keys. 
- For `SENDING_EMAIL_THROUGH` create earlier IAM custom user create email or for SES service user account own Email
- create s3 bucket `AWS_BUCKET`
- Create `JWT_TOKEN` for the application 
   
   ```bash
   node -e "console.log(require('crypto').randomBytes(64).toString('hex'))"
   ```

## Frontend 

- http://localhost:80
