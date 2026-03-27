#!/bin/bash
set -e

echo "=== Interview Tracker EC2 Setup ==="

# Create app directory
mkdir -p ~/app
cd ~/app

# Download docker-compose.yml from the repo
curl -o docker-compose.yml https://raw.githubusercontent.com/VinokurYurii/interview_tracker_be/main/deploy/docker-compose.yml

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
  cat > .env << 'EOF'
DATABASE_USERNAME=postgres
DATABASE_PASSWORD=CHANGE_ME_TO_A_STRONG_PASSWORD
RAILS_MASTER_KEY=PASTE_YOUR_MASTER_KEY_HERE
EOF
  echo ""
  echo ">>> .env file created at ~/app/.env"
  echo ">>> IMPORTANT: Edit it now with real values!"
  echo ">>>   nano ~/app/.env"
  echo ""
else
  echo ".env already exists, skipping."
fi

echo "=== Setup complete ==="
echo "Next steps:"
echo "  1. Edit ~/app/.env with real values"
echo "  2. Run: cd ~/app && docker compose pull"
echo "  3. Run: docker compose up -d"
