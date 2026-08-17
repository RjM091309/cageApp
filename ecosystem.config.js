const { execSync } = require('child_process');
const path = require('path');

const PREFERRED_PORT = Number(process.env.PREFERRED_PORT || 4200);

function isPortInUse(port) {
  try {
    const out = execSync(`ss -H -tuln sport = :${port}`, {
      encoding: 'utf8',
      stdio: ['pipe', 'pipe', 'ignore'],
    });
    return out.trim().length > 0;
  } catch {
    return false;
  }
}

function resolvePort(preferred, maxTries = 20) {
  for (let port = preferred; port < preferred + maxTries; port += 1) {
    if (!isPortInUse(port)) return port;
  }
  return preferred;
}

const PORT = resolvePort(PREFERRED_PORT);

module.exports = {
  apps: [
    {
      name: 'infcageApp',
      cwd: path.resolve(__dirname),
      script: 'serve_web.py',
      interpreter: 'python3',
      autorestart: true,
      watch: false,
      max_restarts: 10,
      min_uptime: '5s',
      env: {
        PORT: String(PORT),
        PREFERRED_PORT: String(PREFERRED_PORT),
      },
    },
  ],
};
