# StudentAI
## docker build command
```sh
docker build -t userdetails:latest .
docker build -t auth:latest .
docker build -t testfe:latest .
```
## docker-compose 
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
Note - in case you are facing running any specific container use below-mentioned troubleshooting steps

#Rebuild the Docker Images
#Run the following command to rebuild the Docker images:
docker-compose build user-service
# Debug the Build Context
docker build --no-cache -t user-service ./user-service
#Inspect the Container
docker-compose up -d user-service
docker exec -it user-service sh
ls /usr/src/app
# Check health status specifically
docker inspect --format='{{json .State.Health}}' user-service
#Clean Up Docker Cache
docker-compose down --rmi all --volumes --remove-orphans 
docker-compose build --no-cache
docker-compose up
```

### Authentication Service Structure

The `/auth` directory contains a Node.js authentication microservice with the following components:

1. **Main Application** (index.js): Express server with CORS, middleware, and route definitions
2. **Controllers**: Handle business logic for users, organizations, and health checks
3. **Models**: MongoDB data models for authentication
4. **Utils**: JWT token handling, database connection, and Swagger configuration
5. **Routes**: API endpoint definitions

#### 3. **How Variables Are Used**

- **JWT_TOKEN**: Used for signing and verifying JWT tokens (jwtToken.js)
- **MONGO_URI**: Database connection string (conn.js)
- **AWS credentials**: Used for SES email service (user.controller.js)
- **PORT**: Server port (referenced in index.js)


## How to Create AWS Credentials

### Step 1: Create an AWS Account
1. Go to [aws.amazon.com](https://aws.amazon.com)
2. Click "Create an AWS Account"
3. Follow the registration process

### Step 2: Create an IAM User for Programmatic Access

1. **Access IAM Console**:
   - Sign in to AWS Console
   - Search for "IAM" and open the service

2. **Create User**:
   - Click "Users" → "Create user"
   - Username: `studentai-auth-service`
   - Select "Programmatic access"

3. **Set Permissions**:
   - Attach policies directly
   - Add these policies:
     - `AmazonSESFullAccess` (for email sending)
     - Or create a custom policy with minimal SES permissions:
   ```json
   {
     "Version": "2012-10-17",
     "Statement": [
       {
         "Effect": "Allow",
         "Action": [
           "ses:SendEmail",
           "ses:SendRawEmail"
         ],
         "Resource": "*"
       }
     ]
   }
   ```

4. **Download Credentials**:
   - After creation, download the CSV file with:
     - Access Key ID
     - Secret Access Key

### Step 3: Configure AWS SES (Simple Email Service)

1. **Open SES Console**:
   - Search for "SES" in AWS Console
   - Select your region (ap-south-1 for India)

2. **Verify Email Address**:
   - Go to "Verified identities"
   - Click "Create identity"
   - Choose "Email address"
   - Enter your sending email address
   - Verify through the email you receive

3. **Request Production Access** (if needed):
   - By default, SES is in sandbox mode
   - Can only send to verified emails
   - Request production access for unrestricted sending

### Step 4: Update Your .env File

Replace your current .env with:

```properties
MONGO_URI=mongodb+srv://dbuser:tUmusUV3MteObgt179ou@cluster0.i0pov.mongodb.net/auth?retryWrites=true&w=majority
JWT_TOKEN=your_strong_jwt_secret_key_here_min_32_chars
JWT_EXPIRATION=1h
AWS_KEY_ID=AKIA...your_access_key_id
AWS_SECRET_KEY=your_secret_access_key_here
AWS_REGION=ap-south-1
PORT=3001
SENDING_EMAIL_THROUGH=your-verified-email@domain.com
```

### Step 5: Generate a Strong JWT Secret

Run this command to generate a secure JWT secret: 

node -e "console.log(require('crypto').randomBytes(64).toString('hex'))"

PS C:\Devops\Capstone\StudentAI\backend\auth> node index.js
MONGO_URI: mongodb+srv://dbuser:tUmusUV3MteObgt179ou@cluster0.i0pov.mongodb.net/studentai?retryWrites=true&w=majority
Auth Service running at port 3001

http://localhost:3001/auth/health
http://localhost:3001/auth/organization
http://localhost:3001/auth/user

http://localhost:3002/api/basicresume
http://localhost:3002/api/organization
http://localhost:3002/api/org/userDetails
