#!/bin/bash

ORANGE='\033[0;33m'
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
echo -e "${GREEN}Script başlatılıyor: Ufuk tarafından hazırlanmıştır.${RESET}"

sleep 2

# Bağımlılık ve docker kontrolü
echo -e "${CYAN}Gerekli bağımlılıklar yükleniyor...${RESET}"
sudo apt update && sudo apt install curl wget screen jq -y

echo -e "${CYAN}Docker kurulumu kontrol ediliyor...${RESET}"
if ! command -v docker &> /dev/null; then
  echo -e "${ORANGE}Docker bulunamadı, kurulum başlatılıyor...${RESET}"
  curl -fsSL https://get.docker.com -o get-docker.sh
  sh get-docker.sh
  rm get-docker.sh
fi

echo -e "${GREEN}Docker hazır.${RESET}"

# Girdi al
read -p "Sepolia RPC URL girin: " RPC
read -p "Beacon (consensus) URL girin: " BEACON
read -p "Cüzdan private key girin: " PRVKEY
read -p "Cüzdan adresi (0x ile): " PUBKEY

# IP adresini al
IP=$(curl -s https://api.ipify.org)
echo -e "${GREEN}Tespit edilen IP: $IP${RESET}"

# Eski container silinsin
echo -e "${CYAN}Eski aztec-node konteyneri siliniyor...${RESET}"
docker rm -f aztec-node 2>/dev/null

# Node başlat

echo -e "${CYAN}Docker ile Aztec node başlatılıyor...${RESET}"
docker run -d --name aztec-node \
  -e HOME=/root \
  -e FORCE_COLOR=1 \
  -e P2P_PORT=40400 \
  -p 8080:8080 -p 40400:40400 -p 40400:40400/udp \
  --add-host host.docker.internal:host-gateway \
  --user 0:0 \
  --entrypoint node \
  aztecprotocol/aztec:0.85.0-alpha-testnet.8 \
  /usr/src/yarn-project/aztec/dist/bin/index.js \
  --node --archiver --sequencer \
  --network alpha-testnet \
  --l1-rpc-urls $RPC \
  --l1-consensus-host-urls $BEACON \
  --sequencer.validatorPrivateKey $PRVKEY \
  --sequencer.coinbase $PUBKEY \
  --p2p.p2pIp $IP \
  --p2p.maxTxPoolSize 1000000000

sleep 2

echo -e "${GREEN}Node başarıyla başlatıldı. Logları görmek için:${RESET}"
echo -e "${CYAN}docker logs -f aztec-node${RESET}"
