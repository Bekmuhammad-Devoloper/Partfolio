module.exports = {
  apps: [
    {
      name: "hisobchi-ai",
      // we assume this is a NestJS/Node app with a start script
      script: "npm",
      args: "run start:prod",
      cwd: "./",
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: "300M",
      env: {
        NODE_ENV: "production",
        PORT: 3000
      }
    }
  ]
};
