# Interview Tracker

AI-powered Interview Tracking Platform — a full-stack web application that helps job candidates
track their interview processes across multiple companies and improve performance through
structured reflection and AI-driven insights.

## Tech Stack

- **Backend:** Ruby 3.3.7, Rails 8 (API mode)
- **Database:** PostgreSQL 14
- **Background Jobs:** Sidekiq + Redis (planned)
- **Auth:** Devise (JWT) + Pundit
- **Infrastructure:** Docker, Docker Compose

## Getting Started with Docker

### Prerequisites

- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/) (included with Docker Desktop)

### Setup

1. Clone the repository
2. Copy the environment file and fill in your values:
   ```bash
   cp .env.example .env
   ```
3. Build and start the containers:
   ```bash
   docker compose build
   docker compose up
   ```
4. In a separate terminal, set up the databases:
   ```bash
   docker compose exec api bin/rails db:create db:migrate
   docker compose exec -e RAILS_ENV=test api bin/rails db:create db:schema:load
   ```

The API is now available at `http://localhost:3000`.

### Common Docker Commands

```bash
# Start all services
docker compose up

# Start in background (detached mode)
docker compose up -d

# Stop all services
docker compose down

# Rebuild after Gemfile changes
docker compose build
docker compose up

# Rails console
docker compose exec api bin/rails console

# Run tests
docker compose exec -e RAILS_ENV=test api bundle exec rspec

# Run migrations (development)
docker compose exec api bin/rails db:migrate

# Run migrations (test)
docker compose exec -e RAILS_ENV=test api bin/rails db:migrate

# View logs
docker compose logs api
docker compose logs db

# Seed the database
docker compose exec api bin/rails db:seed
```

### Production Build

```bash
docker compose -f docker-compose.prod.yml build
docker compose -f docker-compose.prod.yml up -d
```

## Getting Started without Docker

### Prerequisites

- Ruby 3.3.7 (via RVM: `rvm use 3.3.7@interview_tracker`)
- PostgreSQL 14

### Setup

```bash
bundle install
bin/rails db:create db:migrate
bin/rails server
```

### Running Tests

```bash
bundle exec rspec
```
