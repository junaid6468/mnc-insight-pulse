🚀 Deploying an AI-Generated Website using CI/CD and AWS
This project is about deploying an AI-generated frontend website using the DevOps practices I’ve been learning and applying over time.
The goal wasn’t just to host a website — it was to automate the entire lifecycle:

Provision infrastructure
Build the application
Deploy automatically
Secure the environment
Remove manual steps
Everything from infrastructure creation to production deployment is automated.

💡 Why This Project?
I wanted to move beyond “I built a website” to:
“I built the system that deploys the website.”
Instead of manually launching EC2 instances and copying files over SSH, I implemented:

Infrastructure as Code
CI/CD automation
Secure cloud configuration
Production-ready deployment workflow
This project reflects my hands-on DevOps learning journey.

🏗 Architecture Overview

GitHub
→ Jenkins Pipeline
→ CloudFormation (Infrastructure Provisioning)
→ AWS EC2
→ Production Build (dist/)
→ rsync Deployment
→ Nginx
→ Live Website

The pipeline handles everything from pulling code to making the application live.

Infrastructure as Code
Infrastructure is defined in prod_server.yml using AWS CloudFormation.

The template automatically provisions:

EC2 instance (t2.micro)
Security Group
SSH restricted to my IP only
HTTP access for the web app
Dynamic AMI resolution
Public IP output
Instead of manually configuring servers, the environment can be recreated at any time using the template.
This ensures consistency and repeatability.

🔁 CI/CD Pipeline

The Jenkins pipeline has three main stages:

1️⃣ Checkout
Pull latest code from GitHub.

2️⃣ Build
Install dependencies using npm ci
Generate optimized production build using npm run build
Create the dist/ folder as the deployment artifact

3️⃣ Deploy

Use rsync over SSH
Transfer only changed files
Automatically remove outdated files
Restart Nginx
No manual login. No manual file copy. No manual restarts.

⚡ Why rsync?

Instead of using SCP, I chose rsync because:
It transfers only changed files
It supports incremental updates
It automatically cleans removed files
It’s closer to real production deployment practices
This significantly reduces deployment time.

🔐 Security Considerations

Security was intentionally designed:
SSH restricted to my public IP (/32)
No open SSH to the world
Private key stored securely in Jenkins Credentials
No secrets committed to GitHub
Minimal exposed ports
The deployment is automated without sacrificing security.

🌍 Result

Once the pipeline runs successfully, the application is immediately accessible via:
http://<EC2_PUBLIC_IP>
The entire process is automated end-to-end.

🧠 What This Project Demonstrates

This project reflects practical experience in:
Infrastructure as Code (CloudFormation)
Jenkins Pipeline design
AWS EC2 provisioning
Linux server configuration
Nginx setup
Secure SSH configuration
Production deployment workflow

CI/CD automation
It’s not just about deploying a website — it’s about building the automation around it.

🔮 Future Improvements

I plan to extend this project by:
Migrating deployment to Docker
Adding GitHub webhook triggers
Implementing Auto Scaling + Load Balancer
Adding HTTPS (ACM / Let’s Encrypt)
Exploring Blue-Green deployment strategy
Integrating monitoring

👨‍💻 About Me

This project represents my practical learning and experimentation with DevOps tools and cloud infrastructure.
I built this to strengthen my understanding of:
Automation
Cloud deployment
Security best practices
Real-world DevOps workflows

Results: 
<img width="1710" height="993" alt="jenkins_pipeline" src="https://github.com/user-attachments/assets/c1f94301-91c3-45da-be1b-ffe592f0bebf" />


<img width="1710" height="1107" alt="ec2_instnace" src="https://github.com/user-attachments/assets/b816e746-0e06-4f32-af11-a711215d934a" />


<img width="1710" height="300" alt="deployed_by_jenkins_on_server" src="https://github.com/user-attachments/assets/3083cd40-309a-4821-bb52-99b39ccbcb70" />


<img width="1710" height="1038" alt="project_live_on_instance" src="https://github.com/user-attachments/assets/750decfa-1385-4b08-afb2-60b8d730ccb0" />


