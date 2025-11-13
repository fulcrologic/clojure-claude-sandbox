# Clojure + Node.js + Claude Code Docker Image

Docker image combining Clojure development tools with Node.js ecosystem and Claude Code CLI.

## Image Details

**Base Image:** `clojure:temurin-25-tools-deps-alpine`
**Docker Hub:** `tonykayclj/clojure-node-claude:latest`

## Included Tools

- **Clojure CLI** 1.12.3.1577
- **Java/OpenJDK** 25.0.1 (Temurin LTS)
- **Node.js** v22.16.0 (from Alpine repos)
- **npm** 11.3.0
- **yarn** 1.22.22
- **nvm** 0.40.1 (for Node version management)
- **Claude Code** 2.0.37
- **git**, **bash**, **curl**, **ca-certificates**

## Quick Start

```bash
# Pull the image
docker pull tonykayclj/clojure-node-claude:latest

# Run interactively
docker run -it --rm tonykayclj/clojure-node-claude:latest

# Mount your project directory
docker run -it --rm -v $(pwd):/workspace -w /workspace tonykayclj/clojure-node-claude:latest
```

## Using nvm

Node.js v22.16.0 is installed by default. To manage Node versions with nvm:

```bash
# List available Node versions
. "$NVM_DIR/nvm.sh" && nvm ls-remote

# Install a specific version
. "$NVM_DIR/nvm.sh" && nvm install 20

# Switch versions
. "$NVM_DIR/nvm.sh" && nvm use 20

# Check current version
. "$NVM_DIR/nvm.sh" && node --version
```

Note: nvm is automatically loaded in interactive bash sessions via `.bashrc`

## Dockerfile Layer Structure

The Dockerfile is optimized for Docker layer caching:

### Layer 1: System Packages (Rarely Changes)
```dockerfile
RUN apk add --no-cache \
    bash \
    curl \
    git \
    ca-certificates \
    nodejs \
    npm \
    yarn
```
These packages rarely change. This layer will be cached and reused unless you modify the package list.

### Layer 2: nvm Installation (Rarely Changes)
```dockerfile
ENV NVM_DIR="/root/.nvm"
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash && \
    echo 'export NVM_DIR="$HOME/.nvm"' >> /root/.bashrc && \
    echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> /root/.bashrc && \
    echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' >> /root/.bashrc
```
nvm installation is stable. This layer will be cached unless you update nvm version.

### Layer 3: Global npm Packages (Most Likely to Change)
```dockerfile
RUN npm install -g @anthropic-ai/claude-code
```
Global npm packages are installed in their own layer. Add new packages here - only this layer will rebuild when modified.

### Layer 4: Verification (Optional)
```dockerfile
RUN node --version && \
    npm --version && \
    yarn --version && \
    claude --version && \
    bash -c '. "$NVM_DIR/nvm.sh" && nvm --version'
```
Verification commands ensure all tools are working. Can be removed to save a layer.

## Extending the Image

### Adding System Packages
Add to Layer 1 (will invalidate all subsequent layers):
```dockerfile
RUN apk add --no-cache \
    bash \
    curl \
    git \
    ca-certificates \
    nodejs \
    npm \
    yarn \
    postgresql-client \  # New package
    redis
```

### Adding Global npm Packages
Add to Layer 3 (only invalidates verification layer):
```dockerfile
RUN npm install -g @anthropic-ai/claude-code && \
    npm install -g typescript && \
    npm install -g ts-node
```

Or create separate RUN commands for even better caching:
```dockerfile
RUN npm install -g @anthropic-ai/claude-code
RUN npm install -g typescript
RUN npm install -g ts-node
```

### Creating a Custom Image
```dockerfile
FROM tonykayclj/clojure-node-claude:latest

# Add your custom tools
RUN apk add --no-cache postgresql-client
RUN npm install -g typescript

# Copy your project files
COPY . /app
WORKDIR /app

CMD ["/bin/bash"]
```

## Building the Image

```bash
# Build locally
docker build -t tonykayclj/clojure-node-claude:latest .

# Test the build
docker run --rm tonykayclj/clojure-node-claude:latest bash -c 'clojure --version && node --version && claude --version'

# Push to Docker Hub
docker push tonykayclj/clojure-node-claude:latest
```

## Common Use Cases

### Running a Clojure REPL
```bash
docker run -it --rm tonykayclj/clojure-node-claude:latest clojure
```

### Running a Node.js Script
```bash
docker run --rm -v $(pwd):/app -w /app tonykayclj/clojure-node-claude:latest node script.js
```

### Using Claude Code
```bash
docker run -it --rm \
  -v $(pwd):/workspace \
  -w /workspace \
  -e ANTHROPIC_API_KEY=$ANTHROPIC_API_KEY \
  tonykayclj/clojure-node-claude:latest \
  claude
```

### Development Environment
```bash
docker run -it --rm \
  -v $(pwd):/workspace \
  -w /workspace \
  -p 3000:3000 \
  -p 9630:9630 \
  tonykayclj/clojure-node-claude:latest \
  bash
```

## Image Size Considerations

This image uses Alpine Linux for minimal size. Current size: ~133 MB (before npm packages).

To reduce size further:
- Remove verification layer (saves minimal space)
- Use multi-stage builds if you only need runtime dependencies
- Consider removing yarn if you only use npm

## Troubleshooting

### nvm command not found
If running non-interactive commands, source nvm first:
```bash
docker run --rm tonykayclj/clojure-node-claude:latest bash -c '. "$NVM_DIR/nvm.sh" && nvm --version'
```

### Permission issues
The image runs as root by default. To run as a different user:
```bash
docker run -it --rm -u $(id -u):$(id -g) tonykayclj/clojure-node-claude:latest
```

### Node version mismatch
Alpine provides Node.js v22.x. To use a different version:
```bash
docker run -it --rm tonykayclj/clojure-node-claude:latest bash -c '. "$NVM_DIR/nvm.sh" && nvm install 20 && nvm use 20 && node --version'
```

## License

This Dockerfile is provided as-is for community use.
