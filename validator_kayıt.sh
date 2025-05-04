#!/bin/bash

ORANGE='\033[0;33m'
GREEN='\033[1;32m'
CYAN='\033[0;36m'
RESET='\033[0m'

echo -e "${CYAN}Sepolia RPC URL girin:${RESET}"
read -p "> " RPC

echo -e "${CYAN}Cüzdan private key girin (0x ile başlayan):${RESET}"
read -p "> " PRVKEY

echo -e "${CYAN}Validator cüzdan adresini girin (0x ile başlayan):${RESET}"
read -p "> " ADDRESS

echo -e "${CYAN}Validatör olarak kayıt olunuyor...${RESET}"

aztec add-l1-validator \
  --l1-rpc-urls "$RPC" \
  --private-key "$PRVKEY" \
  --attester "$ADDRESS" \
  --proposer-eoa "$ADDRESS" \
  --staking-asset-handler 0xF739D03e98e23A7B65940848aBA8921fF3bAc4b2 \
  --l1-chain-id 11155111

echo -e "${GREEN}Komut gönderildi. Günlük limit doluysa daha sonra tekrar dene.${RESET}"
