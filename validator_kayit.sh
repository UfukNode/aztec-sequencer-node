#!/bin/bash

ORANGE='\033[0;33m'
GREEN='\033[1;32m'
RESET='\033[0m'

echo -e "${ORANGE}Validator olarak kayıt olunuyor...${RESET}"

read -p "Sepolia RPC URL girin: " RPC
read -p "Cüzdan Private Keyinizi girin: " PRVKEY
read -p "Cüzdan Adresinizi Girin: " PUBKEY

OUTPUT=$(aztec add-l1-validator \
  --l1-rpc-urls $RPC \
  --private-key $PRVKEY \
  --attester $PUBKEY \
  --proposer-eoa $PUBKEY \
  --staking-asset-handler 0xF739D03e98e23A7B65940848aBA8921fF3bAc4b2 \
  --l1-chain-id 11155111 2>&1)

if echo "$OUTPUT" | grep -qi "ValidatorQuotaFilledUntil"; then
  TS=$(echo "$OUTPUT" | grep -oE 'ValidatorQuotaFilledUntil\([0-9]+\)' | grep -oE '[0-9]+' | head -n1)
  HUMAN_TIME=$(export TZ="Europe/Istanbul"; date -d "@$TS" "+%d %B %Y %H:%M:%S")
  echo -e "${ORANGE}⚠ Günlük validator limiti dolmuş olabilir.${RESET}"
  echo -e "${GREEN}⏳ Bir sonraki deneme zamanı (TR saatiyle): $HUMAN_TIME${RESET}"
elif echo "$OUTPUT" | grep -qi "Error\|invalid\|stack"; then
  echo -e "${ORANGE}⚠ Bir hata oluştu. Girdiğiniz bilgileri kontrol edin.${RESET}"
else
  echo -e "${GREEN}✅ Validator kaydı başarılı oldu.${RESET}"
fi
