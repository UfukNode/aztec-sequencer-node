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

echo -e "${CYAN}Gerekli bağımlılıklar yükleniyor...${RESET}"
sudo apt update && sudo apt install curl wget screen jq docker.io -y

echo -e "${GREEN}Docker kurulu durumda.${RESET}"

echo -e "${CYAN}IP adresi tespit ediliyor...${RESET}"
IP=$(curl -s https://api.ipify.org)
echo -e "${GREEN}Tespit edilen IP: $IP${RESET}"

read -p "Sepolia RPC URL girin: " RPC
read -p "Beacon (consensus) URL girin: " BEACON
read -p "Cüzdan private key girin: " PRVKEY
read -p "Cüzdan adresi girin (0x ile başlayan): " PUBKEY

echo -e "${CYAN}Docker içinde node başlatılıyor...${RESET}"

docker run -d --name aztec-node \
  --restart unless-stopped \
  -p 8080:8080 \
  -p 40400:40400 \
  -p 40400:40400/udp \
  aztecprotocol/aztec:latest \
  node --no-warnings /usr/src/yarn-project/aztec/dest/bin/index.js start \
  --node --archiver --sequencer \
  --network alpha-testnet \
  --l1-rpc-urls $RPC \
  --l1-consensus-host-urls $BEACON \
  --sequencer.validatorPrivateKey $PRVKEY \
  --sequencer.coinbase $PUBKEY \
  --p2p.p2pIp $IP \
  --p2p.maxTxPoolSize 1000000000

echo -e "${GREEN}✅ Node Docker içinde başlatıldı. Logları görmek için:${RESET}"
echo -e "${CYAN}docker logs -f aztec-node${RESET}"
