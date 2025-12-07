# frozen_string_literal: true

# CI/CDのデモンストレーション
# rails runner ci_cd_demo.rb で実行します

puts '=' * 80
puts 'CI/CD（継続的インテグレーション/デプロイ）のデモンストレーション'
puts '=' * 80
puts ''

puts '1. GitHub Actions CI'
puts '-' * 40
puts ''

github_actions_ci = <<~YAML
# .github/workflows/ci.yml
name: CI

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    services:
      postgres:
        image: postgres:16
        env:
          POSTGRES_PASSWORD: postgres
        ports:
          - 5432:5432
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
      
      redis:
        image: redis:7
        ports:
          - 6379:6379
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: 3.2
          bundler-cache: true
      
      - name: Set up Node
        uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: 'yarn'
      
      - name: Install dependencies
        run: |
          bundle install
          yarn install
      
      - name: Setup database
        env:
          DATABASE_URL: postgres://postgres:postgres@localhost:5432/test
          RAILS_ENV: test
        run: |
          bundle exec rails db:create
          bundle exec rails db:schema:load
      
      - name: Run tests
        env:
          DATABASE_URL: postgres://postgres:postgres@localhost:5432/test
          RAILS_ENV: test
          REDIS_URL: redis://localhost:6379
        run: bundle exec rspec
      
      - name: Run Rubocop
        run: bundle exec rubocop
      
      - name: Upload coverage
        uses: actions/upload-artifact@v4
        if: always()
        with:
          name: coverage
          path: coverage/
YAML

puts github_actions_ci
puts ''

puts '2. GitHub Actions Deploy'
puts '-' * 40
puts ''

github_actions_deploy = <<~YAML
# .github/workflows/deploy.yml
name: Deploy

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Deploy to Heroku
        uses: akhileshns/heroku-deploy@v3.13.15
        with:
          heroku_api_key: \${{ secrets.HEROKU_API_KEY }}
          heroku_app_name: your-app-name
          heroku_email: your-email@example.com
      
      - name: Run migrations
        run: heroku run rails db:migrate -a your-app-name
        env:
          HEROKU_API_KEY: \${{ secrets.HEROKU_API_KEY }}

  deploy-docker:
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Login to Container Registry
        uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: \${{ github.actor }}
          password: \${{ secrets.GITHUB_TOKEN }}
      
      - name: Build and push
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: ghcr.io/\${{ github.repository }}:latest
YAML

puts github_actions_deploy
puts ''

puts '3. CircleCI設定'
puts '-' * 40
puts ''

circleci_config = <<~YAML
# .circleci/config.yml
version: 2.1

orbs:
  ruby: circleci/ruby@2.1.0
  node: circleci/node@5.2.0

jobs:
  test:
    docker:
      - image: cimg/ruby:3.2-node
      - image: cimg/postgres:16.0
        environment:
          POSTGRES_USER: postgres
          POSTGRES_PASSWORD: postgres
      - image: cimg/redis:7.2
    
    steps:
      - checkout
      - ruby/install-deps
      - node/install-packages:
          pkg-manager: yarn
      
      - run:
          name: Setup database
          command: |
            bundle exec rails db:create
            bundle exec rails db:schema:load
          environment:
            DATABASE_URL: postgres://postgres:postgres@localhost:5432/test
            RAILS_ENV: test
      
      - run:
          name: Run tests
          command: bundle exec rspec
          environment:
            DATABASE_URL: postgres://postgres:postgres@localhost:5432/test
            RAILS_ENV: test
      
      - store_test_results:
          path: tmp/test-results
      
      - store_artifacts:
          path: coverage

workflows:
  test-and-deploy:
    jobs:
      - test
YAML

puts circleci_config
puts ''

puts '4. Kubernetes デプロイメント'
puts '-' * 40
puts ''

kubernetes_config = <<~YAML
# k8s/deployment.yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: rails-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: rails-app
  template:
    metadata:
      labels:
        app: rails-app
    spec:
      containers:
      - name: rails
        image: your-registry/rails-app:latest
        ports:
        - containerPort: 3000
        env:
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: rails-secrets
              key: database-url
        - name: RAILS_MASTER_KEY
          valueFrom:
            secretKeyRef:
              name: rails-secrets
              key: master-key
        - name: RAILS_ENV
          value: production
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        readinessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 5
          periodSeconds: 10
        livenessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 15
          periodSeconds: 20

---
# k8s/service.yml
apiVersion: v1
kind: Service
metadata:
  name: rails-app
spec:
  selector:
    app: rails-app
  ports:
  - port: 80
    targetPort: 3000
  type: LoadBalancer
YAML

puts kubernetes_config
puts ''

puts '=' * 80
puts 'CI/CDのベストプラクティス'
puts '=' * 80
puts ''

puts '1. テストを必ず通過させる'
puts '2. コードレビューを必須にする'
puts '3. 自動デプロイを設定する'
puts '4. ロールバック手順を準備する'
puts '5. ステージング環境で事前確認する'
puts ''

puts '=' * 80

