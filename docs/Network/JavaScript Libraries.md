## **Reliable Resources for npm Package Research**

| Resource | URL | Best For |
|----------|-----|----------|
| **npmjs.com** | https://www.npmjs.com | Official registry, download stats, versions |
| **Snyk Advisor** | https://snyk.io/advisor | Security vulnerabilities, maintenance score, package health |
| **Socket.dev** | https://socket.dev | Supply chain security, malware detection |

## **Command Line Tools:**

```bash
# Check latest version
npm view [package] version

# Check all versions
npm view [package] versions

# Full package info
npm info [package]

# Check for vulnerabilities AFTER installing
npm audit

# Check outdated packages
npm outdated
```

## Use express for web servers
https://expressjs.com/
- while latest version is 5.1, 4.21.2 is more stable and widely used

## **Version Prefix Options:**

| Symbol | Example | Allows | Meaning |
|--------|---------|--------|---------|
| **`^`** | `^4.21.2` | 4.21.2, 4.22.0, 4.99.0 | Minor + patch updates (most common) |
| **`~`** | `~4.21.2` | 4.21.2, 4.21.3, 4.21.99 | Patch updates only |
| **None** | `4.21.2` | 4.21.2 ONLY | Exact version (use with `--save-exact`) |
| **`*`** | `*` | ANY version | Dangerous! Never use |
| **`>=`** | `>=4.21.2` | 4.21.2 and ANY newer | Too loose |
