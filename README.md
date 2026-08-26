# Demo DevSecOps — Juice Shop + pipeline de seguridad

Fork de [OWASP Juice Shop](https://github.com/juice-shop/juice-shop) con un pipeline de GitHub Actions que corre cuatro escáneres de seguridad en cada push y bloquea el merge si encuentra algo crítico.

![Gitleaks](https://img.shields.io/badge/secretos-Gitleaks-E3B341)
![Semgrep](https://img.shields.io/badge/SAST-Semgrep-F0776C)
![Trivy](https://img.shields.io/badge/SCA%20%2B%20imagen-Trivy-F0776C)
![OWASP ZAP](https://img.shields.io/badge/DAST-OWASP%20ZAP-3FB950)

## Contexto

[OWASP Juice Shop](https://owasp-juice.shop) es una aplicación web deliberadamente insegura que se usa para entrenar en seguridad y probar herramientas. Este repo la toma como base para demostrar un enfoque DevSecOps: mover la seguridad al inicio del ciclo de desarrollo en lugar de dejarla para el final.

La mecánica es simple. Cada vez que alguien hace push, un pipeline corre cuatro escáneres en paralelo. Si alguno detecta algo crítico, el pipeline falla y el merge queda bloqueado, antes de que el código llegue a producción.

## Las cuatro capas

Cada herramienta cubre una superficie distinta, así que lo que una no ve, otra lo atrapa.

| Capa | Herramienta | Qué busca |
|------|-------------|-----------|
| Secretos | [Gitleaks](https://github.com/gitleaks/gitleaks) | Llaves, tokens y contraseñas en el código y el historial de git |
| SAST | [Semgrep](https://semgrep.dev) | Vulnerabilidades en el código fuente: SQL injection, XSS, crypto débil |
| SCA + imagen | [Trivy](https://github.com/aquasecurity/trivy) | Dependencias con CVEs conocidos y secretos en la imagen Docker |
| DAST | [OWASP ZAP](https://www.zaproxy.org) | La app corriendo: cabeceras faltantes, endpoints vulnerables |

SAST analiza el código sin ejecutarlo. DAST ataca la aplicación ya levantada, como lo haría un atacante real. SCA revisa las dependencias de terceros.

## Resultados

Salida del pipeline sobre este repo. No se realizó ninguna auditoría manual al código.

| Herramienta | Resultado | Hallazgos destacados |
|-------------|:---------:|----------------------|
| Gitleaks | Pasa | Escanea solo el diff de cada push. Se pone en rojo al abrir un PR con un secreto |
| Semgrep | 62 hallazgos | SQL injection, XSS, JWT hardcodeado, open redirect |
| Trivy | 3 llaves + 8 CVEs | Llaves privadas RSA en `lib/insecurity.ts` y terraform; CVEs críticos en `lodash`, `crypto-js`, `jsonwebtoken`, `marsdb` |
| OWASP ZAP | 8 warnings | CSP ausente, cross-domain misconfiguration, cabeceras faltantes |


## Cómo funciona

El workflow vive en [`.github/workflows/security.yml`](.github/workflows/security.yml) y se dispara en cada `push` y `pull_request`:

```
push / PR
   │
   ├─▶ Gitleaks   (secretos)
   ├─▶ Semgrep    (SAST)
   ├─▶ Trivy      (SCA + imagen Docker)
   └─▶ OWASP ZAP  (DAST sobre la app corriendo)
   │
   ▼
Si alguno encuentra algo crítico → pipeline en rojo → merge bloqueado
```

## Cómo verlo

Para levantar la app localmente:

```bash
docker run --rm -p 3000:3000 bkimminich/juice-shop
# abre http://localhost:3000
```

Los escaneos están en la pestaña [Actions](../../actions): abre cualquier run del workflow `security` para ver los cuatro jobs y sus hallazgos.

Para ver el bloqueo de secretos, abre un Pull Request que agregue un archivo con un secreto de ejemplo y observa cómo Gitleaks pone el check en rojo y bloquea el merge.

## Stack

GitHub Actions, Docker, Gitleaks, Semgrep, Trivy, OWASP ZAP.

---

<sub>Demo con fines educativos. La app base es OWASP Juice Shop, © Bjoern Kimminich y OWASP Juice Shop contributors, bajo licencia MIT. El pipeline de seguridad es la contribución de esta demo.</sub>
