# Install any updates
sudo apt update && sudo apt dist-upgrade && sudo apt upgrade -y

#Install docker
# Source https://docs.docker.com/engine/install/ubuntu/
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# NOTE: The VM build adds a user that you are logged in with now
# Add the current user to the docker group
sudo usermod -aG docker $USER
sudo reboot

# Enable Docker to start on boot
sudo systemctl enable docker.service
sudo systemctl enable containerd.service

###########################
# Install Cloudflared
# Source:
###########################
docker run -d --name cloudflared --restart unless-stopped cloudflare/cloudflared:latest tunnel --no-autoupdate run --token eyJhIjoiNWZhOGY4YjZjYzhkNjIyYWIyMDM5OGU4M2E3M2U4NGUiLCJ0IjoiMDhkNjFmZWItZjMxNy00ZWZiLWJjYmMtOWNiMmQxZDQyZjNiIiwicyI6IlpUYzRNVEl6Wm1ZdE9ESmpNQzAwT1dNeExXRmtNMll0Wm1VM05ETXlNekJrTURBMiJ9

###########################
# Install Portainer
# Source: https://docs.portainer.io/start/install-ce/server/docker/linux
###########################

docker volume create portainer_data
docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:lts

###########################
# Install the N8N Ai starter kit
# Source: https://github.com/n8n-io/self-hosted-ai-starter-kit
###########################

# Clone the Ai Starter kit repo
git clone https://github.com/n8n-io/self-hosted-ai-starter-kit.git
cd self-hosted-ai-starter-kit

# Update the .env file
POSTGRES_USER=root
POSTGRES_PASSWORD=tkW6fPXlQMcZc7SvTlC2PooEM6r
POSTGRES_DB=n8n

WEBHOOK_URL=https://n8n.powershellbot.com/

N8N_ENCRYPTION_KEY=tkW6fPXlQMcZc7SvTlC2PooEM6r
N8N_USER_MANAGEMENT_JWT_SECRET=gnTNifabXV5dAL3FzZt1g6frSKB
N8N_DEFAULT_BINARY_DATA_MODE=filesystem

# Start the docker containers
docker compose --profile cpu up


