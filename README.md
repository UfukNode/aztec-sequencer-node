![Gp3YTDybIAAmTYH](https://github.com/user-attachments/assets/cdbcbc64-6901-41f3-85ac-f9e59b91b6e3)

# Aztec Sequencer Node Kurulum Rehberi:

Bu rehber, sadece birkaç adımda Aztec testnet ağı üzerinde Sequencer Node çalıştırmanızı ve Discord’da "Apprentice" rolü almanızı sağlar. Script desteklidir, her şey otomatik gerçekleşir.

## Sistem Gereksinimleri

| Gereksinim           | Detaylar                                |
|----------------------|------------------------------------------|
| RAM                  | En az 16 GB                              |
| CPU                  | 8 Çekirdek                               |
| İşletim Sistemi      | Ubuntu 22.04 veya üzeri                 |
| Depolama             | 1TB SSD                                |

## Sunucu Önerisi:

**Uzun Vade Çalıştıracaklar İçin:**
- [Contabo 8 Core VPS](https://contabo.com/en/vps/cloud-vps-8c/?image=ubuntu.332&qty=1&contract=12&storage-type=vps-8-cores-400-gb-ssd)

**Rol Alamk İçin Çalıştıracaklar İçin:**
- [Contabo 6 Core VPS](https://contabo.com/en/vps/cloud-vps-6c/?image=ubuntu.332&qty=1&contract=12&storage-type=vps-6-cores-200-gb-ssd)

## Kurulum Öncesi Gereklilikler

- Yeni bir MetaMask cüzdanı oluşturun.
- Sepolia Test ETH alın: https://www.alchemy.com/faucets
- Sepolia RPC alın: https://dashboard.alchemy.com
- Beacon (Consensus) RPC alın: https://chainstack.com/global-nodes

![image](https://github.com/user-attachments/assets/d4910a1b-d47c-4252-ae15-5dbcbaa15396)

## 1- Node Kurulumu

Aşağıdaki komutu VPS'e girdikten sonra çalıştırın:

```bash
[ -f "script.sh" ] && rm script.sh; apt update -y && apt install curl -y && curl -sSL -o script.sh https://raw.githubusercontent.com/UfukNode/aztec-sequencer-node/refs/heads/main/script.sh && chmod +x script.sh && ./script.sh
````

### Script sizden şu bilgileri isteyecek:

* Sepolia RPC URL
* Beacon (Consensus) URL
* Private Key (**başında 0x olmadan**)
* Wallet Address (**0x ile başlayan**)

Kurulum tamamlandığında node `aztec` isimli bir screen oturumunda çalışmaya başlar.

## 2- Screen Kullanımı

Screen oturumundan çıkmak için:

```
CTRL + A ardından D
```

Tekrar bağlanmak için:

```bash
screen -r aztec
```

## 3- Discord "Apprentice" Rolü Alma

Node birkaç dakika çalıştıktan sonra aşağıdaki adımları izleyin:

### A- Block Numarası Al

```bash
curl -s -X POST -H 'Content-Type: application/json' \
-d '{"jsonrpc":"2.0","method":"node_getL2Tips","params":[],"id":67}' \
http://localhost:8080 | jq -r ".result.proven.number"
```

Bu komut size bir block numarası verir. Not alın.

### B- Proof Al

Aldığınız block numarasını aşağıdaki komuttaki "BLOCK" kısmındaki iki yere yazın:

```bash
curl -s -X POST -H 'Content-Type: application/json' \
-d '{"jsonrpc":"2.0","method":"node_getArchiveSiblingPath","params":["BLOCK","BLOCK"],"id":67}' \
http://localhost:8080 | jq -r ".result"
```

![blok (1)](https://github.com/user-attachments/assets/7a0694e9-8541-4331-a7f0-c33ba4266b8b)

Gelen uzun çıktı proof’tur, hepsini kopyalayın.

### C- Discord Rolü Almak

1. [https://discord.gg/aztec](https://discord.gg/aztec) adresine katılın
2. `#operators > start-here` kanalına girin
3. Komutu yazın:

```
/operator start
```

4. Sırasıyla:

   * Wallet adresinizi
   * Block numaranızı
   * Proof çıktısını girin

![Gp9h5y5WAAAV3eo](https://github.com/user-attachments/assets/ee1e114a-ef28-43c4-80cb-c81881b69de3)

## 4- Validator Kaydı (Opsiyonel)

Node senkronize olduktan sonra aşağıdaki komutla validator olarak kayıt olabilirsiniz:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/UfukNode/aztec-sequencer-node/main/validator_kayıt.sh)"
```

Script çalışırsa validator olarak kayıt olursunuz. Eğer günlük limit doluysa şu mesaj gösterilir:

```
⚠ Günlük limit dolmuş olabilir. Lütfen ertesi gün tekrar deneyin.
```

---

Ulaşmak ve Sorularınız İçin: https://x.com/UfukDegen
