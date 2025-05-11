#!/bin/bash

GREEN='\033[1;32m'
CYAN='\033[0;36m'
RESET='\033[0m'

clear
echo -e "${CYAN}"
echo "██    ██  ███████ ██   ██  ██   ██"
echo "██    ██  ██      ██   ██  ██  ██ "
echo "██    ██  █████   ██   ██  █████  "
echo "██    ██  ██      ██   ██  ██  ██ "
echo "████████  ██      ███████  ██   ██"
echo -e "${RESET}"
echo -e "${GREEN}Script hazırlanmıştır: Ufuk (@UfukDegen) tarafından 🌐${RESET}"
sleep 2

echo -e "${CYAN}📦 Gerekli paketler yükleniyor...${RESET}"
sudo apt update && sudo apt install -y \
  git curl wget build-essential cmake pkg-config libssl-dev \
  ca-certificates gnupg lsb-release unzip apt-transport-https ufw

# Node.js kurulumu
echo -e "${CYAN}🧩 Node.js (20.17.0) kuruluyor...${RESET}"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
export NVM_DIR="$HOME/.nvm" && source "$NVM_DIR/nvm.sh"
nvm install 20.17.0 && nvm use 20.17.0

# Docker kurulumu
echo -e "${CYAN}🐳 Docker kuruluyor...${RESET}"
sudo install -m 0755 -d /etc/apt/keyrings
sudo rm -f /etc/apt/keyrings/docker.gpg
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update && sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo usermod -aG docker $USER && newgrp docker

# UFW port izinleri
echo -e "${CYAN}🛡️ Gerekli portlar açılıyor...${RESET}"
sudo ufw allow 22/tcp
sudo ufw allow 40400/tcp
sudo ufw allow 40400/udp
sudo ufw allow 8080/tcp
sudo ufw --force enable

# Kullanıcı bilgilerini al
echo -e "${CYAN}🔑 Gerekli bilgileri girin:${RESET}"
read -p "Ethereum RPC URL (ETHEREUM_HOSTS): " ETHEREUM_HOSTS
read -p "Beacon (Consensus) URL (L1_CONSENSUS_HOST_URLS): " L1_CONSENSUS_HOST_URLS
read -p "Validator Private Key (0x ile): " VALIDATOR_PRIVATE_KEY
read -p "Validator Public Address (0x ile): " VALIDATOR_ADDRESS

P2P_IP=$(curl -s ifconfig.me)
echo -e "${CYAN}🌐 IP adresiniz otomatik tespit edildi: $P2P_IP${RESET}"

# Docker Compose klasörünü ve dosyasını oluştur
mkdir -p ~/aztec-node/data && cd ~/aztec-node

cat > docker-compose.yml << EOL
version: '3'
services:
  aztec-node:
    container_name: aztec-sequencer
    image: aztecprotocol/aztec:alpha-testnet
    restart: unless-stopped
    environment:
      - ETHEREUM_HOSTS=${ETHEREUM_HOSTS}
      - L1_CONSENSUS_HOST_URLS=${L1_CONSENSUS_HOST_URLS}
      - DATA_DIRECTORY=/data
      - VALIDATOR_PRIVATE_KEY=${VALIDATOR_PRIVATE_KEY}
      - VALIDATOR_ADDRESS=${VALIDATOR_ADDRESS}
      - P2P_IP=${P2P_IP}
      - LOG_LEVEL=info
    volumes:
      - ./data:/data
    ports:
      - "40400:40400/tcp"
      - "40400:40400/udp"
      - "8080:8080/tcp"
    entrypoint: >
      sh -c 'node --no-warnings /usr/src/yarn-project/aztec/dest/bin/index.js start --network alpha-testnet --node --archiver --sequencer --p2p.maxTxPoolSize 1000000000'
EOL

# Node'u başlat
docker compose up -d

echo -e "${GREEN}✅ Aztec Sequencer Node başlatıldı!${RESET}"
echo -e "${CYAN}Logları görüntülemek için:\n${RESET}cd ~/aztec-node && docker compose logs -f"
