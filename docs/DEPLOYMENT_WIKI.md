# NOEMI E-commerce Platform - Advanced Deployment Wiki

This wiki provides in-depth technical documentation for advanced deployment scenarios, third-party integrations, and production optimization.

## 📖 Table of Contents

- [Third-Party Service Integrations](#third-party-service-integrations)
- [Advanced AWS Deployment](#advanced-aws-deployment)
- [Advanced Azure Deployment](#advanced-azure-deployment)
- [Advanced Digital Ocean Deployment](#advanced-digital-ocean-deployment)
- [Advanced Netlify + Railway Deployment](#advanced-netlify--railway-deployment)
- [Performance Optimization](#performance-optimization)
- [Monitoring and Analytics](#monitoring-and-analytics)
- [CI/CD Pipeline Configuration](#cicd-pipeline-configuration)
- [SSL Certificate Management](#ssl-certificate-management)
- [Database Optimization](#database-optimization)
- [Backup and Disaster Recovery](#backup-and-disaster-recovery)

## Third-Party Service Integrations

### Required API Keys and Accounts

#### Payment Processing (Stripe)

1. **Create Stripe Account:**
   - Go to [https://stripe.com](https://stripe.com)
   - Create account and complete verification
   - Navigate to Developers > API Keys

2. **Get API Keys:**
   ```bash
   # Test Keys (for development)
   STRIPE_PUBLISHABLE_KEY=pk_test_...
   STRIPE_SECRET_KEY=sk_test_...
   
   # Live Keys (for production)
   STRIPE_PUBLISHABLE_KEY=pk_live_...
   STRIPE_SECRET_KEY=sk_live_...
   ```

3. **Configure Webhooks:**
   ```bash
   # Webhook endpoint: https://api.your-domain.com/hooks/stripe
   # Events to listen for:
   - payment_intent.succeeded
   - payment_intent.payment_failed
   - customer.subscription.created
   - customer.subscription.updated
   - customer.subscription.deleted
   ```

4. **Backend Configuration:**
   ```typescript
   // medusa-config.ts
   modules: [
     {
       resolve: "@medusajs/payment-stripe",
       options: {
         api_key: process.env.STRIPE_SECRET_KEY,
         webhook_secret: process.env.STRIPE_WEBHOOK_SECRET,
       },
     },
   ]
   ```

#### Email Service (SendGrid)

1. **Create SendGrid Account:**
   - Go to [https://sendgrid.com](https://sendgrid.com)
   - Create account and verify domain
   - Generate API key in Settings > API Keys

2. **Domain Authentication:**
   ```bash
   # DNS Records to add:
   # Type: CNAME, Name: s1._domainkey, Value: s1.domainkey.u[ID].wl.sendgrid.net
   # Type: CNAME, Name: s2._domainkey, Value: s2.domainkey.u[ID].wl.sendgrid.net
   ```

3. **Backend Configuration:**
   ```typescript
   // medusa-config.ts
   modules: [
     {
       resolve: "@medusajs/notification-sendgrid",
       options: {
         api_key: process.env.SENDGRID_API_KEY,
         from: process.env.SENDGRID_FROM,
         templates: {
           order_placed: "d-template-id",
           customer_password_reset: "d-template-id",
         },
       },
     },
   ]
   ```

#### File Storage (AWS S3)

1. **Create S3 Bucket:**
   ```bash
   aws s3 mb s3://noemi-medusa-uploads --region us-east-1
   ```

2. **Configure CORS:**
   ```json
   {
     "CORSRules": [
       {
         "AllowedHeaders": ["*"],
         "AllowedMethods": ["GET", "POST", "PUT", "DELETE"],
         "AllowedOrigins": ["https://your-domain.com", "https://admin.your-domain.com"],
         "ExposeHeaders": []
       }
     ]
   }
   ```

3. **Create IAM User:**
   ```json
   {
     "Version": "2012-10-17",
     "Statement": [
       {
         "Effect": "Allow",
         "Action": [
           "s3:GetObject",
           "s3:PutObject",
           "s3:DeleteObject"
         ],
         "Resource": "arn:aws:s3:::noemi-medusa-uploads/*"
       },
       {
         "Effect": "Allow",
         "Action": ["s3:ListBucket"],
         "Resource": "arn:aws:s3:::noemi-medusa-uploads"
       }
     ]
   }
   ```

4. **Backend Configuration:**
   ```typescript
   // medusa-config.ts
   modules: [
     {
       resolve: "@medusajs/file-s3",
       options: {
         s3_url: process.env.S3_URL,
         bucket: process.env.S3_BUCKET,
         region: process.env.S3_REGION,
         access_key_id: process.env.S3_ACCESS_KEY_ID,
         secret_access_key: process.env.S3_SECRET_ACCESS_KEY,
       },
     },
   ]
   ```

#### Search (MeiliSearch)

1. **MeiliSearch Cloud Setup:**
   - Go to [https://cloud.meilisearch.com](https://cloud.meilisearch.com)
   - Create project and get API key

2. **Backend Configuration:**
   ```typescript
   // medusa-config.ts
   modules: [
     {
       resolve: "@medusajs/search-meilisearch",
       options: {
         config: {
           host: process.env.MEILISEARCH_HOST,
           apiKey: process.env.MEILISEARCH_API_KEY,
         },
         settings: {
           products: {
             indexSettings: {
               searchableAttributes: ["title", "description", "tags"],
               displayedAttributes: ["id", "title", "description", "handle", "thumbnail"],
               filterableAttributes: ["id", "status", "created_at", "updated_at"],
               sortableAttributes: ["created_at", "updated_at"],
             },
           },
         },
       },
     },
   ]
   ```

## Advanced AWS Deployment

### Complete ECS Task Definition

```json
{
  "family": "noemi-medusa-backend",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "1024",
  "memory": "2048",
  "executionRoleArn": "arn:aws:iam::your-account:role/ecsTaskExecutionRole",
  "taskRoleArn": "arn:aws:iam::your-account:role/ecsTaskRole",
  "containerDefinitions": [
    {
      "name": "medusa-backend",
      "image": "your-account-id.dkr.ecr.us-east-1.amazonaws.com/noemi-medusa-backend:latest",
      "portMappings": [
        {
          "containerPort": 9000,
          "protocol": "tcp"
        }
      ],
      "essential": true,
      "environment": [
        {
          "name": "NODE_ENV",
          "value": "production"
        }
      ],
      "secrets": [
        {
          "name": "DATABASE_URL",
          "valueFrom": "arn:aws:ssm:us-east-1:account:parameter/noemi/DATABASE_URL"
        },
        {
          "name": "JWT_SECRET",
          "valueFrom": "arn:aws:ssm:us-east-1:account:parameter/noemi/JWT_SECRET"
        },
        {
          "name": "COOKIE_SECRET",
          "valueFrom": "arn:aws:ssm:us-east-1:account:parameter/noemi/COOKIE_SECRET"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/noemi-medusa-backend",
          "awslogs-region": "us-east-1",
          "awslogs-stream-prefix": "ecs"
        }
      },
      "healthCheck": {
        "command": ["CMD-SHELL", "curl -f http://localhost:9000/health || exit 1"],
        "interval": 30,
        "timeout": 5,
        "retries": 3,
        "startPeriod": 60
      }
    }
  ]
}
```

### Application Load Balancer Configuration

```bash
# Create ALB
aws elbv2 create-load-balancer \
  --name noemi-medusa-alb \
  --subnets subnet-12345 subnet-67890 \
  --security-groups sg-web-traffic

# Create target group
aws elbv2 create-target-group \
  --name noemi-medusa-targets \
  --protocol HTTP \
  --port 9000 \
  --vpc-id vpc-12345 \
  --target-type ip \
  --health-check-path /health \
  --health-check-interval-seconds 30 \
  --health-check-timeout-seconds 5 \
  --healthy-threshold-count 2 \
  --unhealthy-threshold-count 5

# Create listener
aws elbv2 create-listener \
  --load-balancer-arn arn:aws:elasticloadbalancing:... \
  --protocol HTTPS \
  --port 443 \
  --certificates CertificateArn=arn:aws:acm:... \
  --default-actions Type=forward,TargetGroupArn=arn:aws:elasticloadbalancing:...
```

### Auto Scaling Configuration

```bash
# Create scaling policy
aws application-autoscaling register-scalable-target \
  --service-namespace ecs \
  --scalable-dimension ecs:service:DesiredCount \
  --resource-id service/noemi-cluster/noemi-medusa-backend \
  --min-capacity 1 \
  --max-capacity 10

# Create scale-out policy
aws application-autoscaling put-scaling-policy \
  --policy-name noemi-medusa-scale-out \
  --service-namespace ecs \
  --scalable-dimension ecs:service:DesiredCount \
  --resource-id service/noemi-cluster/noemi-medusa-backend \
  --policy-type TargetTrackingScaling \
  --target-tracking-scaling-policy-configuration '{
    "TargetValue": 70.0,
    "PredefinedMetricSpecification": {
      "PredefinedMetricType": "ECSServiceAverageCPUUtilization"
    },
    "ScaleOutCooldown": 300,
    "ScaleInCooldown": 300
  }'
```

### CloudFront Distribution for Frontend

```json
{
  "CallerReference": "noemi-medusa-frontend-2024",
  "Comment": "NOEMI Medusa Frontend Distribution",
  "DefaultRootObject": "index.html",
  "Origins": {
    "Quantity": 1,
    "Items": [
      {
        "Id": "S3-noemi-medusa-frontend",
        "DomainName": "noemi-medusa-frontend.s3.amazonaws.com",
        "S3OriginConfig": {
          "OriginAccessIdentity": "origin-access-identity/cloudfront/ABCDEFGHIJKLMN"
        }
      }
    ]
  },
  "DefaultCacheBehavior": {
    "TargetOriginId": "S3-noemi-medusa-frontend",
    "ViewerProtocolPolicy": "redirect-to-https",
    "AllowedMethods": {
      "Quantity": 7,
      "Items": ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"],
      "CachedMethods": {
        "Quantity": 2,
        "Items": ["GET", "HEAD"]
      }
    },
    "ForwardedValues": {
      "QueryString": true,
      "Cookies": {
        "Forward": "none"
      },
      "Headers": {
        "Quantity": 1,
        "Items": ["Origin"]
      }
    },
    "TrustedSigners": {
      "Enabled": false,
      "Quantity": 0
    },
    "MinTTL": 0,
    "DefaultTTL": 86400,
    "MaxTTL": 31536000,
    "Compress": true
  },
  "CacheBehaviors": {
    "Quantity": 2,
    "Items": [
      {
        "PathPattern": "/_next/static/*",
        "TargetOriginId": "S3-noemi-medusa-frontend",
        "ViewerProtocolPolicy": "redirect-to-https",
        "MinTTL": 31536000,
        "DefaultTTL": 31536000,
        "MaxTTL": 31536000,
        "ForwardedValues": {
          "QueryString": false,
          "Cookies": {"Forward": "none"}
        }
      },
      {
        "PathPattern": "/api/*",
        "TargetOriginId": "ALB-noemi-medusa-backend",
        "ViewerProtocolPolicy": "redirect-to-https",
        "MinTTL": 0,
        "DefaultTTL": 0,
        "MaxTTL": 0,
        "ForwardedValues": {
          "QueryString": true,
          "Cookies": {"Forward": "all"},
          "Headers": {"Quantity": 1, "Items": ["*"]}
        }
      }
    ]
  },
  "CustomErrorResponses": {
    "Quantity": 2,
    "Items": [
      {
        "ErrorCode": 403,
        "ResponsePagePath": "/index.html",
        "ResponseCode": "200",
        "ErrorCachingMinTTL": 0
      },
      {
        "ErrorCode": 404,
        "ResponsePagePath": "/index.html",
        "ResponseCode": "200",
        "ErrorCachingMinTTL": 0
      }
    ]
  },
  "Enabled": true,
  "PriceClass": "PriceClass_100"
}
```

## Advanced Azure Deployment

### Azure Static Web Apps Configuration

```json
{
  "routes": [
    {
      "route": "/api/*",
      "allowedRoles": ["anonymous"]
    },
    {
      "route": "/admin/*",
      "allowedRoles": ["authenticated"]
    }
  ],
  "navigationFallback": {
    "rewrite": "/index.html",
    "exclude": ["/images/*.{png,jpg,gif}", "/css/*"]
  },
  "mimeTypes": {
    ".json": "text/json"
  },
  "globalHeaders": {
    "X-Content-Type-Options": "nosniff",
    "X-Frame-Options": "DENY",
    "X-XSS-Protection": "1; mode=block"
  },
  "responseOverrides": {
    "401": {
      "redirect": "/login",
      "statusCode": 302
    }
  }
}
```

### Azure Container Registry and App Service

```bash
# Create container registry
az acr create \
  --resource-group noemi-medusa-rg \
  --name noemimargcr \
  --sku Basic \
  --admin-enabled true

# Build and push image
cd noemi-medusa-backend
az acr build \
  --registry noemimargcr \
  --image medusa-backend:latest \
  .

# Create app service with container
az webapp create \
  --resource-group noemi-medusa-rg \
  --plan noemi-medusa-plan \
  --name noemi-medusa-backend \
  --deployment-container-image-name noemimargcr.azurecr.io/medusa-backend:latest

# Configure continuous deployment
az webapp deployment container config \
  --name noemi-medusa-backend \
  --resource-group noemi-medusa-rg \
  --enable-cd true
```

### Azure Application Gateway Configuration

```bash
# Create application gateway
az network application-gateway create \
  --name noemi-ag \
  --location eastus \
  --resource-group noemi-medusa-rg \
  --vnet-name noemi-vnet \
  --subnet noemi-ag-subnet \
  --capacity 2 \
  --sku Standard_v2 \
  --http-settings-cookie-based-affinity Disabled \
  --frontend-port 80 \
  --http-settings-port 80 \
  --http-settings-protocol Http \
  --public-ip-address noemi-ag-pip

# Add SSL certificate
az network application-gateway ssl-cert create \
  --gateway-name noemi-ag \
  --resource-group noemi-medusa-rg \
  --name ssl-cert \
  --cert-file path/to/certificate.pfx \
  --cert-password your-password
```

## Advanced Digital Ocean Deployment

### App Platform Spec with Advanced Configuration

```yaml
name: noemi-medusa-complete
region: nyc

databases:
- name: noemi-db
  engine: PG
  version: "15"
  size: db-s-1vcpu-1gb
  num_nodes: 1
  production: true

services:
- name: backend
  source_dir: /noemi-medusa-backend
  github:
    repo: your-username/noemi-medusa-monorepo
    branch: main
    deploy_on_push: true
  
  run_command: yarn start
  build_command: NODE_ENV=production yarn build
  
  environment_slug: node-js
  instance_count: 2
  instance_size_slug: basic-s
  
  http_port: 9000
  
  routes:
  - path: /
  
  health_check:
    http_path: /health
  
  envs:
  - key: NODE_ENV
    value: production
  - key: DATABASE_URL
    value: ${noemi-db.DATABASE_URL}
  - key: JWT_SECRET
    value: "your-super-secure-jwt-secret-min-32-chars"
    type: SECRET
  - key: COOKIE_SECRET
    value: "your-super-secure-cookie-secret-min-32-chars" 
    type: SECRET
  - key: STORE_CORS
    value: "https://your-domain.com,https://www.your-domain.com"
  - key: ADMIN_CORS
    value: "https://noemi-medusa-backend-slug.ondigitalocean.app"
  - key: AUTH_CORS
    value: "https://noemi-medusa-backend-slug.ondigitalocean.app"

static_sites:
- name: frontend
  source_dir: /noemi-medusa-storefront
  github:
    repo: your-username/noemi-medusa-monorepo
    branch: main
    deploy_on_push: true
  
  build_command: corepack enable && yarn install && yarn build
  output_dir: .next
  
  environment_slug: node-js
  
  routes:
  - path: /
  
  envs:
  - key: NEXT_PUBLIC_MEDUSA_BACKEND_URL
    value: "https://noemi-medusa-backend-slug.ondigitalocean.app"
  - key: MEDUSA_BACKEND_URL
    value: "https://noemi-medusa-backend-slug.ondigitalocean.app"
  - key: NEXT_PUBLIC_MEDUSA_PUBLISHABLE_KEY
    value: "pk_live_your_key"
    type: SECRET
  - key: NEXT_PUBLIC_BASE_URL
    value: "https://your-domain.com"
  - key: NODE_ENV
    value: production

domains:
- name: your-domain.com
  type: PRIMARY
  zone: your-domain.com
- name: www.your-domain.com
  type: ALIAS
  zone: your-domain.com
- name: api.your-domain.com
  type: ALIAS
  zone: your-domain.com

alerts:
- rule: CPU_UTILIZATION
  disabled: false
  value: 80
- rule: MEM_UTILIZATION
  disabled: false
  value: 80
- rule: RESTART_COUNT
  disabled: false
  value: 5
```

### Load Balancer Configuration

```bash
# Create load balancer
doctl compute load-balancer create \
  --name noemi-lb \
  --forwarding-rules "entry_protocol:https,entry_port:443,target_protocol:http,target_port:9000,certificate_id:cert-id" \
  --health-check "protocol:http,port:9000,path:/health,check_interval_seconds:10,response_timeout_seconds:5,healthy_threshold:3,unhealthy_threshold:3" \
  --region nyc3 \
  --size lb-small

# Add droplets to load balancer
# First, get your droplet IDs (replace the filter as needed):
doctl compute droplet list --format ID,Name

# Then, add your actual droplet IDs (replace <droplet-id-1>,<droplet-id-2> with your real IDs):
doctl compute load-balancer add-droplets noemi-lb --droplet-ids <droplet-id-1>,<droplet-id-2>
```

## Advanced Netlify + Railway Deployment

### Railway Production Configuration

```toml
# railway.toml
[build]
builder = "NIXPACKS"
buildCommand = "NODE_ENV=production yarn build"

[deploy]
startCommand = "yarn start"
healthcheckPath = "/health"
healthcheckTimeout = 100
restartPolicyType = "ON_FAILURE"
restartPolicyMaxRetries = 10

[env]
NODE_ENV = "production"

[scaling]
minReplicas = 1
maxReplicas = 10

[resources]
cpuLimit = "1000m"
memoryLimit = "1Gi"

[networking]
serviceDomains = ["api.your-domain.com"]
```

### Advanced Netlify Configuration

```toml
# netlify.toml
[build]
  base = "noemi-medusa-storefront/"
  command = "corepack enable && yarn install && yarn build"
  publish = ".next/"
  
[build.environment]
  NODE_VERSION = "20"
  YARN_VERSION = "3.2.3"
  COREPACK_ENABLE_STRICT = "0"
  NODE_OPTIONS = "--max-old-space-size=4096"

[context.production.environment]
  NODE_ENV = "production"
  NEXT_TELEMETRY_DISABLED = "1"

[context.deploy-preview.environment]
  NODE_ENV = "development"

[[plugins]]
  package = "@netlify/plugin-nextjs"

[[plugins]]
  package = "netlify-plugin-cache"
  [plugins.inputs]
    paths = [".next/cache"]

[[redirects]]
  from = "/sitemap.xml"
  to = "/.netlify/functions/sitemap"
  status = 200

[[redirects]]
  from = "/api/*"
  to = "https://your-backend.railway.app/api/:splat"
  status = 200
  force = true

[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200

[[headers]]
  for = "/*"
  [headers.values]
    X-Frame-Options = "DENY"
    X-Content-Type-Options = "nosniff"
    X-XSS-Protection = "1; mode=block"
    Referrer-Policy = "strict-origin-when-cross-origin"
    Permissions-Policy = "camera=(), microphone=(), geolocation=()"

[[headers]]
  for = "/_next/static/*"
  [headers.values]
    Cache-Control = "public, max-age=31536000, immutable"

[[headers]]
  for = "/images/*"
  [headers.values]
    Cache-Control = "public, max-age=31536000"

[functions]
  node_bundler = "esbuild"
  included_files = ["data/**"]
```

## Performance Optimization

### Database Connection Pooling

```typescript
// Database configuration with pooling
export const dbConfig = {
  type: "postgres",
  url: process.env.DATABASE_URL,
  extra: {
    max: 20, // maximum number of connections
    min: 2,  // minimum number of connections
    acquireTimeoutMillis: 60000,
    createTimeoutMillis: 30000,
    destroyTimeoutMillis: 5000,
    idleTimeoutMillis: 30000,
    reapIntervalMillis: 1000,
    createRetryIntervalMillis: 200,
  },
  ssl: process.env.NODE_ENV === "production" ? { rejectUnauthorized: false } : false,
}
```

### Redis Configuration for Caching

```typescript
// Redis session store configuration
import RedisStore from "connect-redis"
import Redis from "ioredis"

const redis = new Redis(process.env.REDIS_URL, {
  retryDelayOnFailover: 100,
  maxRetriesPerRequest: 3,
  lazyConnect: true,
})

export const sessionConfig = {
  store: new RedisStore({ client: redis }),
  secret: process.env.COOKIE_SECRET,
  resave: false,
  saveUninitialized: false,
  cookie: {
    secure: process.env.NODE_ENV === "production",
    httpOnly: true,
    maxAge: 24 * 60 * 60 * 1000, // 24 hours
  },
}
```

### Next.js Optimization

```javascript
// next.config.js
/** @type {import('next').NextConfig} */
const nextConfig = {
  experimental: {
    optimizeCss: true,
    optimizeServerReact: true,
  },
  images: {
    formats: ['image/webp', 'image/avif'],
    deviceSizes: [640, 750, 828, 1080, 1200, 1920, 2048, 3840],
    imageSizes: [16, 32, 48, 64, 96, 128, 256, 384],
    domains: ['your-cdn-domain.com'],
    loader: 'custom',
    loaderFile: './src/lib/image-loader.ts',
  },
  webpack: (config, { dev, isServer }) => {
    if (!dev && !isServer) {
      config.optimization.splitChunks.chunks = 'all'
      config.optimization.splitChunks.cacheGroups = {
        default: false,
        vendors: false,
        vendor: {
          name: 'vendor',
          chunks: 'all',
          test: /node_modules/,
        },
        common: {
          name: 'common',
          minChunks: 2,
          chunks: 'all',
          enforce: true,
        },
      }
    }
    return config
  },
  async headers() {
    return [
      {
        source: '/(.*)',
        headers: [
          {
            key: 'X-DNS-Prefetch-Control',
            value: 'on'
          },
          {
            key: 'Strict-Transport-Security',
            value: 'max-age=63072000; includeSubDomains; preload'
          },
          {
            key: 'X-Frame-Options',
            value: 'SAMEORIGIN'
          }
        ]
      }
    ]
  }
}

module.exports = nextConfig
```

## Monitoring and Analytics

### Error Tracking with Sentry

```bash
# Install Sentry
npm install @sentry/nextjs @sentry/node
```

```javascript
// sentry.client.config.js
import * as Sentry from "@sentry/nextjs"

Sentry.init({
  dsn: process.env.NEXT_PUBLIC_SENTRY_DSN,
  tracesSampleRate: 0.1,
  environment: process.env.NODE_ENV,
  beforeSend(event) {
    if (event.exception) {
      const error = event.exception.values?.[0]
      if (error?.value?.includes('Non-Error promise rejection')) {
        return null
      }
    }
    return event
  },
})
```

```javascript
// sentry.server.config.js
import * as Sentry from "@sentry/node"

Sentry.init({
  dsn: process.env.SENTRY_DSN,
  tracesSampleRate: 0.1,
  environment: process.env.NODE_ENV,
})
```

### Application Performance Monitoring

```typescript
// lib/monitoring.ts
import { Performance } from 'perf_hooks'

export class APMMonitor {
  private static instance: APMMonitor
  private metrics: Map<string, number[]> = new Map()

  static getInstance(): APMMonitor {
    if (!APMMonitor.instance) {
      APMMonitor.instance = new APMMonitor()
    }
    return APMMonitor.instance
  }

  startTimer(name: string): () => void {
    const start = performance.now()
    return () => {
      const duration = performance.now() - start
      this.recordMetric(name, duration)
    }
  }

  recordMetric(name: string, value: number): void {
    if (!this.metrics.has(name)) {
      this.metrics.set(name, [])
    }
    this.metrics.get(name)!.push(value)
  }

  getMetrics(): Record<string, { avg: number; min: number; max: number; count: number }> {
    const result: any = {}
    for (const [name, values] of this.metrics.entries()) {
      result[name] = {
        avg: values.reduce((a, b) => a + b, 0) / values.length,
        min: Math.min(...values),
        max: Math.max(...values),
        count: values.length,
      }
    }
    return result
  }
}
```

### Health Check Endpoints

```typescript
// src/api/health/detailed/route.ts
import { NextRequest, NextResponse } from 'next/server'
import { APMMonitor } from '@/lib/monitoring'

export async function GET(req: NextRequest) {
  const monitor = APMMonitor.getInstance()
  
  const health = {
    status: 'healthy',
    timestamp: new Date().toISOString(),
    version: process.env.npm_package_version,
    environment: process.env.NODE_ENV,
    uptime: process.uptime(),
    memory: process.memoryUsage(),
    metrics: monitor.getMetrics(),
    database: await checkDatabaseHealth(),
    redis: await checkRedisHealth(),
  }

  return NextResponse.json(health)
}

async function checkDatabaseHealth(): Promise<{ status: string; latency?: number }> {
  try {
    const start = performance.now()
    // Add your database health check here
    const latency = performance.now() - start
    return { status: 'connected', latency }
  } catch (error) {
    return { status: 'disconnected' }
  }
}

async function checkRedisHealth(): Promise<{ status: string; latency?: number }> {
  try {
    const start = performance.now()
    // Add your Redis health check here
    const latency = performance.now() - start
    return { status: 'connected', latency }
  } catch (error) {
    return { status: 'disconnected' }
  }
}
```

## CI/CD Pipeline Configuration

### Complete GitHub Actions Workflow

```yaml
# .github/workflows/deploy.yml
name: Deploy NOEMI Platform

on:
  push:
    branches: [main, staging, develop]
  pull_request:
    branches: [main]

env:
  NODE_VERSION: '20'
  REGISTRY: ghcr.io

jobs:
  test:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_PASSWORD: postgres
          POSTGRES_DB: test_db
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 5432:5432

    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'yarn'

      - name: Install dependencies
        run: |
          cd noemi-medusa-backend
          yarn install --frozen-lockfile
          cd ../noemi-medusa-storefront
          corepack enable
          yarn install

      - name: Run backend tests
        run: |
          cd noemi-medusa-backend
          yarn test:unit
        env:
          DATABASE_URL: postgres://postgres:postgres@localhost:5432/test_db
          NODE_ENV: test

      - name: Run frontend tests
        run: |
          cd noemi-medusa-storefront
          yarn lint
          yarn typecheck

      - name: Build backend
        run: |
          cd noemi-medusa-backend
          NODE_ENV=production yarn build

      - name: Build frontend
        run: |
          cd noemi-medusa-storefront
          yarn build
        env:
          NEXT_PUBLIC_MEDUSA_BACKEND_URL: http://localhost:9000
          NEXT_PUBLIC_MEDUSA_PUBLISHABLE_KEY: pk_test_dummy

  security-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Run Trivy vulnerability scanner
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: 'fs'
          scan-ref: '.'
          format: 'sarif'
          output: 'trivy-results.sarif'

      - name: Upload Trivy scan results to GitHub Security tab
        uses: github/codeql-action/upload-sarif@v2
        with:
          sarif_file: 'trivy-results.sarif'

  deploy-staging:
    if: github.ref == 'refs/heads/staging'
    needs: [test, security-scan]
    runs-on: ubuntu-latest
    environment: staging
    steps:
      - uses: actions/checkout@v4
      
      - name: Deploy Backend to Railway (Staging)
        run: |
          npm install -g @railway/cli
          cd noemi-medusa-backend
          railway login --token ${{ secrets.RAILWAY_TOKEN_STAGING }}
          railway deploy --service backend
      
      - name: Run Database Migrations
        run: |
          cd noemi-medusa-backend
          railway run npx medusa db:migrate
        env:
          RAILWAY_TOKEN: ${{ secrets.RAILWAY_TOKEN_STAGING }}
      
      - name: Deploy Frontend to Netlify (Staging)
        uses: nwtgck/actions-netlify@v2
        with:
          publish-dir: './noemi-medusa-storefront/.next'
          production-deploy: false
          alias: pr-${{ github.event.number }}
        env:
          NETLIFY_AUTH_TOKEN: ${{ secrets.NETLIFY_AUTH_TOKEN }}
          NETLIFY_SITE_ID: ${{ secrets.NETLIFY_SITE_ID_STAGING }}

  deploy-production:
    if: github.ref == 'refs/heads/main'
    needs: [test, security-scan]
    runs-on: ubuntu-latest
    environment: production
    steps:
      - uses: actions/checkout@v4
      
      - name: Deploy Backend to Railway (Production)
        run: |
          npm install -g @railway/cli
          cd noemi-medusa-backend
          railway login --token ${{ secrets.RAILWAY_TOKEN_PRODUCTION }}
          railway deploy --service backend --environment production
      
      - name: Run Database Migrations
        run: |
          cd noemi-medusa-backend
          railway run npx medusa db:migrate
        env:
          RAILWAY_TOKEN: ${{ secrets.RAILWAY_TOKEN_PRODUCTION }}
      
      - name: Deploy Frontend to Netlify (Production)
        uses: nwtgck/actions-netlify@v2
        with:
          publish-dir: './noemi-medusa-storefront/.next'
          production-deploy: true
        env:
          NETLIFY_AUTH_TOKEN: ${{ secrets.NETLIFY_AUTH_TOKEN }}
          NETLIFY_SITE_ID: ${{ secrets.NETLIFY_SITE_ID_PRODUCTION }}

      - name: Notify deployment success
        uses: 8398a7/action-slack@v3
        with:
          status: success
          channel: '#deployments'
        env:
          SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK_URL }}

  performance-test:
    if: github.ref == 'refs/heads/main'
    needs: deploy-production
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Install Lighthouse CI
        run: npm install -g @lhci/cli@0.12.x
      
      - name: Run Lighthouse
        run: lhci autorun
        env:
          LHCI_GITHUB_APP_TOKEN: ${{ secrets.LHCI_GITHUB_APP_TOKEN }}
```

### Required GitHub Secrets

```bash
# Repository secrets to add in GitHub:
RAILWAY_TOKEN_STAGING=your-railway-staging-token
RAILWAY_TOKEN_PRODUCTION=your-railway-production-token
NETLIFY_AUTH_TOKEN=your-netlify-auth-token
NETLIFY_SITE_ID_STAGING=your-netlify-staging-site-id
NETLIFY_SITE_ID_PRODUCTION=your-netlify-production-site-id
NEXT_PUBLIC_MEDUSA_BACKEND_URL=https://api.your-domain.com
NEXT_PUBLIC_MEDUSA_PUBLISHABLE_KEY=pk_live_your_key
SLACK_WEBHOOK_URL=your-slack-webhook-url
LHCI_GITHUB_APP_TOKEN=your-lighthouse-token
```

## SSL Certificate Management

### Let's Encrypt with Certbot

```bash
# Install Certbot
sudo apt-get update
sudo apt-get install certbot python3-certbot-nginx

# Generate certificate
sudo certbot --nginx -d your-domain.com -d www.your-domain.com -d api.your-domain.com

# Auto-renewal setup
sudo crontab -e
# Add: 0 12 * * * /usr/bin/certbot renew --quiet
```

### Cloudflare SSL/TLS Configuration

```bash
# Using Cloudflare API to manage SSL
curl -X POST "https://api.cloudflare.com/client/v4/zones/zone-id/ssl/verification" \
  -H "Authorization: Bearer your-api-token" \
  -H "Content-Type: application/json" \
  --data '{
    "validation_method": "http",
    "validation_errors": []
  }'
```

## Database Optimization

### PostgreSQL Performance Tuning

```sql
-- Recommended PostgreSQL settings for production
-- Add to postgresql.conf

shared_buffers = '256MB'          -- 25% of total RAM
effective_cache_size = '1GB'      -- 75% of total RAM
work_mem = '4MB'                  -- RAM / max_connections
maintenance_work_mem = '64MB'     -- RAM / 16
checkpoint_segments = 32
checkpoint_completion_target = 0.7
wal_buffers = '16MB'
default_statistics_target = 100

-- Connection pooling settings
max_connections = 100
shared_preload_libraries = 'pg_stat_statements'

-- Enable query optimization
log_statement = 'all'
log_duration = on
log_min_duration_statement = 1000
```

### Database Indexing Strategy

```sql
-- Essential indexes for Medusa tables
CREATE INDEX CONCURRENTLY idx_product_status ON product(status) WHERE status IS NOT NULL;
CREATE INDEX CONCURRENTLY idx_product_created_at ON product(created_at);
CREATE INDEX CONCURRENTLY idx_product_updated_at ON product(updated_at);

CREATE INDEX CONCURRENTLY idx_order_status ON "order"(status) WHERE status IS NOT NULL;
CREATE INDEX CONCURRENTLY idx_order_created_at ON "order"(created_at);
CREATE INDEX CONCURRENTLY idx_order_customer_id ON "order"(customer_id) WHERE customer_id IS NOT NULL;

CREATE INDEX CONCURRENTLY idx_customer_email ON customer(email);
CREATE INDEX CONCURRENTLY idx_customer_created_at ON customer(created_at);

-- Composite indexes for common queries
CREATE INDEX CONCURRENTLY idx_product_status_created ON product(status, created_at) WHERE status IS NOT NULL;
CREATE INDEX CONCURRENTLY idx_order_status_created ON "order"(status, created_at) WHERE status IS NOT NULL;

-- Text search indexes
CREATE INDEX CONCURRENTLY idx_product_title_gin ON product USING gin(to_tsvector('english', title));
CREATE INDEX CONCURRENTLY idx_product_description_gin ON product USING gin(to_tsvector('english', description));
```

## Backup and Disaster Recovery

### Database Backup Strategy

```bash
#!/bin/bash
# backup-database.sh

set -e

# Configuration
DB_NAME="medusav2"
BACKUP_DIR="/backups/postgresql"
RETENTION_DAYS=30
S3_BUCKET="noemi-backups"

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Generate backup filename
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="$BACKUP_DIR/${DB_NAME}_backup_$TIMESTAMP.sql"

# Create database dump
pg_dump "$DATABASE_URL" > "$BACKUP_FILE"

# Compress backup
gzip "$BACKUP_FILE"
BACKUP_FILE="$BACKUP_FILE.gz"

# Upload to S3
aws s3 cp "$BACKUP_FILE" "s3://$S3_BUCKET/database/"

# Remove local backup
rm "$BACKUP_FILE"

# Clean old backups from S3
aws s3 ls "s3://$S3_BUCKET/database/" --recursive | \
  awk '{print $4}' | \
  while read file; do
    if [[ $(date -d "$(echo $file | grep -oE '[0-9]{8}_[0-9]{6}')" +%s) -lt $(date -d "$RETENTION_DAYS days ago" +%s) ]]; then
      aws s3 rm "s3://$S3_BUCKET/$file"
# Clean old backups from S3 using LastModified metadata (requires jq)
CUTOFF_DATE=$(date -d "$RETENTION_DAYS days ago" --iso-8601=seconds)
aws s3api list-objects-v2 --bucket "$S3_BUCKET" --prefix "database/" --query 'Contents[?LastModified<=`'"$CUTOFF_DATE"'`]' --output json | \
  jq -r '.[].Key' | \
  while read file; do
    aws s3 rm "s3://$S3_BUCKET/$file"
  done

echo "Backup completed: $BACKUP_FILE"
```

### Application Code Backup

```bash
#!/bin/bash
# backup-application.sh

set -e

# Configuration
APP_DIR="/app"
BACKUP_DIR="/backups/application"
RETENTION_DAYS=7
S3_BUCKET="noemi-backups"

# Create backup
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="$BACKUP_DIR/application_backup_$TIMESTAMP.tar.gz"

mkdir -p "$BACKUP_DIR"

# Create tar backup excluding node_modules and logs
tar -czf "$BACKUP_FILE" \
  --exclude="node_modules" \
  --exclude="*.log" \
  --exclude=".git" \
  --exclude="dist" \
  --exclude=".next" \
  -C "$APP_DIR" .

# Upload to S3
aws s3 cp "$BACKUP_FILE" "s3://$S3_BUCKET/application/"

# Remove local backup
rm "$BACKUP_FILE"

echo "Application backup completed"
```

### Disaster Recovery Plan

```yaml
# disaster-recovery-plan.yml
recovery_scenarios:
  database_failure:
    steps:
      1. "Stop application services"
      2. "Restore latest database backup from S3"
      3. "Verify data integrity"
      4. "Start application services"
      5. "Run health checks"
    rto: "30 minutes"  # Recovery Time Objective
    rpo: "1 hour"      # Recovery Point Objective

  application_failure:
    steps:
      1. "Deploy last known good version"
      2. "Run database migrations if needed"
      3. "Verify application functionality"
      4. "Update monitoring alerts"
    rto: "15 minutes"
    rpo: "0 minutes"

  complete_infrastructure_failure:
    steps:
      1. "Provision new infrastructure using IaC"
      2. "Restore database from S3 backup"
      3. "Deploy application from git repository"
      4. "Configure DNS and SSL certificates"
      5. "Run full system tests"
    rto: "2 hours"
    rpo: "1 hour"

recovery_contacts:
  primary: "devops@noemi.com"
  secondary: "admin@noemi.com"
  escalation: "cto@noemi.com"
```

This comprehensive wiki covers all advanced deployment scenarios and configurations needed for a production-ready NOEMI e-commerce platform.