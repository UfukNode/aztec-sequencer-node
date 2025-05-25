#!/bin/bash

ORANGE='\033[0;33m'
RESET='\033[0m'

echo -e "${ORANGE}Validator olarak kayıt olunuyor...${RESET}"

read -p "Sepolia RPC URL girin: " RPC
read -p "Cüzdan Private Key girin: " PRVKEY
read -p "Cüzdan Adresi (0x ile başlayan): " PUBKEY

OUTPUT=$(aztec add-l1-validator \
  --l1-rpc-urls $RPC \
  --private-key $PRVKEY \
  --attester $PUBKEY \
  --proposer-eoa $PUBKEY \
  --staking-asset-handler 0xF739D03e98e23A7B65940848aBA8921fF3bAc4b2 \
  --l1-chain-id 11155111 2>&1)

if echo "$OUTPUT" | grep -q "Error\|error\|invalid\|stack"; then
    echo -e "${ORANGE}⚠ Günlük limit dolmuş olabilir. Lütfen ertesi gün tekrar deneyin.${RESET}"
else
    echo -e "${ORANGE}✅ Validator kaydı başarılı oldu.${RESET}"
fi
