# Amazon Prime Video Clone

<p align="center">
  <img src="https://github.com/user-attachments/assets/62248ec2-4838-4d9f-a7be-703bc4fe3848" alt="Amazon Prime Video Clone" width="50%">
</p>

## Description
This project demonstrates deploying an Amazon Prime clone using a set of DevOps tools and practices. It showcases the automation of infrastructure provisioning, continuous integration, and deployment pipelines, along with monitoring and security practices.

## Technologies/Tools Used
- **AWS**: Used an IAM user for best practices.
- **Terraform**: Infrastructure as Code (IaC) tool to create AWS infrastructure such as EC2 instances and EKS clusters.
- **GitHub**: Source code management.
- **Jenkins**: CI/CD automation tool.
- **SonarQube**: Code quality analysis and quality gate tool.
- **NPM**: Build tool for NodeJS.
- **Aqua Trivy**: Security vulnerability scanner.
- **Docker**: Containerization tool to create images.
- **AWS ECR**: Repository to store Docker images.
- **AWS EKS**: Container management platform.
- **ArgoCD**: Continuous deployment tool.
- **Prometheus & Grafana**: Monitoring and alerting tools.

## How to Run/Install

### 1. Clone the Repository
```bash
# Replace with your repository URL
git clone https://github.com/SaiVicky321/Project_3_Full_Terraform_CICD_K8s_Clone_amazon-prime-application
```

### 2. Initialize and Apply Terraform
#### a. Main Server
```bash
cd terraform-code\main-server
terraform init
terraform apply
```
#### b. AWS EKS Server
```bash
cd terraform-code\eks-server
terraform init
terraform apply
```

### 3. Access Jenkins and SonarQube
After applying Terraform for the main server, you'll have access to Jenkins and SonarQube.

### 4. Configure SonarQube
1. Login to SonarQube (`admin`/`admin`).
2. Update the password.
3. Go to **Administration > Webhooks** and create a webhook:
   - **Name**: `sonarqube-webhook`
   - **URL**: `<ip_of_jenkins>:8080/sonarqube-webhook`
4. Generate a token:
   - **Security > Users > Tokens**
   - Create a token named `sonar-token` and save it.

### 5. Configure Jenkins
#### a. Login to Jenkins
Check the Terraform console for the password or Use the cat command to retrieve the password and set up the administrator account.
#### b. Add Credentials
1. **SonarQube Token**
   - Type: Secret text
   - Value: `sonar-token`
2. **AWS Access Key and Secret Key**
   - Type: Secret text
   - Values: IAM user credentials

#### c. Install Plugins
Install the following plugins from **Manage Jenkins > Plugins**:
- SonarQube Scanner
- NodeJS
- Eclipse Temurin installer
- Docker-related plugins
- Prometheus metrics

#### d. Configure Jenkins Tools
Add the following tools:
- **JDK**: Use Eclipse Temurin installer.
- **SonarQube Scanner**: Install from Maven Central.
- **NodeJS**: Install from NodeJS.org.
- **Docker**: Install from Docker.com.

### 6. Run the Pipeline
1. Ensure the AWS EKS server is active.
2. Click **Build**, then immediately cancel it (to display "Build with Parameters").
3. Set the parameters and start the build.
4. Retrieve the URLs for ArgoCD, Prometheus, and Grafana from the Jenkins console.

## Pipeline Overview
The CI/CD pipeline includes 14 stages:
1. **Git Checkout**: Clones the source code from GitHub.
2. **SonarQube Analysis**: Performs static code analysis.
3. **Quality Gate**: Ensures code quality standards.
4. **Install NPM Dependencies**: Installs NodeJS packages.
5. **Trivy Security Scan**: Scans the project for vulnerabilities.
6. **Docker Build**: Builds a Docker image for the project.
7. **AWS ECR Repository**: Creates an empty ECR repository.
8. **AWS ECR Image Tagging**: Tags Docker images.
9. **Push to AWS ECR**: Pushes the Docker image to ECR.
10. **Image Cleanup**: Deletes images from Jenkins to save space.
11. **AWS EKS Configure**: Sets up kubeconfig for EKS.
12. **Prometheus and Grafana**: Installs monitoring tools using Helm.
13. **ArgoCD**: Installs ArgoCD.
14. **URLs**: Retrieves URLs for ArgoCD, Prometheus, and Grafana.

### 7. Configure ArgoCD
1. Login to ArgoCD.
2. Create a new application:
   - **Name**: `Amazon-Prime-Video`
   - **Project**: `default`
   - **Source**: GitHub URL with Kubernetes manifests.
   - **Path**: Kubernetes manifests folder path.
   - **Destination**: Default cluster URL and namespace.

### 8. Configure Prometheus and Grafana
1. Open Grafana using the URL from Jenkins.
2. Login with the credentials from Jenkins.
3. Import a dashboard (ID: 1860 for Node Exporter Full).
4. Set Prometheus as the data source.

### 9. Destroy Terraform
#### a. Main Server
```bash
cd terraform/main-server
terraform destroy
```
#### b. AWS EKS Server
```bash
cd terraform/eks-server
terraform destroy
```

## Notes
- Make sure all required tools are installed locally before running.
- Monitor the pipeline logs for any errors.
- Ensure secure handling of credentials.
