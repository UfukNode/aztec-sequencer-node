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
sudo apt update && sudo apt install -y curl wget screen jq

echo -e "${CYAN}Docker kurulumu kontrol ediliyor...${RESET}"
if ! command -v docker &> /dev/null; then
  echo -e "${ORANGE}Docker bulunamadı, kurulum başlatılıyor...${RESET}"
  curl -fsSL https://get.docker.com -o get-docker.sh
  sh get-docker.sh
  rm get-docker.sh
else
  echo -e "${GREEN}Docker zaten kurulu.${RESET}"
fi

echo -e "${CYAN}Aztec CLI kuruluyor...${RESET}"
curl -fsSL https://install.aztec.network | bash
export PATH="$HOME/.aztec/bin:$PATH"
echo 'export PATH="$HOME/.aztec/bin:$PATH"' >> ~/.bashrc

echo -e "${CYAN}Testnet'e geçiliyor...${RESET}"
aztec-up alpha-testnet

echo -e "${CYAN}IP adresi tespit ediliyor...${RESET}"
IP=$(curl -s https://api.ipify.org)
echo -e "${GREEN}Tespit edilen IP: $IP${RESET}"

read -p "Sepolia RPC URL girin: " RPC
read -p "Beacon (consensus) URL girin: " BEACON
read -p "Cüzdan private key girin: " PRVKEY
read -p "Cüzdan adresi girin (0x ile başlayan): " PUBKEY

echo -e "${CYAN}Node başlatılıyor...${RESET}"

NODE_SCRIPT="$HOME/start_aztec_node.sh"
cat > "$NODE_SCRIPT" <<EOF
#!/bin/bash
export PATH=\$PATH:\$HOME/.aztec/bin
aztec start --node --archiver --sequencer \\
  --network alpha-testnet \\
  --l1-rpc-urls $RPC \\
  --l1-consensus-host-urls $BEACON \\
  --sequencer.validatorPrivateKey $PRVKEY \\
  --sequencer.coinbase $PUBKEY \\
  --p2p.p2pIp $IP \\
  --p2p.maxTxPoolSize 1000000000
EOF

chmod +x "$NODE_SCRIPT"

# Daha önce açık bir screen varsa öldür
screen -S aztec -X quit 2>/dev/null

# Yeni bir screen oturumu başlat
screen -dmS aztec bash "$NODE_SCRIPT"

echo -e "${GREEN}Node başarıyla başlatıldı. \`screen -r aztec\` komutuyla ekranı görebilirsin.${RESET}"
