pipeline {
    agent any

//Allows users to specify or override the name of the AWS ECR repository where the Docker image will be stored.
//Enables the user to define the AWS account ID for identifying and accessing resources like ECR and EKS.
//Allows users to provide the name of the EKS cluster to which the application will be deployed.
    parameters {
        string(name: 'ECR_REPO_NAME', defaultValue: 'amazon-prime', description: 'Enter repository name')
        string(name: 'AWS_ACCOUNT_ID', defaultValue: '9876543210', description: 'Enter AWS Account ID') // Added missing quote
        string(name: 'CLUSTER_NAME', defaultValue: 'amazon-prime-cluster', description: 'Enter your EKS cluster name')
    }

//Installs the specified version of Node.js, required for building and managing dependencies in JavaScript-based applications.
//Ensures that the specified JDK (Java Development Kit) version is available for any Java-based operations in the pipeline.    
    tools {
        jdk 'JDK'
        nodejs 'NodeJS'
    }

//Sets the path to the SonarQube Scanner tool for running code quality analysis during the SonarQube stage.
//Specifies the path to the kubectl binary, which is used to interact with the Kubernetes cluster for deployments and configurations.    
    environment {
        SCANNER_HOME = tool 'SonarQube Scanner'
        KUBECTL = '/usr/local/bin/kubectl'
    }
    
    stages {
// This pulls the latest code from the specified GitHub repository, ensuring the pipeline works with the latest version of the code.
        stage('1. Code Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/SaiVicky321/Project_3_Full_Terraform_CICD_K8s_Clone_amazon-prime-application'
            }
        }

// This performs a static code analysis using SonarQube to check for code quality and security vulnerabilities.
        stage('2. SonarQube Analysis') {
            steps {
                withSonarQubeEnv ('sonar-server') {
                    sh """
                    $SCANNER_HOME/bin/sonar-scanner \
                    -Dsonar.projectName=amazon-prime \
                    -Dsonar.projectKey=amazon-prime
                    """
                }
            }
        }

// This ensures the pipeline waits for the SonarQube quality gate to pass before proceeding, optionally aborting on failure.        
        stage('3. Quality Gate') {
            steps {
                waitForQualityGate abortPipeline: false, 
                credentialsId: 'sonar-token'
            }
        }


//This installs the project dependencies from the package.json file to ensure all necessary libraries are available for the build.
        stage('4. Install npm') {
            steps {
                sh "npm install"
            }
        }

//This runs a security scan on the codebase using Trivy to identify vulnerabilities and security issues in the project's filesystem.        
        stage('5. Trivy Scan') {
            steps {
                sh "trivy fs . > trivy.txt"
            }
        }

//This builds a Docker image from the Dockerfile in the project and tags it with the repository name for later use.        
        stage('6. Build Docker Image') {
            steps {
                sh "docker build -t ${params.ECR_REPO_NAME} ."
            }
        }

//This checks if the specified ECR repository exists; if not, it creates a new one to store the Docker image.        
        stage('7. Create ECR repo') {
            steps {
                withCredentials([string(credentialsId: 'access-key', variable: 'AWS_ACCESS_KEY'), 
                                 string(credentialsId: 'secret-key', variable: 'AWS_SECRET_KEY')]) {
                    sh """
                    aws configure set aws_access_key_id $AWS_ACCESS_KEY
                    aws configure set aws_secret_access_key $AWS_SECRET_KEY
                    aws ecr describe-repositories --repository-names ${params.ECR_REPO_NAME} --region us-east-1 || \
                    aws ecr create-repository --repository-name ${params.ECR_REPO_NAME} --region us-east-1
                    """
                }
            }
        }

//This authenticates Docker to AWS ECR so the image can be pushed to the repository, then tags the image with the build number and latest tag.
        stage('8. Login to ECR & tag image') {
            steps {
                withCredentials([string(credentialsId: 'access-key', variable: 'AWS_ACCESS_KEY'), 
                                 string(credentialsId: 'secret-key', variable: 'AWS_SECRET_KEY')]) {
                    sh """
                    aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${params.AWS_ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com
                    docker tag ${params.ECR_REPO_NAME} ${params.AWS_ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com/${params.ECR_REPO_NAME}:${BUILD_NUMBER}
                    docker tag ${params.ECR_REPO_NAME} ${params.AWS_ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com/${params.ECR_REPO_NAME}:latest
                    """
                }
            }
        }

//This pushes the tagged Docker image to the ECR repository for storage and use in the deployment pipeline.        
        stage('9. Push image to ECR') {
            steps {
                withCredentials([string(credentialsId: 'access-key', variable: 'AWS_ACCESS_KEY'), 
                                 string(credentialsId: 'secret-key', variable: 'AWS_SECRET_KEY')]) {
                    sh """
                    docker push ${params.AWS_ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com/${params.ECR_REPO_NAME}:${BUILD_NUMBER}
                    docker push ${params.AWS_ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com/${params.ECR_REPO_NAME}:latest
                    """
                }
            }
        }

//This removes the local copies of Docker images to free up space after the image has been pushed to ECR.        
        stage('10. Cleanup Images') {
            steps {
                sh """
                docker rmi ${params.AWS_ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com/${params.ECR_REPO_NAME}:${BUILD_NUMBER}
                docker rmi ${params.AWS_ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com/${params.ECR_REPO_NAME}:latest
		        docker images
                """
            }
        }

//This updates the kubeconfig file to authenticate the Jenkins pipeline with the EKS cluster for deploying and managing applications.
        stage("11. Login to EKS") {
            steps {
                script {
                    withCredentials([string(credentialsId: 'access-key', variable: 'AWS_ACCESS_KEY'),
                                     string(credentialsId: 'secret-key', variable: 'AWS_SECRET_KEY')]) {
                        sh "aws eks --region us-east-1 update-kubeconfig --name ${params.CLUSTER_NAME}"
                    }
                }
            }
        }

//This installs or updates Prometheus and Grafana to monitor the EKS cluster, setting up necessary services and exposing them via LoadBalancer.
        stage("12. Configure Prometheus & Grafana") {
            steps {
                script {
                    sh """
                    helm repo add stable https://charts.helm.sh/stable || true
                    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts || true

                    # Check if namespace 'prometheus' exists
                    if kubectl get namespace prometheus > /dev/null 2>&1; then
                        helm upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack -n prometheus
                    else
                        kubectl create namespace prometheus
                        helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack -n prometheus
                    fi

                    # Expose Prometheus and Grafana via LoadBalancer
                    kubectl patch svc kube-prometheus-stack-prometheus -n prometheus -p '{"spec": {"type": "LoadBalancer"}}'
                    kubectl patch svc kube-prometheus-stack-grafana -n prometheus -p '{"spec": {"type": "LoadBalancer"}}'
                    """
                }
            }
        }

//This installs ArgoCD, a tool for continuous delivery and GitOps, and exposes the ArgoCD UI via LoadBalancer for easy access.
        stage("13. Configure ArgoCD") {
            steps {
                script {
                    sh """
                    # Install ArgoCD
                    kubectl create namespace argocd || true
                    kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

                    # Expose ArgoCD via LoadBalancer
                    kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
                    """
                }
            }
        }

//This waits for the services (ArgoCD, Prometheus, Grafana) to be provisioned and fetches their URLs and credentials for display to the user.
        stage("14. Fetch and Display URLs") {
            steps {
                script {
                    sh '''
                    # Wait for services to be provisioned
                    echo "Waiting for ArgoCD service to be ready..."
                    until kubectl get svc -n argocd argocd-server &>/dev/null; do sleep 30; done

                    echo "Waiting for Prometheus and Grafana services to be ready..."
                    until kubectl get svc -n prometheus kube-prometheus-stack-prometheus &>/dev/null; do sleep 30; done
                    until kubectl get svc -n prometheus kube-prometheus-stack-grafana &>/dev/null; do sleep 30; done

                    # Fetch and display URLs and credentials
                    argo_url=$(kubectl get svc -n argocd argocd-server -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
                    if [ -z "$argo_url" ]; then
                        argo_url=$(kubectl get svc -n argocd argocd-server -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
                    fi

                    until kubectl get secret argocd-initial-admin-secret -n argocd &>/dev/null; do
                        echo "Waiting for ArgoCD admin secret..."
                        sleep 30
                    done
                    argo_password=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 --decode)

                    prometheus_url=$(kubectl get svc -n prometheus kube-prometheus-stack-prometheus -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
                    if [ -z "$prometheus_url" ]; then
                        prometheus_url=$(kubectl get svc -n prometheus kube-prometheus-stack-prometheus -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
                    fi

                    grafana_url=$(kubectl get svc -n prometheus kube-prometheus-stack-grafana -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
                    if [ -z "$grafana_url" ]; then
                        grafana_url=$(kubectl get svc -n prometheus kube-prometheus-stack-grafana -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
                    fi

                    grafana_password=$(kubectl get secret kube-prometheus-stack-grafana -n prometheus -o jsonpath='{.data.admin-password}' | base64 --decode)

                    echo "------------------------"
                    echo "ArgoCD URL: $argo_url"
                    echo "ArgoCD User: admin"
                    echo "ArgoCD Password: $argo_password"
                    echo
                    echo "Prometheus URL: $prometheus_url:9090"
                    echo
                    echo "Grafana URL: $grafana_url"
                    echo "Grafana User: admin"
                    echo "Grafana Password: $grafana_password"
                    echo "------------------------"
                    '''
                }
            }
        }
    }
}
