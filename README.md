DevOps Application Deployment Projec
tSystem Architecture & Deployment Documentation - This repository houses the production-ready infrastructure deployment pipeline for the containerized React Frontend Application. The complete system utilizes a multi-branch branching strategy, an automated Jenkins CI/CD Pipeline, split Docker Hub registries, an AWS EC2 cloud compute environment, and an integrated Prometheus/Grafana analytics suite.

Architectural Topology Overviewtext  [ GitHub Repository ]
     /             \
 ( dev )         ( main )

    |               |
 [Jenkins Branch Automation Scanner] <--- (docker-hub-creds PAT)

    |               |
 ( dev-build )   ( prod-build )

    |               |
 [ Docker Hub ]  [ Docker Hub ]
 ( Public Dev )  ( Private Prod )
    \               /
   [ AWS EC2 t3.small Host VM ] 🚀 Port 80 (React App via Nginx)
         |
   [ Prometheus Time-Series DB ] ➔ [ Grafana Visualization Dashboard ] (Port 3000)
📦 Infrastructure Stack Configuration Components1. Containerization Layer (Dockerfile)To achieve peak delivery speeds and lightweight footprints on cloud nodes, the configuration maps pre-compiled production web assets natively into a streamlined, high-performance Nginx Alpine instance.dockerfile# Serve pre-compiled React build assets via production Nginx engine
FROM nginx:alpine
COPY build/ /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
Use code with caution.2. Multi-Branch Jenkins Pipeline Strategy (Jenkinsfile)The declarative deployment model relies on a Jenkins Multibranch Pipeline job that dynamically hooks the branch context name parameters to isolate deployment artifacts safely.groovypipeline {
    agent any
    environment {
        DOCKER_CREDS = credentials('docker-hub-creds') 
        DOCKER_USER  = 'namodharani'
        DEV_REPO     = 'devops-build-dev'
        PROD_REPO    = 'devops-build-prod'
        IMAGE_TAG    = "${env.BUILD_NUMBER}"
    }
    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }
        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${DOCKER_USER}/${DEV_REPO}:${IMAGE_TAG} -t ${DOCKER_USER}/${PROD_REPO}:${IMAGE_TAG} ."
            }
        }
        stage('Docker Hub Routing & Push') {
            steps {
                sh "echo \$DOCKER_CREDS_PSW | docker login -u \$DOCKER_CREDS_USR --password-stdin"
                script {
                    if (env.BRANCH_NAME == 'dev') {
                        echo "🌿 Branch 'dev' matched: Uploading to Public Development Repository..."
                        sh "docker push ${DOCKER_USER}/${DEV_REPO}:${IMAGE_TAG}"
                    } else if (env.BRANCH_NAME == 'main') {
                        echo "🚀 Branch 'main' matched: Uploading to Private Production Repository..."
                        sh "docker push ${DOCKER_USER}/${PROD_REPO}:${IMAGE_TAG}"
                    }
                }
            }
        }
    }
    post {
        always {
            sh "docker logout"
        }
    }
}

Cloud Network Firewall Specifications (AWS Security Group)Traffic entering the AWS EC2 t3.small instance is bounded using tight ingress security controls to isolate management access while maintaining high-availability web delivery:Target ProtocolNetwork PortConfigured SourceSecurity Operational PurposeHTTP800.0.0.0/0Public production ingress path routing web access to the React store container.Custom TCP30000.0.0.0/0Public endpoint visibility access into the Grafana monitoring dashboards panel views.Custom TCP9090My IP OnlySecure local workspace restriction clamping the raw Prometheus query portal from open snooping.SSH22My IP OnlySecure terminal channel layout completely blocked away from outside dictionary-attack vectors.

System Observation & Telemetry Dashboard MetricsReal-time monitoring maps the infrastructure resource health data streams accurately using standard open-source tools:Node Exporter: Captures kernel architecture statistics and hardware load levels directly off the base EC2 OS.Prometheus Database: Polls metrics sequentially on a 15-second configuration tracking step interval pattern.Grafana Visualization (Dashboard ID: 1860): Translates complex queries into visual panels monitoring CPU usage thresholds, available RAM system memory allocations, storage volume loads, and ingress network traffic throughput speeds.

Service Recovery & Reboot Persistence RulesAll containers on the EC2 node run with hard native service recovery bindings. If the server experiences a maintenance cycle, power interruption, or execution failure, the services resume automatically:System Core Level: docker.service and containered.service are bound using standard systemctl enable hooks.Container Instance Level: All instances (my-live-react-app, node-exporter, prometheus, and grafana) run with explicit --restart always enforcement parameters.

Verification Execution Reference CheatsheetLocal Branch Sync Workflowbashgit checkout dev
git add .
git commit -m "feat: complete deployment stack elements"
git push origin dev
git checkout main
git merge dev
git push origin main
git checkout dev
Use code with caution.Manual Engine Compilation Tracebashsudo docker build -t react-app:latest .
sudo docker run -d --name my-live-react-app --restart always -p 80:80 react-app:latest

Monitoring Component Launch Sequencebashsudo docker network create monitoring-network

sudo docker run -d --name=node-exporter --network=monitoring-network --restart=always -v "/proc:/host/proc:ro" -v "/sys:/host/sys:ro" -v "/:/rootfs:ro" prom/node-exporter:latest --path.procfs=/host/proc --path.sysfs=/host/sys --path.rootfs=/rootfs

sudo docker run -d --name=prometheus --network=monitoring-network --restart=always -p 9090:9090 -v ~/prometheus-config/prometheus.yml:/etc/prometheus/prometheus.yml prom/prometheus:latest

sudo docker run -d --name=grafana --network=monitoring-network --restart=always 
