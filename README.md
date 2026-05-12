# Convertly Landing

Landing page para [Convertly](https://useconvertly.lemonsqueezy.com) — API self-hostable de extracción estructurada de facturas para España, México y Argentina.

## Live

→ https://pokus-alfredo.github.io/convertly-landing/ *(reemplazar `pokus-alfredo` con tu user GitHub)*

## Stack

- HTML estático + Tailwind CDN
- Demo upload en vivo (vanilla JS, sin build)
- API backend: tunnel Cloudflare apuntando a homelab (será reemplazado por `convertly.io` cuando se registre)

## Demo flow

1. Usuario arrastra/sube factura (PNG/JPG/PDF) o clickea sample ES/MX/AR
2. JS hace POST a `/v1/invoice/extract` con API key de demo
3. Backend (Convertly API en homelab) corre OCR + Llama 3.1 8B local
4. Devuelve JSON estructurado con NIF/CIF/RFC/CUIT validados
5. Landing muestra el JSON en pantalla

## Producto que se vende

**Convertly Self-Hosted** vía Lemon Squeezy:

- Single-user: $79 one-time, license perpetua, updates 1 año
- Team: $149, 5 usuarios, soporte 1 año
- Enterprise: $399, ilimitado, soporte prioritario

## Deploy

GitHub Pages configurado en branch `main`. Cada push triggers auto-deploy.

Setup manual:
```
Settings → Pages → Build from: main branch / (root)
```

## License

MIT — landing es marketing público, modificable.
