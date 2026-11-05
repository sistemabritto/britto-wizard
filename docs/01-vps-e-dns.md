# 01 · VPS, DNS e requisitos

**VPS recomendada:** Ubuntu 24.04, x86_64, 4 vCPU, 8 GB de RAM, 80 GB de disco. Funciona com 4 GB, mas o wizard cria 4 GB de swap.

**Database Mart:** as VPS de entrada usam **Intel Xeon E3 v2 (Ivy Bridge)**, não AMD, e a CPU **não tem AVX2**. O wizard já usa versões que rodam sem AVX2, como o ClickHouse 26.3 LTS. Não troque as imagens por `latest` sem testar: o ClickHouse 26.5+ exige AVX2 e para de subir. Para conferir a CPU: `grep -o -w avx2 /proc/cpuinfo | head -1` (vazio = sem AVX2).

**DNS:** crie registros **A** apontando para o IP da VPS antes de rodar o wizard:

| Nome | Para |
|---|---|
| `portainer` | painel de administração |
| `crm` | o CRM |
| `api-crm` | a API (frontend, webhooks, MCP) |
| `whatsapp` | Evolution Go (evogo-jud) |
| `mcp` | conector MCP (opcional) |
| `assinatura` | DocuSeal (opcional) |

Na Cloudflare, deixe a nuvem **cinza** (sem proxy) até o certificado sair. Depois pode ligar o proxy.

**Rodar:**
```bash
sudo -i
bash <(curl -sSL https://raw.githubusercontent.com/sistemabritto/britto-wizard/main/britto)
```
Depois da 1ª vez, o comando `britto-wizard` fica instalado (`britto-wizard status`, `britto-wizard mcp`, `britto-wizard template`…).
