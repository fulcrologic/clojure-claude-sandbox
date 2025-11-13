FROM clojure:temurin-25-tools-deps-alpine

# Layer 1: Install system packages (rarely changes)
RUN apk add --no-cache \
    bash \
    curl \
    git \
    ca-certificates \
    nodejs \
    npm \
    yarn

# Layer 2: Install and configure nvm (rarely changes)
ENV NVM_DIR="/root/.nvm"
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash && \
    echo 'export NVM_DIR="$HOME/.nvm"' >> /root/.bashrc && \
    echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> /root/.bashrc && \
    echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' >> /root/.bashrc

# Layer 3: Install global npm packages (changes when updating packages)
# Add new global packages here, each on its own line for better caching
RUN npm install -g @anthropic-ai/claude-code

# Layer 4: Verification (optional, can be removed to save a layer)
RUN node --version && \
    npm --version && \
    yarn --version && \
    claude --version && \
    bash -c '. "$NVM_DIR/nvm.sh" && nvm --version'

# Default command
CMD ["/bin/bash"]
