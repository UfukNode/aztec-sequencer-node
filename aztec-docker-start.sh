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
echo -e "${GREEN}Docker script başlatılıyor: Ufuk tarafından hazırlanmıştır.${RESET}"

sleep 2

echo -e "${CYAN}Docker kurulumu kontrol ediliyor...${RESET}"
if ! command -v docker &> /dev/null; then
  echo -e "${ORANGE}Docker bulunamadı, kurulum başlatılıyor...${RESET}"
  curl -fsSL https://get.docker.com -o get-docker.sh
  sh get-docker.sh
  rm get-docker.sh
fi

echo -e "${CYAN}Güncel Aztec imajı çekiliyor...${RESET}"
docker pull aztecprotocol/aztec:0.85.0-alpha-testnet.8

echo -e "${CYAN}IP adresi tespit ediliyor...${RESET}"
IP=$(curl -s https://api.ipify.org)
echo -e "${GREEN}Tespit edilen IP: $IP${RESET}"

read -p "Sepolia RPC URL girin: " RPC
read -p "Beacon (consensus) URL girin: " BEACON
read -p "Cüzdan private key girin: " PRVKEY
read -p "Cüzdan adresi girin (0x ile başlayan): " PUBKEY

echo -e "${CYAN}Node başlatılıyor...${RESET}"

docker rm -f aztec-node > /dev/null 2>&1

docker run -d --name aztec-node \
  -e HOME=/root \
  -e FORCE_COLOR=1 \
  -e P2P_PORT=40400 \
  -p 8080:8080 -p 40400:40400 -p 40400:40400/udp \
  --add-host host.docker.internal:host-gateway \
  --user 0:0 \
  --entrypoint aztecprotocol/aztec:0.85.0-alpha-testnet.8 \
  aztecprotocol/aztec:0.85.0-alpha-testnet.8 \
  node --no-warnings /usr/src/yarn-project/aztec/dist/bin/index.js start \
  --node --archiver --sequencer \
  --network alpha-testnet \
  --l1-rpc-urls $RPC \
  --l1-consensus-host-urls $BEACON \
  --sequencer.validatorPrivateKey $PRVKEY \
  --sequencer.coinbase $PUBKEY \
  --p2p.p2pIp $IP \
  --p2p.maxTxPoolSize 1000000000

echo -e "${GREEN}Node başarıyla başlatıldı. Logları görmek için:${RESET}"
echo -e "${CYAN}docker logs -f aztec-node${RESET}"
