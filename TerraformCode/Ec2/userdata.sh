#!/bin/bash
sudo dnf  install unzip -y
      "curl 'https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip' -o 'awscliv2.zip'",
      "unzip awscliv2.zip",
      "sudo ./aws/install"

echo "===== Updating System ====="
sudo dnf  update -y
sudo dnf  install -y ca-certificates curl gnupg lsb-release

# ------------------------------
# Install Docker on Ubuntu
# ------------------------------
echo "===== Installing Docker ====="

sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo tee /etc/apt/keyrings/docker.asc > /dev/null
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
  https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo dnf  update -y
sudo dnf  install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo usermod -aG docker ubuntu

dnf install docker

sudo systemctl enable docker
sudo systemctl start docker

docker --version

# ------------------------------
# Fix memory requirements for SonarQube
# ------------------------------
echo "===== Applying SonarQube Kernel Settings ====="

sudo sysctl -w vm.max_map_count=524288
sudo sysctl -w fs.file-max=131072

echo "vm.max_map_count=524288" | sudo tee -a /etc/sysctl.conf
echo "fs.file-max=131072" | sudo tee -a /etc/sysctl.conf

# Install & Run SonarQube
# ------------------------------
echo "===== Starting SonarQube Container ====="

docker run -d --name sonar \
  -p 9000:9000 \
  -e SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true \
  sonarqube:lts-community

echo "===== SonarQube Installation Complete ====="


echo "===== Installing Java 17 (Required for Jenkins) ====="
sudo dnf install -y java-17-amazon-corretto java-17-amazon-corretto-devel

echo "===== Adding Jenkins Repository ====="
sudo wget -O /etc/pki/rpm-gpg/jenkins.io.key https://pkg.jenkins.io/redhat-stable/jenkins.io.key
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key

sudo tee /etc/yum.repos.d/jenkins.repo > /dev/null <<EOF
[jenkins]
name=Jenkins-stable
baseurl=https://pkg.jenkins.io/redhat-stable
gpgcheck=1
gpgkey=https://pkg.jenkins.io/redhat-stable/jenkins.io.key
EOF

echo "===== Installing Jenkins ====="
sudo dnf install -y jenkins

echo "===== Starting Jenkins ====="
sudo systemctl enable jenkins
sudo systemctl start Jenkins



echo "Installing kubectl..."

curl -o kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.30.4/2024-09-11/bin/linux/amd64/kubectl

chmod +x kubectl
sudo mv kubectl /usr/local/bin/kubectl

kubectl version --client

wget https://get.helm.sh/helm-v3.16.1-linux-amd64.tar.gz
tar -zxvf helm-v3.16.1-linux-amd64.tar.gz
sudo mv linux-amd64/helm /usr/local/bin/helm
helm version


VERSION=$(curl -sL https://api.github.com/repos/argoproj/argo-cd/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')
curl -sSL -o argocd-linux-amd64 \
  https://github.com/argoproj/argo-cd/releases/download/v${VERSION}/argocd-linux-amd64

sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64

argocd version --client

