# eBuildify Backend Architecture & Implementation Guide

**BuildTech Solutions - Comprehensive Backend Design**  
**Client:** Sol Little By Little Enterprise  
**Project:** eBuildify Platform  
**Architecture:** Microservices with Monolithic API Gateway

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Technology Stack](#technology-stack)
3. [System Architecture Layers](#system-architecture-layers)
4. [Microservices Design](#microservices-design)
5. [Database Architecture](#database-architecture)
6. [API Gateway & Routing](#api-gateway--routing)
7. [Authentication & Authorization](#authentication--authorization)
8. [External Integrations](#external-integrations)
9. [Infrastructure & Deployment](#infrastructure--deployment)
10. [Monitoring & Observability](#monitoring--observability)
11. [Security Implementation](#security-implementation)
12. [Development Workflow](#development-workflow)

---

## Architecture Overview

### Architecture Pattern: **Modular Monolith → Microservices Evolution**

**Phase 1 (Launch):** Modular Monolith with clear service boundaries
**Phase 2 (Scale):** Extract to independent microservices

### Core Design Principles

- **Domain-Driven Design (DDD):** Business logic organized by domains
- **SOLID Principles:** Maintainable and extensible code
- **Event-Driven Architecture:** Async communication between services
- **API-First Design:** Contract-first development approach
- **Scalability by Design:** Horizontal scaling capabilities
- **Fault Tolerance:** Circuit breakers and graceful degradation

### System Context Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    eBuildify Ecosystem                      │
│                                                             │
│  Frontend (PWA) ←→ API Gateway ←→ Backend Services          │
│                           ↓                                 │
│                    Message Queue                            │
│                           ↓                                 │
│                   External Services                         │
│                (Payment, SMS, Email)                        │
└─────────────────────────────────────────────────────────────┘
```

---

## Technology Stack

### Core Backend Technologies

| Component | Technology | Version | Justification |
|-----------|------------|---------|---------------|
| **Runtime** | Node.js | 20.x LTS | Performance, ecosystem, JavaScript consistency |
| **Framework** | Express.js | 4.18+ | Mature, flexible, extensive middleware support |
| **Database** | PostgreSQL | 15+ | ACID compliance, JSON support, scalability |
| **ORM** | Prisma | 5.x | Type-safe, modern ORM with excellent migrations |
| **Cache** | Redis | 7.x | Session management, caching, pub/sub |
| **Message Queue** | Bull Queue | 4.x | Job processing, background tasks |
| **Authentication** | JWT + Passport.js | Latest | Stateless auth, multiple strategies |
| **Validation** | Joi | 17.x | Schema validation, error handling |
| **Testing** | Jest + Supertest | Latest | Unit and integration testing |
| **Documentation** | Swagger/OpenAPI | 3.0 | API documentation and testing |

### Supporting Technologies

| Component | Technology | Purpose |
|-----------|------------|---------|
| **File Storage** | AWS S3/DigitalOcean Spaces | Image and document storage |
| **Email Service** | SendGrid/AWS SES | Transactional emails |
| **SMS Service** | Twilio/Afrika's Talking | SMS notifications |
| **Payment Gateway** | Flutterwave | Payment processing |
| **Monitoring** | Winston + ELK Stack | Logging and monitoring |
| **Process Manager** | PM2 | Production process management |
| **API Gateway** | Express Gateway/Kong | Request routing and rate limiting |

---

## System Architecture Layers

### 1. Presentation Layer (API Layer)

```typescript
// API Structure
src/
├── routes/
│   ├── auth/
│   ├── users/
│   ├── products/
│   ├── orders/
│   ├── payments/
│   ├── services/
│   └── admin/
├── middleware/
│   ├── authentication.js
│   ├── authorization.js
│   ├── validation.js
│   ├── rateLimiting.js
│   └── errorHandling.js
└── controllers/
    ├── AuthController.js
    ├── UserController.js
    ├── ProductController.js
    └── OrderController.js
```

### 2. Business Logic Layer (Service Layer)

```typescript
// Service Layer Structure
src/
├── services/
│   ├── UserService.js
│   ├── ProductService.js
│   ├── OrderService.js
│   ├── PaymentService.js
│   ├── InventoryService.js
│   ├── DeliveryService.js
│   ├── CreditService.js
│   └── NotificationService.js
├── domain/
│   ├── entities/
│   ├── valueObjects/
│   └── aggregates/
└── usecases/
    ├── CreateOrder.js
    ├── ProcessPayment.js
    └── ManageInventory.js
```

### 3. Data Access Layer (Repository Pattern)

```typescript
// Repository Pattern Implementation
src/
├── repositories/
│   ├── UserRepository.js
│   ├── ProductRepository.js
│   ├── OrderRepository.js
│   └── BaseRepository.js
├── models/
│   ├── User.js
│   ├── Product.js
│   └── Order.js
└── database/
    ├── migrations/
    ├── seeders/
    └── config/
```

---

## Microservices Design

### Service Decomposition Strategy

#### Core Business Services

1. **User Management Service**
   - Authentication & Authorization
   - Profile Management
   - Ghana Card Verification
   - Address Management

2. **Product Catalog Service**
   - Product Management
   - Category Management
   - Search & Filtering
   - Inventory Sync

3. **Order Management Service**
   - Cart Management
   - Order Processing
   - Order Status Tracking
   - Bulk Pricing Logic

4. **Payment & Credit Service**
   - Payment Processing
   - Credit Account Management
   - Automated Payments
   - Financial Reporting

5. **Delivery & Logistics Service**
   - Delivery Zone Management
   - Route Optimization
   - Driver Assignment
   - Tracking & Updates

6. **Service Booking Service**
   - Consultancy Booking
   - Consultant Management
   - Project Management
   - Service Delivery

7. **Notification Service**
   - Email Notifications
   - SMS Notifications
   - Push Notifications
   - Notification Templates

#### Service Communication Patterns

```typescript
// Event-Driven Communication Example
// Order Service publishes event
eventBus.publish('order.created', {
  orderId: 'uuid-123',
  customerId: 'uuid-456',
  total: 2275.00,
  items: [...]
});

// Inventory Service subscribes
eventBus.subscribe('order.created', async (event) => {
  await inventoryService.reserveStock(event.items);
});

// Notification Service subscribes
eventBus.subscribe('order.created', async (event) => {
  await notificationService.sendOrderConfirmation(event);
});
```

### Service Boundaries & Data Ownership

```
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│  User Service   │  │ Product Service │  │  Order Service  │
│                 │  │                 │  │                 │
│ - users         │  │ - products      │  │ - orders        │
│ - user_profiles │  │ - categories    │  │ - order_items   │
│ - addresses     │  │ - inventory     │  │ - cart_items    │
└─────────────────┘  └─────────────────┘  └─────────────────┘
```

---

## Database Architecture

### Database Per Service Pattern

```sql
-- User Service Database
CREATE DATABASE ebuildify_users;

-- Product Service Database  
CREATE DATABASE ebuildify_products;

-- Order Service Database
CREATE DATABASE ebuildify_orders;

-- Payment Service Database
CREATE DATABASE ebuildify_payments;

-- Shared Analytics Database
CREATE DATABASE ebuildify_analytics;
```

### Data Consistency Strategies

#### 1. Eventual Consistency with Saga Pattern

```typescript
// Order Processing Saga
class OrderProcessingSaga {
  async execute(orderData) {
    const saga = new Saga();
    
    try {
      // Step 1: Create Order
      const order = await saga.step('createOrder', 
        () => orderService.createOrder(orderData),
        () => orderService.cancelOrder(order.id)
      );
      
      // Step 2: Reserve Inventory
      await saga.step('reserveInventory',
        () => inventoryService.reserveStock(order.items),
        () => inventoryService.releaseStock(order.items)
      );
      
      // Step 3: Process Payment
      await saga.step('processPayment',
        () => paymentService.processPayment(order.payment),
        () => paymentService.refundPayment(order.payment)
      );
      
      return order;
    } catch (error) {
      await saga.compensate();
      throw error;
    }
  }
}
```

#### 2. Database Synchronization

```typescript
// Event-Sourced Data Sync
class DataSynchronizer {
  async syncUserData(userId) {
    const user = await userService.getUser(userId);
    
    // Sync to Order Service
    await orderService.updateCustomerInfo(userId, {
      name: `${user.firstName} ${user.lastName}`,
      email: user.email,
      phone: user.phoneNumber
    });
    
    // Sync to Analytics
    await analyticsService.updateCustomerProfile(userId, user);
  }
}
```

---

## API Gateway & Routing

### Request Flow Architecture

```
Client Request → Load Balancer → API Gateway → Service Router → Microservice
                                      ↓
                               Rate Limiting
                               Authentication
                               Request Validation
                               Response Caching
```

### API Gateway Implementation

```typescript
// Express Gateway Configuration
const gateway = require('express-gateway');

gateway()
  .load(path.join(__dirname, 'models'))
  .load(path.join(__dirname, 'policies'))
  .load(path.join(__dirname, 'pipelines'))
  .run({
    config: {
      http: { port: 8080 },
      https: { port: 8443 },
      serviceEndpoints: {
        userService: { url: 'http://user-service:3001' },
        productService: { url: 'http://product-service:3002' },
        orderService: { url: 'http://order-service:3003' }
      },
      policies: ['cors', 'jwt', 'rate-limit', 'request-size-limit'],
      pipelines: {
        api: {
          apiEndpoints: ['api'],
          policies: [
            { cors: null },
            { jwt: null },
            { rate-limit: { max: 100, windowMs: 60000 } }
          ]
        }
      }
    }
  });
```

### Service Discovery & Load Balancing

```typescript
// Service Registry Implementation
class ServiceRegistry {
  constructor() {
    this.services = new Map();
  }

  register(serviceName, instances) {
    this.services.set(serviceName, instances);
  }

  discover(serviceName) {
    const instances = this.services.get(serviceName) || [];
    return this.loadBalance(instances);
  }

  loadBalance(instances) {
    // Round-robin load balancing
    const index = Math.floor(Math.random() * instances.length);
    return instances[index];
  }
}
```

---

## Authentication & Authorization

### JWT-Based Authentication Flow

```typescript
// Authentication Middleware
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ 
      success: false, 
      error: { code: 'UNAUTHORIZED', message: 'Access token required' }
    });
  }

  jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
    if (err) {
      return res.status(403).json({ 
        success: false, 
        error: { code: 'FORBIDDEN', message: 'Invalid or expired token' }
      });
    }
    req.user = user;
    next();
  });
};
```

### Role-Based Access Control (RBAC)

```typescript
// Permission System
class PermissionManager {
  constructor() {
    this.permissions = {
      'admin': ['*'],
      'customer': ['order:create', 'order:read', 'profile:update'],
      'contractor': ['order:create', 'order:read', 'credit:apply'],
      'driver': ['delivery:update', 'order:read'],
      'consultant': ['booking:read', 'booking:update']
    };
  }

  hasPermission(userRole, action) {
    const rolePermissions = this.permissions[userRole] || [];
    return rolePermissions.includes('*') || rolePermissions.includes(action);
  }
}

// Authorization Middleware
const authorize = (action) => {
  return (req, res, next) => {
    const userRole = req.user.userType;
    
    if (!permissionManager.hasPermission(userRole, action)) {
      return res.status(403).json({
        success: false,
        error: { code: 'FORBIDDEN', message: 'Insufficient permissions' }
      });
    }
    
    next();
  };
};
```

---

## External Integrations

### Payment Gateway Integration

```typescript
// Flutterwave Payment Service
class FlutterwaveService {
  constructor() {
    this.flw = new Flutterwave(
      process.env.FLW_PUBLIC_KEY,
      process.env.FLW_SECRET_KEY
    );
  }

  async initializePayment(orderData) {
    const payload = {
      tx_ref: orderData.orderId,
      amount: orderData.amount,
      currency: 'GHS',
      redirect_url: process.env.PAYMENT_CALLBACK_URL,
      customer: {
        email: orderData.customerEmail,
        phonenumber: orderData.customerPhone,
        name: orderData.customerName
      },
      customizations: {
        title: 'eBuildify Payment',
        description: `Payment for order ${orderData.orderNumber}`
      }
    };

    try {
      const response = await this.flw.StandardSubaccount.charge(payload);
      return {
        success: true,
        paymentUrl: response.data.link,
        reference: response.data.tx_ref
      };
    } catch (error) {
      throw new PaymentError('Payment initialization failed', error);
    }
  }

  async verifyPayment(transactionId) {
    try {
      const response = await this.flw.Transaction.verify({ id: transactionId });
      return {
        success: response.data.status === 'successful',
        amount: response.data.amount,
        currency: response.data.currency,
        reference: response.data.tx_ref
      };
    } catch (error) {
      throw new PaymentError('Payment verification failed', error);
    }
  }
}
```

### Ghana Card Verification Integration

```typescript
// Ghana Card Verification Service
class GhanaCardService {
  async verifyGhanaCard(cardNumber, personalInfo) {
    // Integration with Ghana Card API (when available)
    // For now, implement basic validation
    
    const isValidFormat = this.validateCardFormat(cardNumber);
    if (!isValidFormat) {
      throw new ValidationError('Invalid Ghana Card format');
    }

    // Store verification attempt
    await this.logVerificationAttempt(cardNumber, personalInfo);
    
    // Simulate verification process
    return {
      verified: true,
      cardNumber: cardNumber,
      verificationId: uuid.v4(),
      verifiedAt: new Date()
    };
  }

  validateCardFormat(cardNumber) {
    const ghanaCardRegex = /^GHA-\d{9}-\d$/;
    return ghanaCardRegex.test(cardNumber);
  }
}
```

### SMS/Email Notification Integration

```typescript
// Notification Service
class NotificationService {
  constructor() {
    this.smsService = new TwilioService();
    this.emailService = new SendGridService();
  }

  async sendOrderConfirmation(order) {
    const customer = await userService.getUser(order.customerId);
    
    // Send SMS
    await this.smsService.sendSMS({
      to: customer.phoneNumber,
      message: `Order ${order.orderNumber} confirmed. Total: GHS ${order.totalAmount}`
    });

    // Send Email
    await this.emailService.sendEmail({
      to: customer.email,
      subject: `Order Confirmation - ${order.orderNumber}`,
      template: 'order-confirmation',
      data: { order, customer }
    });
  }

  async sendCreditReminder(creditTransaction) {
    const customer = await userService.getUser(creditTransaction.customerId);
    
    const message = `Reminder: Your credit payment of GHS ${creditTransaction.amount} is due on ${creditTransaction.dueDate}`;
    
    await Promise.all([
      this.smsService.sendSMS({ to: customer.phoneNumber, message }),
      this.emailService.sendEmail({
        to: customer.email,
        subject: 'Credit Payment Reminder',
        template: 'credit-reminder',
        data: { creditTransaction, customer }
      })
    ]);
  }
}
```

---

## Infrastructure & Deployment

### Container Architecture (Docker)

```dockerfile
# Base Node.js Image
FROM node:20-alpine

WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm ci --only=production

# Copy application code
COPY . .

# Create non-root user
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nextjs -u 1001

USER nextjs

EXPOSE 3000

CMD ["npm", "start"]
```

### Docker Compose for Development

```yaml
version: '3.8'
services:
  # API Gateway
  api-gateway:
    build: ./api-gateway
    ports:
      - "8080:8080"
    environment:
      - NODE_ENV=development
    depends_on:
      - user-service
      - product-service
      - order-service

  # User Service
  user-service:
    build: ./services/user-service
    environment:
      - DATABASE_URL=postgresql://user:pass@user-db:5432/ebuildify_users
      - REDIS_URL=redis://redis:6379
    depends_on:
      - user-db
      - redis

  # Product Service
  product-service:
    build: ./services/product-service
    environment:
      - DATABASE_URL=postgresql://user:pass@product-db:5432/ebuildify_products
    depends_on:
      - product-db

  # Databases
  user-db:
    image: postgres:15
    environment:
      - POSTGRES_DB=ebuildify_users
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=pass
    volumes:
      - user-db-data:/var/lib/postgresql/data

  product-db:
    image: postgres:15
    environment:
      - POSTGRES_DB=ebuildify_products
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=pass
    volumes:
      - product-db-data:/var/lib/postgresql/data

  # Redis for caching and sessions
  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"

volumes:
  user-db-data:
  product-db-data:
```

### Production Deployment (Kubernetes)

```yaml
# API Gateway Deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ebuildify-api-gateway
spec:
  replicas: 3
  selector:
    matchLabels:
      app: api-gateway
  template:
    metadata:
      labels:
        app: api-gateway
    spec:
      containers:
      - name: api-gateway
        image: ebuildify/api-gateway:latest
        ports:
        - containerPort: 8080
        env:
        - name: NODE_ENV
          value: "production"
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
---
apiVersion: v1
kind: Service
metadata:
  name: api-gateway-service
spec:
  selector:
    app: api-gateway
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
  type: LoadBalancer
```

---

## Monitoring & Observability

### Application Monitoring

```typescript
// Monitoring Setup
const winston = require('winston');
const prometheus = require('prom-client');

// Metrics Collection
const httpRequestDuration = new prometheus.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status']
});

const activeConnections = new prometheus.Gauge({
  name: 'active_connections',
  help: 'Number of active connections'
});

// Logging Configuration
const logger = winston.createLogger({
  level: 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.errors({ stack: true }),
    winston.format.json()
  ),
  transports: [
    new winston.transports.File({ filename: 'error.log', level: 'error' }),
    new winston.transports.File({ filename: 'combined.log' })
  ]
});

// Health Check Endpoint
app.get('/health', (req, res) => {
  const healthCheck = {
    uptime: process.uptime(),
    message: 'OK',
    timestamp: Date.now(),
    checks: {
      database: 'OK',
      redis: 'OK',
      externalServices: 'OK'
    }
  };
  
  res.status(200).json(healthCheck);
});
```

### Error Tracking & Alerting

```typescript
// Error Tracking Service
class ErrorTracker {
  static track(error, context = {}) {
    logger.error('Application Error', {
      message: error.message,
      stack: error.stack,
      context,
      timestamp: new Date().toISOString()
    });

    // Send to external monitoring service (e.g., Sentry)
    if (process.env.NODE_ENV === 'production') {
      Sentry.captureException(error, { extra: context });
    }
  }

  static async checkSystemHealth() {
    const checks = await Promise.allSettled([
      this.checkDatabase(),
      this.checkRedis(),
      this.checkExternalServices()
    ]);

    const healthStatus = {
      status: 'healthy',
      checks: {}
    };

    checks.forEach((check, index) => {
      const serviceName = ['database', 'redis', 'external'][index];
      healthStatus.checks[serviceName] = {
        status: check.status === 'fulfilled' ? 'healthy' : 'unhealthy',
        message: check.status === 'fulfilled' ? 'OK' : check.reason.message
      };

      if (check.status === 'rejected') {
        healthStatus.status = 'unhealthy';
      }
    });

    return healthStatus;
  }
}
```

---

## Security Implementation

### Data Encryption & Protection

```typescript
// Encryption Service
const crypto = require('crypto');

class EncryptionService {
  constructor() {
    this.algorithm = 'aes-256-gcm';
    this.secretKey = process.env.ENCRYPTION_KEY;
  }

  encrypt(text) {
    const iv = crypto.randomBytes(16);
    const cipher = crypto.createCipher(this.algorithm, this.secretKey, iv);
    
    let encrypted = cipher.update(text, 'utf8', 'hex');
    encrypted += cipher.final('hex');
    
    const authTag = cipher.getAuthTag();
    
    return {
      encrypted: encrypted,
      iv: iv.toString('hex'),
      authTag: authTag.toString('hex')
    };
  }

  decrypt(encryptedData) {
    const decipher = crypto.createDecipher(
      this.algorithm, 
      this.secretKey, 
      Buffer.from(encryptedData.iv, 'hex')
    );
    
    decipher.setAuthTag(Buffer.from(encryptedData.authTag, 'hex'));
    
    let decrypted = decipher.update(encryptedData.encrypted, 'hex', 'utf8');
    decrypted += decipher.final('utf8');
    
    return decrypted;
  }
}

// Ghana Card Data Protection
class GhanaCardProtection {
  static async storeGhanaCardData(userId, ghanaCardData) {
    const encryptionService = new EncryptionService();
    
    const encryptedData = encryptionService.encrypt(ghanaCardData.cardNumber);
    
    await db.users.update({
      where: { userId },
      data: {
        ghanaCardNumber: encryptedData.encrypted,
        ghanaCardIv: encryptedData.iv,
        ghanaCardAuthTag: encryptedData.authTag,
        ghanaCardVerified: true
      }
    });

    // Log access for audit
    await auditLogger.log({
      action: 'GHANA_CARD_STORED',
      userId,
      timestamp: new Date(),
      ipAddress: req.ip
    });
  }
}
```

### Input Validation & Sanitization

```typescript
// Validation Schemas
const Joi = require('joi');

const validationSchemas = {
  user: {
    register: Joi.object({
      email: Joi.string().email().required(),
      phoneNumber: Joi.string().pattern(/^\+233[0-9]{9}$/).required(),
      password: Joi.string().min(8).pattern(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/).required(),
      firstName: Joi.string().min(2).max(50).required(),
      lastName: Joi.string().min(2).max(50).required(),
      ghanaCardNumber: Joi.string().pattern(/^GHA-\d{9}-\d$/).required(),
      dateOfBirth: Joi.date().max('now').required()
    }),
    
    login: Joi.object({
      email: Joi.string().email().required(),
      password: Joi.string().required()
    })
  },

  order: {
    create: Joi.object({
      items: Joi.array().items(
        Joi.object({
          productId: Joi.string().uuid().required(),
          quantity: Joi.number().integer().min(1).required()
        })
      ).min(1).required(),
      deliveryAddress: Joi.object({
        addressLine1: Joi.string().required(),
        city: Joi.string().required(),
        region: Joi.string().required(),
        latitude: Joi.number().min(-90).max(90),
        longitude: Joi.number().min(-180).max(180)
      }).required()
    })
  }
};

// Validation Middleware
const validate = (schema) => {
  return (req, res, next) => {
    const { error } = schema.validate(req.body);
    
    if (error) {
      return res.status(400).json({
        success: false,
        error: {
          code: 'VALIDATION_ERROR',
          message: 'Invalid input data',
          details: error.details.map(detail => ({
            field: detail.path.join('.'),
            message: detail.message
          }))
        }
      });
    }
    
    next();
  };
};
```

---

## Development Workflow

### Project Structure

```
ebuildify-backend/
├── src/
│   ├── api/
│   │   ├── routes/
│   │   ├── controllers/
│   │   └── middleware/
│   ├── services/
│   │   ├── UserService.js
│   │   ├── ProductService.js
│   │   └── OrderService.js
│   ├── repositories/
│   ├── models/
│   ├── utils/
│   ├── config/
│   └── tests/
├── docker/
├── scripts/
├── docs/
├── package.json
├── Dockerfile
└── docker-compose.yml
```

### Development Environment Setup

```bash
# Environment Setup Script
#!/bin/bash

echo "Setting up eBuildify Backend Development Environment..."

# Install dependencies
npm install

# Setup environment variables
cp .env.example .env

# Setup database
docker-compose up -d postgres redis

# Wait for database to be ready
sleep 10

# Run migrations
npm run migrate

# Seed initial data
npm run seed

# Start development server
npm run dev

echo "Development environment ready at http://localhost:3000"
```

### Testing Strategy

```typescript
// Test Configuration
// jest.config.js
module.exports = {
  testEnvironment: 'node',
  setupFilesAfterEnv: ['<rootDir>/src/tests/setup.js'],
  testMatch: ['**/__tests__/**/*.js', '**/?(*.)+(spec|test).js'],
  collectCoverageFrom: [
    'src/**/*.js',
    '!src/tests/**',
    '!src/config/**'
  ],
  coverageThreshold: {
    global: {
      branches: 80,
      functions: 80,
      lines: 80,
      statements: 80
    }
  }
};

// Integration Test Example
describe('Order Management API', () => {
  beforeEach(async () => {
    await setupTestDatabase();
  });

  afterEach(async () => {
    await cleanupTestDatabase();
  });

  test('should create order with bulk discount', async () => {
    const user = await createTestUser();
    const product = await createTestProduct({ isBulkItem: true });
    
    const orderData = {
      items: [{ productId: product.id, quantity: 150 }],
      deliveryAddress: testAddress
    };

    const response = await request(app)
      .post('/api/v1/orders')
      .set('Authorization', `Bearer ${user.token}`)
      .send(orderData)
      .expect(201);

    expect(response.body.success).toBe(true);
    expect(response.body.data.discountAmount).toBeGreaterThan(0);
  });
});
```

### CI/CD Pipeline

```yaml
# .github/workflows/backend.yml
name: Backend CI/CD

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

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
      
      redis:
        image: redis:7-alpine
        options: >-
          --health-cmd "redis-cli ping"
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 6379:6379

    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Node.js
      uses: actions/setup-node@v3
      with:
        node-version: '20'
        cache: 'npm'
    
    - name: Install dependencies
      run: npm ci
    
    - name: Run linting
      run: npm run lint
    
    - name: Run unit tests
      run: npm run test:unit
      env:
        NODE_ENV: test
        DATABASE_URL: postgresql://postgres:postgres@localhost:5432/test_db
        REDIS_URL: redis://localhost:6379
    
    - name: Run integration tests
      run: npm run test:integration
      env:
        NODE_ENV: test
        DATABASE_URL: postgresql://postgres:postgres@localhost:5432/test_db
        REDIS_URL: redis://localhost:6379
    
    - name: Generate coverage report
      run: npm run test:coverage
    
    - name: Upload coverage to Codecov
      uses: codecov/codecov-action@v3

  build:
    needs: test
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v2
    
    - name: Login to Container Registry
      uses: docker/login-action@v2
      with:
        registry: ghcr.io
        username: ${{ github.actor }}
        password: ${{ secrets.GITHUB_TOKEN }}
    
    - name: Build and push Docker image
      uses: docker/build-push-action@v4
      with:
        context: .
        push: true
        tags: |
          ghcr.io/buildtech/ebuildify-backend:latest
          ghcr.io/buildtech/ebuildify-backend:${{ github.sha }}

  deploy:
    needs: build
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    
    steps:
    - name: Deploy to production
      run: |
        echo "Deploying to production environment"
        # Add deployment scripts here
```

---

## Performance Optimization Strategies

### Database Optimization

```typescript
// Database Connection Pool Configuration
const { Pool } = require('pg');

const pool = new Pool({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  max: 20, // Maximum number of connections
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
  maxUses: 7500, // Close connection after 7500 uses
});

// Query Optimization Examples
class OptimizedQueries {
  // Efficient product search with pagination
  static async searchProducts(filters, pagination) {
    const query = `
      SELECT 
        p.product_id,
        p.product_name,
        p.unit_price,
        p.brand,
        pc.category_name,
        i.available_stock,
        (SELECT image_url FROM product_images pi 
         WHERE pi.product_id = p.product_id AND pi.is_primary = true 
         LIMIT 1) as primary_image
      FROM products p
      JOIN product_categories pc ON p.category_id = pc.category_id
      JOIN inventory i ON p.product_id = i.product_id
      WHERE p.is_active = true
        AND ($1::uuid IS NULL OR p.category_id = $1)
        AND ($2::text IS NULL OR p.product_name ILIKE $2)
        AND ($3::decimal IS NULL OR p.unit_price >= $3)
        AND ($4::decimal IS NULL OR p.unit_price <= $4)
        AND ($5::boolean IS NULL OR i.available_stock > 0)
      ORDER BY 
        CASE WHEN $6 = 'name' THEN p.product_name END ASC,
        CASE WHEN $6 = 'price' AND $7 = 'asc' THEN p.unit_price END ASC,
        CASE WHEN $6 = 'price' AND $7 = 'desc' THEN p.unit_price END DESC,
        p.created_at DESC
      LIMIT $8 OFFSET $9
    `;
    
    const offset = (pagination.page - 1) * pagination.limit;
    
    return await pool.query(query, [
      filters.categoryId,
      filters.search ? `%${filters.search}%` : null,
      filters.minPrice,
      filters.maxPrice,
      filters.inStock,
      pagination.sortBy,
      pagination.sortOrder,
      pagination.limit,
      offset
    ]);
  }

  // Efficient order history with aggregations
  static async getCustomerOrderHistory(customerId, pagination) {
    const query = `
      WITH order_totals AS (
        SELECT 
          o.order_id,
          o.order_number,
          o.total_amount,
          o.order_status,
          o.order_placed_at,
          COUNT(oi.order_item_id) as item_count,
          STRING_AGG(DISTINCT pc.category_name, ', ') as categories
        FROM orders o
        JOIN order_items oi ON o.order_id = oi.order_id
        JOIN products p ON oi.product_id = p.product_id
        JOIN product_categories pc ON p.category_id = pc.category_id
        WHERE o.customer_id = $1
        GROUP BY o.order_id, o.order_number, o.total_amount, o.order_status, o.order_placed_at
      )
      SELECT *,
        COUNT(*) OVER() as total_count
      FROM order_totals
      ORDER BY order_placed_at DESC
      LIMIT $2 OFFSET $3
    `;
    
    const offset = (pagination.page - 1) * pagination.limit;
    return await pool.query(query, [customerId, pagination.limit, offset]);
  }
}
```

### Caching Strategy Implementation

```typescript
// Redis Caching Service
const Redis = require('redis');

class CacheService {
  constructor() {
    this.client = Redis.createClient({
      url: process.env.REDIS_URL,
      retry_strategy: (options) => {
        if (options.error && options.error.code === 'ECONNREFUSED') {
          return new Error('Redis server connection refused');
        }
        if (options.total_retry_time > 1000 * 60 * 60) {
          return new Error('Retry time exhausted');
        }
        if (options.attempt > 10) {
          return undefined;
        }
        return Math.min(options.attempt * 100, 3000);
      }
    });
  }

  async get(key) {
    try {
      const value = await this.client.get(key);
      return value ? JSON.parse(value) : null;
    } catch (error) {
      console.error('Cache get error:', error);
      return null;
    }
  }

  async set(key, value, ttl = 3600) {
    try {
      await this.client.setex(key, ttl, JSON.stringify(value));
    } catch (error) {
      console.error('Cache set error:', error);
    }
  }

  async invalidate(pattern) {
    try {
      const keys = await this.client.keys(pattern);
      if (keys.length > 0) {
        await this.client.del(keys);
      }
    } catch (error) {
      console.error('Cache invalidate error:', error);
    }
  }
}

// Cache Decorator for Service Methods
function cached(ttl = 3600, keyGenerator) {
  return function(target, propertyName, descriptor) {
    const method = descriptor.value;
    
    descriptor.value = async function(...args) {
      const cacheKey = keyGenerator ? keyGenerator(...args) : `${propertyName}:${JSON.stringify(args)}`;
      
      // Try to get from cache
      let result = await cacheService.get(cacheKey);
      
      if (result === null) {
        // Execute original method
        result = await method.apply(this, args);
        
        // Store in cache
        await cacheService.set(cacheKey, result, ttl);
      }
      
      return result;
    };
  };
}

// Usage Example
class ProductService {
  @cached(1800, (filters) => `products:search:${JSON.stringify(filters)}`)
  async searchProducts(filters) {
    return await productRepository.search(filters);
  }

  @cached(3600, (categoryId) => `products:category:${categoryId}`)
  async getProductsByCategory(categoryId) {
    return await productRepository.findByCategory(categoryId);
  }
}
```

---

## Background Job Processing

### Job Queue Implementation

```typescript
// Job Queue Setup with Bull
const Queue = require('bull');
const redis = require('redis');

// Initialize job queues
const emailQueue = new Queue('email processing', process.env.REDIS_URL);
const smsQueue = new Queue('sms processing', process.env.REDIS_URL);
const inventoryQueue = new Queue('inventory sync', process.env.REDIS_URL);
const analyticsQueue = new Queue('analytics processing', process.env.REDIS_URL);

// Email Job Processor
emailQueue.process('send-email', async (job) => {
  const { to, subject, template, data } = job.data;
  
  try {
    await emailService.sendEmail({
      to,
      subject,
      template,
      data
    });
    
    console.log(`Email sent successfully to ${to}`);
    return { success: true, recipient: to };
  } catch (error) {
    console.error('Email sending failed:', error);
    throw error;
  }
});

// SMS Job Processor
smsQueue.process('send-sms', async (job) => {
  const { to, message } = job.data;
  
  try {
    await smsService.sendSMS({ to, message });
    console.log(`SMS sent successfully to ${to}`);
    return { success: true, recipient: to };
  } catch (error) {
    console.error('SMS sending failed:', error);
    throw error;
  }
});

// Inventory Sync Job Processor
inventoryQueue.process('sync-inventory', async (job) => {
  try {
    await inventoryService.syncWithGoogleSheets();
    console.log('Inventory sync completed');
    return { success: true, syncedAt: new Date() };
  } catch (error) {
    console.error('Inventory sync failed:', error);
    throw error;
  }
});

// Job Scheduling Service
class JobScheduler {
  static async scheduleEmail(emailData, delay = 0) {
    return await emailQueue.add('send-email', emailData, {
      delay,
      attempts: 3,
      backoff: {
        type: 'exponential',
        delay: 2000,
      },
    });
  }

  static async scheduleSMS(smsData, delay = 0) {
    return await smsQueue.add('send-sms', smsData, {
      delay,
      attempts: 3,
      backoff: {
        type: 'exponential',
        delay: 2000,
      },
    });
  }

  static async scheduleInventorySync() {
    return await inventoryQueue.add('sync-inventory', {}, {
      repeat: { cron: '0 */6 * * *' }, // Every 6 hours
      attempts: 2,
    });
  }

  static async scheduleCreditReminders() {
    // Find all credit transactions due in 3 days
    const upcomingDueTransactions = await creditService.getUpcomingDueTransactions(3);
    
    for (const transaction of upcomingDueTransactions) {
      await this.scheduleEmail({
        to: transaction.customer.email,
        subject: 'Credit Payment Reminder',
        template: 'credit-reminder',
        data: { transaction }
      });
      
      await this.scheduleSMS({
        to: transaction.customer.phoneNumber,
        message: `Reminder: Your credit payment of GHS ${transaction.amount} is due on ${transaction.dueDate}`
      });
    }
  }
}

// Recurring Job Setup
const setupRecurringJobs = () => {
  // Daily credit reminder check
  emailQueue.add('credit-reminders', {}, {
    repeat: { cron: '0 9 * * *' }, // 9 AM daily
  });

  // Hourly inventory sync
  inventoryQueue.add('sync-inventory', {}, {
    repeat: { cron: '0 * * * *' }, // Every hour
  });

  // Daily analytics processing
  analyticsQueue.add('process-daily-analytics', {}, {
    repeat: { cron: '0 2 * * *' }, // 2 AM daily
  });
};
```

---

## Error Handling & Resilience

### Circuit Breaker Pattern

```typescript
// Circuit Breaker Implementation
class CircuitBreaker {
  constructor(options = {}) {
    this.failureThreshold = options.failureThreshold || 5;
    this.timeout = options.timeout || 60000; // 1 minute
    this.resetTimeout = options.resetTimeout || 30000; // 30 seconds
    
    this.state = 'CLOSED'; // CLOSED, OPEN, HALF_OPEN
    this.failureCount = 0;
    this.lastFailureTime = null;
    this.nextAttempt = null;
  }

  async execute(operation) {
    if (this.state === 'OPEN') {
      if (Date.now() < this.nextAttempt) {
        throw new Error('Circuit breaker is OPEN');
      } else {
        this.state = 'HALF_OPEN';
      }
    }

    try {
      const result = await Promise.race([
        operation(),
        this.timeoutPromise()
      ]);
      
      this.onSuccess();
      return result;
    } catch (error) {
      this.onFailure();
      throw error;
    }
  }

  onSuccess() {
    this.failureCount = 0;
    this.state = 'CLOSED';
  }

  onFailure() {
    this.failureCount++;
    this.lastFailureTime = Date.now();
    
    if (this.failureCount >= this.failureThreshold) {
      this.state = 'OPEN';
      this.nextAttempt = Date.now() + this.resetTimeout;
    }
  }

  timeoutPromise() {
    return new Promise((_, reject) => {
      setTimeout(() => reject(new Error('Operation timeout')), this.timeout);
    });
  }
}

// Service with Circuit Breaker
class ExternalServiceClient {
  constructor() {
    this.circuitBreaker = new CircuitBreaker({
      failureThreshold: 3,
      timeout: 5000,
      resetTimeout: 30000
    });
  }

  async callExternalAPI(data) {
    return await this.circuitBreaker.execute(async () => {
      const response = await fetch('https://external-api.com/endpoint', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data)
      });

      if (!response.ok) {
        throw new Error(`API call failed: ${response.status}`);
      }

      return await response.json();
    });
  }
}
```

### Retry Mechanism with Exponential Backoff

```typescript
// Retry Service
class RetryService {
  static async withRetry(operation, options = {}) {
    const {
      maxAttempts = 3,
      baseDelay = 1000,
      maxDelay = 10000,
      backoffFactor = 2,
      retryCondition = (error) => true
    } = options;

    let lastError;
    
    for (let attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        return await operation();
      } catch (error) {
        lastError = error;
        
        if (attempt === maxAttempts || !retryCondition(error)) {
          throw error;
        }
        
        const delay = Math.min(
          baseDelay * Math.pow(backoffFactor, attempt - 1),
          maxDelay
        );
        
        console.log(`Attempt ${attempt} failed, retrying in ${delay}ms...`);
        await this.delay(delay);
      }
    }
    
    throw lastError;
  }

  static delay(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }
}

// Usage in Payment Service
class PaymentService {
  async processPayment(paymentData) {
    return await RetryService.withRetry(
      async () => {
        return await this.flutterwaveService.processPayment(paymentData);
      },
      {
        maxAttempts: 3,
        baseDelay: 1000,
        retryCondition: (error) => {
          // Only retry on network errors, not validation errors
          return error.code === 'ECONNRESET' || 
                 error.code === 'ETIMEDOUT' ||
                 (error.response && error.response.status >= 500);
        }
      }
    );
  }
}
```

---

## API Documentation & Testing Tools

### OpenAPI/Swagger Documentation

```typescript
// Swagger Configuration
const swaggerJsdoc = require('swagger-jsdoc');
const swaggerUi = require('swagger-ui-express');

const options = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'eBuildify API',
      version: '1.0.0',
      description: 'Building Materials E-commerce Platform API',
      contact: {
        name: 'BuildTech Solutions',
        email: 'api@buildtech.com'
      }
    },
    servers: [
      {
        url: 'https://api.ebuildify.com/v1',
        description: 'Production server'
      },
      {
        url: 'https://staging-api.ebuildify.com/v1',
        description: 'Staging server'
      }
    ],
    components: {
      securitySchemes: {
        bearerAuth: {
          type: 'http',
          scheme: 'bearer',
          bearerFormat: 'JWT'
        }
      }
    }
  },
  apis: ['./src/routes/*.js', './src/models/*.js']
};

const specs = swaggerJsdoc(options);
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(specs));

/**
 * @swagger
 * /auth/login:
 *   post:
 *     summary: User authentication
 *     tags: [Authentication]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - email
 *               - password
 *             properties:
 *               email:
 *                 type: string
 *                 format: email
 *               password:
 *                 type: string
 *                 minLength: 8
 *     responses:
 *       200:
 *         description: Login successful
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                 data:
 *                   type: object
 *                   properties:
 *                     user:
 *                       $ref: '#/components/schemas/User'
 *                     tokens:
 *                       type: object
 *                       properties:
 *                         access_token:
 *                           type: string
 *                         refresh_token:
 *                           type: string
 *                         expires_in:
 *                           type: integer
 */
```

### API Testing Framework

```typescript
// API Test Suite
const request = require('supertest');
const app = require('../app');

describe('eBuildify API Test Suite', () => {
  let authToken;
  let testUser;
  let testProduct;

  beforeAll(async () => {
    // Setup test environment
    await setupTestDatabase();
    testUser = await createTestUser();
    testProduct = await createTestProduct();
    
    // Get auth token
    const loginResponse = await request(app)
      .post('/api/v1/auth/login')
      .send({
        email: testUser.email,
        password: 'TestPassword123!'
      });
    
    authToken = loginResponse.body.data.tokens.access_token;
  });

  afterAll(async () => {
    await cleanupTestDatabase();
  });

  describe('Authentication Endpoints', () => {
    test('POST /auth/register - should register new user', async () => {
      const userData = {
        email: 'newuser@test.com',
        phoneNumber: '+233501234567',
        password: 'SecurePass123!',
        firstName: 'John',
        lastName: 'Doe',
        ghanaCardNumber: 'GHA-123456789-0',
        dateOfBirth: '1990-01-01'
      };

      const response = await request(app)
        .post('/api/v1/auth/register')
        .send(userData)
        .expect(201);

      expect(response.body.success).toBe(true);
      expect(response.body.data.user.email).toBe(userData.email);
    });

    test('POST /auth/login - should authenticate user', async () => {
      const response = await request(app)
        .post('/api/v1/auth/login')
        .send({
          email: testUser.email,
          password: 'TestPassword123!'
        })
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data.tokens.access_token).toBeDefined();
    });
  });

  describe('Product Endpoints', () => {
    test('GET /products - should return product list', async () => {
      const response = await request(app)
        .get('/api/v1/products')
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(Array.isArray(response.body.data)).toBe(true);
    });

    test('GET /products/:id - should return product details', async () => {
      const response = await request(app)
        .get(`/api/v1/products/${testProduct.productId}`)
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data.productId).toBe(testProduct.productId);
    });
  });

  describe('Order Endpoints', () => {
    test('POST /orders - should create new order', async () => {
      const orderData = {
        items: [
          {
            productId: testProduct.productId,
            quantity: 50
          }
        ],
        deliveryAddress: {
          addressLine1: '123 Test Street',
          city: 'Accra',
          region: 'Greater Accra',
          latitude: 5.6037,
          longitude: -0.1870
        }
      };

      const response = await request(app)
        .post('/api/v1/orders')
        .set('Authorization', `Bearer ${authToken}`)
        .send(orderData)
        .expect(201);

      expect(response.body.success).toBe(true);
      expect(response.body.data.orderNumber).toBeDefined();
    });
  });
});

// Load Testing with Artillery
// artillery.yml
config:
  target: 'http://localhost:3000'
  phases:
    - duration: 60
      arrivalRate: 10
  defaults:
    headers:
      Authorization: 'Bearer {{token}}'

scenarios:
  - name: 'Product Search Load Test'
    weight: 70
    flow:
      - get:
          url: '/api/v1/products'
          qs:
            page: 1
            limit: 20
            search: 'cement'
  
  - name: 'Order Creation Load Test'
    weight: 30
    flow:
      - post:
          url: '/api/v1/orders'
          json:
            items:
              - productId: '{{productId}}'
                quantity: 10
            deliveryAddress:
              addressLine1: 'Test Address'
              city: 'Accra'
              region: 'Greater Accra'
```

---

## Deployment & Production Readiness

### Production Environment Configuration

```typescript
// Production Configuration
const productionConfig = {
  // Database Configuration
  database: {
    host: process.env.DB_HOST,
    port: parseInt(process.env.DB_PORT) || 5432,
    database: process.env.DB_NAME,
    username: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    dialect: 'postgres',
    pool: {
      min: 5,
      max: 20,
      acquire: 30000,
      idle: 10000
    },
    logging: false,
    ssl: {
      require: true,
      rejectUnauthorized: false
    }
  },

  // Redis Configuration
  redis: {
    host: process.env.REDIS_HOST,
    port: parseInt(process.env.REDIS_PORT) || 6379,
    password: process.env.REDIS_PASSWORD,
    db: 0,
    retryDelayOnFailover: 100,
    enableReadyCheck: false,
    maxRetriesPerRequest: null
  },

  // Security Configuration
  security: {
    jwtSecret: process.env.JWT_SECRET,
    jwtExpiresIn: '24h',
    refreshTokenExpiresIn: '7d',
    bcryptRounds: 12,
    rateLimitWindow: 15 * 60 * 1000, // 15 minutes
    rateLimitMax: 100, // requests per window
    corsOrigins: process.env.CORS_ORIGINS?.split(',') || []
  },

  // External Services
  services: {
    flutterwave: {
      publicKey: process.env.FLW_PUBLIC_KEY,
      secretKey: process.env.FLW_SECRET_KEY,
      webhookHash: process.env.FLW_WEBHOOK_HASH
    },
    twilio: {
      accountSid: process.env.TWILIO_ACCOUNT_SID,
      authToken: process.env.TWILIO_AUTH_TOKEN,
      fromNumber: process.env.TWILIO_FROM_NUMBER
    },
    sendgrid: {
      apiKey: process.env.SENDGRID_API_KEY,
      fromEmail: process.env.SENDGRID_FROM_EMAIL
    }
  }
};
```

### Health Checks & Monitoring

```typescript
// Comprehensive Health Check Service
class HealthCheckService {
  static async performHealthCheck() {
    const checks = {
      status: 'healthy',
      timestamp: new Date().toISOString(),
      uptime: process.uptime(),
      version: process.env.APP_VERSION || '1.0.0',
      environment: process.env.NODE_ENV,
      checks: {}
    };

    try {
      // Database Health Check
      checks.checks.database = await this.checkDatabase();
      
      // Redis Health Check
      checks.checks.redis = await this.checkRedis();
      
      // External Services Health Check
      checks.checks.flutterwave = await this.checkFlutterwave();
      checks.checks.sms = await this.checkSMSService();
      checks.checks.email = await this.checkEmailService();
      
      // System Resources Check
      checks.checks.memory = this.checkMemoryUsage();
      checks.checks.diskSpace = await this.checkDiskSpace();
      
      // Determine overall status
      const hasUnhealthyChecks = Object.values(checks.checks)
        .some(check => check.status !== 'healthy');
      
      if (hasUnhealthyChecks) {
        checks.status = 'degraded';
      }

    } catch (error) {
      checks.status = 'unhealthy';
      checks.error = error.message;
    }

    return checks;
  }

  static async checkDatabase() {
    try {
      await pool.query('SELECT 1');
      return {
        status: 'healthy',
        responseTime: Date.now(),
        details: 'Database connection successful'
      };
    } catch (error) {
      return {
        status: 'unhealthy',
        error: error.message
      };
    }
  }

  static async checkRedis() {
    try {
      await redisClient.ping();
      return {
        status: 'healthy',
        details: 'Redis connection successful'
      };
    } catch (error) {
      return {
        status: 'unhealthy',
        error: error.message
      };
    }
  }

  static checkMemoryUsage() {
    const memUsage = process.memoryUsage();
    const memLimit = 512 * 1024 * 1024; // 512MB limit
    
    return {
      status: memUsage.heapUsed < memLimit ? 'healthy' : 'warning',
      details: {
        heapUsed: `${Math.round(memUsage.heapUsed / 1024 / 1024)}MB`,
        heapTotal: `${Math.round(memUsage.heapTotal / 1024 / 1024)}MB`,
        rss: `${Math.round(memUsage.rss / 1024 / 1024)}MB`
      }
    };
  }
}

// Health Check Endpoint
app.get('/health', async (req, res) => {
  try {
    const healthStatus = await HealthCheckService.performHealthCheck();
    const statusCode = healthStatus.status === 'healthy' ? 200 : 503;
    res.status(statusCode).json(healthStatus);
  } catch (error) {
    res.status(503).json({
      status: 'unhealthy',
      error: error.message,
      timestamp: new Date().toISOString()
    });
  }
});
```

### Graceful Shutdown Implementation

```typescript
// Graceful Shutdown Handler
class GracefulShutdown {
  constructor(server) {
    this.server = server;
    this.isShuttingDown = false;
    this.connections = new Set();
    
    // Track active connections
    server.on('connection', (connection) => {
      this.connections.add(connection);
      connection.on('close', () => {
        this.connections.delete(connection);
      });
    });
  }

  async shutdown(signal) {
    if (this.isShuttingDown) {
      console.log('Shutdown already in progress...');
      return;
    }

    this.isShuttingDown = true;
    console.log(`Received ${signal}. Starting graceful shutdown...`);

    try {
      // Stop accepting new requests
      this.server.close(() => {
        console.log('HTTP server closed');
      });

      // Close active connections after timeout
      setTimeout(() => {
        console.log('Force closing remaining connections');
        this.connections.forEach(connection => connection.destroy());
      }, 10000);

      // Close database connections
      await pool.end();
      console.log('Database connections closed');

      // Close Redis connections
      await redisClient.quit();
      console.log('Redis connections closed');

      // Wait for background jobs to complete
      await Promise.all([
        emailQueue.close(),
        smsQueue.close(),
        inventoryQueue.close()
      ]);
      console.log('Job queues closed');

      console.log('Graceful shutdown completed');
      process.exit(0);

    } catch (error) {
      console.error('Error during shutdown:', error);
      process.exit(1);
    }
  }
}

// Setup graceful shutdown
const gracefulShutdown = new GracefulShutdown(server);

process.on('SIGTERM', () => gracefulShutdown.shutdown('SIGTERM'));
process.on('SIGINT', () => gracefulShutdown.shutdown('SIGINT'));
```

---

## Security Best Practices Implementation

### Input Sanitization & SQL Injection Prevention

```typescript
// SQL Injection Prevention with Parameterized Queries
class SecureRepository {
  constructor(pool) {
    this.pool = pool;
  }

  async findUserByEmail(email) {
    // Using parameterized queries prevents SQL injection
    const query = 'SELECT * FROM users WHERE email = $1 AND is_active = true';
    const result = await this.pool.query(query, [email]);
    return result.rows[0];
  }

  async searchProducts(filters) {
    let query = `
      SELECT p.*, pc.category_name, i.available_stock
      FROM products p
      JOIN product_categories pc ON p.category_id = pc.category_id
      JOIN inventory i ON p.product_id = i.product_id
      WHERE p.is_active = true
    `;
    
    const params = [];
    let paramIndex = 1;

    if (filters.search) {
      query += ` AND p.product_name ILIKE ${paramIndex}`;
      params.push(`%${filters.search}%`);
      paramIndex++;
    }

    if (filters.categoryId) {
      query += ` AND p.category_id = ${paramIndex}`;
      params.push(filters.categoryId);
      paramIndex++;
    }

    if (filters.minPrice) {
      query += ` AND p.unit_price >= ${paramIndex}`;
      params.push(filters.minPrice);
      paramIndex++;
    }

    query += ` ORDER BY p.created_at DESC LIMIT ${paramIndex} OFFSET ${paramIndex + 1}`;
    params.push(filters.limit || 20, filters.offset || 0);

    const result = await this.pool.query(query, params);
    return result.rows;
  }
}
```

### Rate Limiting & DDoS Protection

```typescript
// Advanced Rate Limiting
const rateLimit = require('express-rate-limit');
const slowDown = require('express-slow-down');
const MongoStore = require('rate-limit-mongo');

// Different rate limits for different endpoints
const createRateLimit = (windowMs, max, message) => {
  return rateLimit({
    windowMs,
    max,
    message: {
      success: false,
      error: {
        code: 'RATE_LIMIT_EXCEEDED',
        message
      }
    },
    standardHeaders: true,
    legacyHeaders: false,
    store: new MongoStore({
      uri: process.env.MONGO_URI,
      collectionName: 'rateLimits',
      expireTimeMs: windowMs
    })
  });
};

// Apply different rate limits
app.use('/api/v1/auth/login', createRateLimit(
  15 * 60 * 1000, // 15 minutes
  5, // 5 attempts
  'Too many login attempts, please try again later'
));

app.use('/api/v1/auth/register', createRateLimit(
  60 * 60 * 1000, // 1 hour
  3, // 3 registrations
  'Too many registration attempts'
));

app.use('/api/v1/orders', createRateLimit(
  15 * 60 * 1000, // 15 minutes
  10, // 10 orders
  'Too many order creation attempts'
));

// Speed limiting for heavy endpoints
const speedLimiter = slowDown({
  windowMs: 15 * 60 * 1000, // 15 minutes
  delayAfter: 50, // Allow 50 requests per windowMs without delay
  delayMs: 500, // Add 500ms delay per request after delayAfter
  maxDelayMs: 20000, // Max delay of 20 seconds
});

app.use('/api/v1/products/search', speedLimiter);
```

### Data Encryption & Privacy Protection

```typescript
// Advanced Encryption Service
const crypto = require('crypto');

class AdvancedEncryption {
  constructor() {
    this.algorithm = 'aes-256-gcm';
    this.keyLength = 32;
    this.ivLength = 16;
    this.tagLength = 16;
    this.masterKey = Buffer.from(process.env.MASTER_ENCRYPTION_KEY, 'hex');
  }

  generateKey() {
    return crypto.randomBytes(this.keyLength);
  }

  encrypt(plaintext, key = null) {
    const encryptionKey = key || this.masterKey;
    const iv = crypto.randomBytes(this.ivLength);
    const cipher = crypto.createCipher(this.algorithm, encryptionKey, iv);
    
    let encrypted = cipher.update(plaintext, 'utf8', 'hex');
    encrypted += cipher.final('hex');
    
    const authTag = cipher.getAuthTag();
    
    return {
      encrypted,
      iv: iv.toString('hex'),
      authTag: authTag.toString('hex')
    };
  }

  decrypt(encryptedData, key = null) {
    const encryptionKey = key || this.masterKey;
    const decipher = crypto.createDecipher(
      this.algorithm,
      encryptionKey,
      Buffer.from(encryptedData.iv, 'hex')
    );
    
    decipher.setAuthTag(Buffer.from(encryptedData.authTag, 'hex'));
    
    let decrypted = decipher.update(encryptedData.encrypted, 'hex', 'utf8');
    decrypted += decipher.final('utf8');
    
    return decrypted;
  }
}

// PII Protection Middleware
class PIIProtection {
  static maskPhoneNumber(phoneNumber) {
    if (!phoneNumber || phoneNumber.length < 4) return phoneNumber;
    return phoneNumber.slice(0, -4).replace(/\d/g, '*') + phoneNumber.slice(-4);
  }

  static maskEmail(email) {
    if (!email || !email.includes('@')) return email;
    const [username, domain] = email.split('@');
    const maskedUsername = username.length > 2 
      ? username[0] + '*'.repeat(username.length - 2) + username.slice(-1)
      : username;
    return `${maskedUsername}@${domain}`;
  }

  static maskGhanaCard(cardNumber) {
    if (!cardNumber) return cardNumber;
    return cardNumber.replace(/\d(?=\d{4})/g, '*');
  }

  static sanitizeUserResponse(user) {
    return {
      ...user,
      phoneNumber: this.maskPhoneNumber(user.phoneNumber),
      email: this.maskEmail(user.email),
      ghanaCardNumber: this.maskGhanaCard(user.ghanaCardNumber)
    };
  }
}
```

---

## Data Analytics & Business Intelligence

### Analytics Data Pipeline

```typescript
// Analytics Service
class AnalyticsService {
  constructor() {
    this.analyticsQueue = new Queue('analytics', process.env.REDIS_URL);
    this.setupAnalyticsProcessors();
  }

  setupAnalyticsProcessors() {
    // Daily customer analytics
    this.analyticsQueue.process('customer-analytics', async (job) => {
      const { date } = job.data;
      await this.processCustomerAnalytics(date);
    });

    // Product performance analytics
    this.analyticsQueue.process('product-analytics', async (job) => {
      const { date } = job.data;
      await this.processProductAnalytics(date);
    });

    // Sales analytics
    this.analyticsQueue.process('sales-analytics', async (job) => {
      const { date } = job.data;
      await this.processSalesAnalytics(date);
    });
  }

  async processCustomerAnalytics(date) {
    const customers = await this.getActiveCustomers(date);
    
    for (const customer of customers) {
      const analytics = await this.calculateCustomerMetrics(customer.userId, date);
      
      await db.customerAnalytics.upsert({
        where: {
          userId_analyticsDate: {
            userId: customer.userId,
            analyticsDate: date
          }
        },
        update: analytics,
        create: {
          userId: customer.userId,
          analyticsDate: date,
          ...analytics
        }
      });
    }
  }

  async calculateCustomerMetrics(userId, date) {
    const startDate = new Date(date);
    const endDate = new Date(date);
    endDate.setDate(endDate.getDate() + 1);

    // Get orders for the day
    const orders = await db.orders.findMany({
      where: {
        customerId: userId,
        orderPlacedAt: {
          gte: startDate,
          lt: endDate
        }
      },
      include: {
        orderItems: {
          include: {
            product: true
          }
        }
      }
    });

    const totalSpent = orders.reduce((sum, order) => sum + order.totalAmount, 0);
    const ordersCount = orders.length;
    const productsCount = orders.reduce((sum, order) => sum + order.orderItems.length, 0);
    const averageOrderValue = ordersCount > 0 ? totalSpent / ordersCount : 0;

    // Calculate favorite category
    const categoryFrequency = {};
    orders.forEach(order => {
      order.orderItems.forEach(item => {
        const category = item.product.category.categoryName;
        categoryFrequency[category] = (categoryFrequency[category] || 0) + item.quantity;
      });
    });

    const favoriteCategory = Object.keys(categoryFrequency).reduce((a, b) => 
      categoryFrequency[a] > categoryFrequency[b] ? a : b, null);

    return {
      ordersCount,
      totalSpent,
      averageOrderValue,
      productsCount,
      favoriteCategory
    };
  }

  async generateBusinessIntelligence(dateRange) {
    const { startDate, endDate } = dateRange;

    // Sales trends
    const salesTrends = await this.getSalesTrends(startDate, endDate);
    
    // Top performing products
    const topProducts = await this.getTopProducts(startDate, endDate);
    
    // Customer segmentation
    const customerSegments = await this.getCustomerSegmentation(startDate, endDate);
    
    // Regional performance
    const regionalPerformance = await this.getRegionalPerformance(startDate, endDate);
    
    // Credit analysis
    const creditAnalysis = await this.getCreditAnalysis(startDate, endDate);

    return {
      summary: {
        totalRevenue: salesTrends.totalRevenue,
        totalOrders: salesTrends.totalOrders,
        averageOrderValue: salesTrends.averageOrderValue,
        uniqueCustomers: salesTrends.uniqueCustomers
      },
      salesTrends,
      topProducts,
      customerSegments,
      regionalPerformance,
      creditAnalysis,
      generatedAt: new Date()
    };
  }

  async getSalesTrends(startDate, endDate) {
    const salesData = await db.orders.groupBy({
      by: ['orderPlacedAt'],
      where: {
        orderPlacedAt: {
          gte: startDate,
          lte: endDate
        },
        orderStatus: {
          in: ['confirmed', 'delivered']
        }
      },
      _sum: {
        totalAmount: true
      },
      _count: {
        orderId: true
      }
    });

    return salesData.map(day => ({
      date: day.orderPlacedAt,
      revenue: day._sum.totalAmount || 0,
      orders: day._count.orderId || 0
    }));
  }
}
```

### Real-time Dashboard Metrics

```typescript
// Real-time Metrics Service
class MetricsService {
  constructor() {
    this.io = require('socket.io')(server);
    this.setupSocketHandlers();
    this.startMetricsCollection();
  }

  setupSocketHandlers() {
    this.io.on('connection', (socket) => {
      console.log('Admin connected to metrics dashboard');
      
      socket.on('subscribe-metrics', (adminId) => {
        socket.join('admin-metrics');
        this.sendCurrentMetrics(socket);
      });

      socket.on('disconnect', () => {
        console.log('Admin disconnected from metrics dashboard');
      });
    });
  }

  startMetricsCollection() {
    // Update metrics every 30 seconds
    setInterval(async () => {
      const metrics = await this.collectCurrentMetrics();
      this.io.to('admin-metrics').emit('metrics-update', metrics);
    }, 30000);
  }

  async collectCurrentMetrics() {
    const now = new Date();
    const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    const yesterday = new Date(today);
    yesterday.setDate(yesterday.getDate() - 1);

    // Today's metrics
    const todayOrders = await db.orders.count({
      where: {
        orderPlacedAt: { gte: today }
      }
    });

    const todayRevenue = await db.orders.aggregate({
      where: {
        orderPlacedAt: { gte: today },
        orderStatus: { in: ['confirmed', 'delivered'] }
      },
      _sum: { totalAmount: true }
    });

    // Pending orders
    const pendingOrders = await db.orders.count({
      where: { orderStatus: 'pending' }
    });

    // Low stock alerts
    const lowStockProducts = await db.inventory.count({
      where: {
        availableStock: { lte: db.inventory.fields.reorderLevel }
      }
    });

    // Active users (last 24 hours)
    const activeUsers = await db.users.count({
      where: {
        lastLoginAt: { gte: yesterday }
      }
    });

    return {
      today: {
        orders: todayOrders,
        revenue: todayRevenue._sum.totalAmount || 0
      },
      pending: {
        orders: pendingOrders,
        lowStockAlerts: lowStockProducts
      },
      users: {
        active: activeUsers
      },
      timestamp: now
    };
  }

  async sendCurrentMetrics(socket) {
    const metrics = await this.collectCurrentMetrics();
    socket.emit('metrics-update', metrics);
  }
}
```

---

## Microservices Migration Strategy

### Phase 1: Modular Monolith Structure

```typescript
// Service Layer Organization
src/
├── services/
│   ├── user/
│   │   ├── UserService.js
│   │   ├── UserRepository.js
│   │   ├── UserController.js
│   │   └── user.routes.js
│   ├── product/
│   │   ├── ProductService.js
│   │   ├── ProductRepository.js
│   │   ├── ProductController.js
│   │   └── product.routes.js
│   ├── order/
│   │   ├── OrderService.js
│   │   ├── OrderRepository.js
│   │   ├── OrderController.js
│   │   └── order.routes.js
│   └── shared/
│       ├── EventBus.js
│       ├── BaseService.js
│       └── BaseRepository.js
```

### Phase 2: Service Extraction Plan

```typescript
// Service Extraction Utility
class ServiceExtractor {
  static async extractService(serviceName, config) {
    const { 
      databaseTables, 
      routes, 
      dependencies,
      communicationPorts 
    } = config;

    console.log(`Extracting ${serviceName} service...`);

    // 1. Create separate database
    await this.createServiceDatabase(serviceName, databaseTables);

    // 2. Migrate data
    await this.migrateServiceData(serviceName, databaseTables);

    // 3. Setup service communication
    await this.setupServiceCommunication(serviceName, communicationPorts);

    // 4. Update API gateway routing
    await this.updateAPIGatewayRouting(serviceName, routes);

    // 5. Deploy new service
    await this.deployService(serviceName);

    console.log(`${serviceName} service extraction completed`);
  }

  static async createServiceDatabase(serviceName, tables) {
    const dbName = `ebuildify_${serviceName}`;
    
    // Create new database
    await adminDb.query(`CREATE DATABASE ${dbName}`);
    
    // Migrate schema for specific tables
    for (const table of tables) {
      await this.migrateTableSchema(table, dbName);
    }
  }

  static async setupServiceCommunication(serviceName, ports) {
    // Setup event-driven communication
    const eventBus = new ServiceEventBus(serviceName);
    
    // Register event handlers
    eventBus.setupEventHandlers();
    
    // Setup HTTP endpoints for direct communication
    const serviceApp = express();
    serviceApp.listen(ports.http, () => {
      console.log(`${serviceName} service listening on port ${ports.http}`);
    });
    
    return { eventBus, serviceApp };
  }
}

// Migration Configuration
const migrationPlan = {
  userService: {
    priority: 1,
    databaseTables: ['users', 'user_profiles', 'user_addresses'],
    routes: ['/auth/*', '/users/*'],
    dependencies: [],
    communicationPorts: { http: 3001, events: 5001 }
  },
  productService: {
    priority: 2,
    databaseTables: ['products', 'product_categories', 'product_images', 'inventory'],
    routes: ['/products/*', '/categories/*'],
    dependencies: ['userService'],
    communicationPorts: { http: 3002, events: 5002 }
  },
  orderService: {
    priority: 3,
    databaseTables: ['orders', 'order_items', 'order_addresses', 'cart_items'],
    routes: ['/orders/*', '/cart/*'],
    dependencies: ['userService', 'productService'],
    communicationPorts: { http: 3003, events: 5003 }
  }
};
```

---

## Final Implementation Checklist

### Development Phase Checklist

- [ ] **Environment Setup**
  - [ ] Node.js 20.x LTS installed
  - [ ] PostgreSQL 15+ configured
  - [ ] Redis 7.x configured
  - [ ] Development database created
  - [ ] Environment variables configured

- [ ] **Core Infrastructure**
  - [ ] Express.js application scaffolded
  - [ ] Database schema migrated
  - [ ] Prisma ORM configured
  - [ ] Redis client configured
  - [ ] Winston logging configured

- [ ] **Authentication & Security**
  - [ ] JWT authentication implemented
  - [ ] Role-based authorization
  - [ ] Input validation with Joi
  - [ ] Rate limiting configured
  - [ ] CORS properly configured
  - [ ] Helmet.js security headers

- [ ] **API Development**
  - [ ] All API endpoints implemented
  - [ ] Request/response validation
  - [ ] Error handling middleware
  - [ ] OpenAPI documentation
  - [ ] API testing with Jest/Supertest

- [ ] **Business Logic**
  - [ ] User management service
  - [ ] Product catalog service
  - [ ] Order processing service
  - [ ] Payment integration
  - [ ] Inventory management
  - [ ] Notification system

- [ ] **External Integrations**
  - [ ] Flutterwave payment gateway
  - [ ] Ghana Card verification
  - [ ] SMS service (Twilio)
  - [ ] Email service (SendGrid)
  - [ ] Google Sheets sync

### Production Deployment Checklist

- [ ] **Infrastructure**
  - [ ] Production server provisioned
  - [ ] Database server configured
  - [ ] Redis cluster setup
  - [ ] Load balancer configured
  - [ ] SSL certificates installed

- [ ] **Security**
  - [ ] Environment variables secured
  - [ ] Database connections encrypted
  - [ ] API rate limiting active
  - [ ] Input sanitization verified
  - [ ] Audit logging enabled

- [ ] **Monitoring**
  - [ ] Health check endpoints
  - [ ] Application metrics
  - [ ] Error tracking (Sentry)
  - [ ] Performance monitoring
  - [ ] Alert system configured

- [ ] **Backup & Recovery**
  - [ ] Database backup strategy
  - [ ] Disaster recovery plan
  - [ ] Data retention policies
  - [ ] Backup testing procedures

### Post-Launch Checklist

- [ ] **Performance Optimization**
  - [ ] Database query optimization
  - [ ] Cache strategy implementation
  - [ ] CDN configuration
  - [ ] Image optimization

- [ ] **Scaling Preparation**
  - [ ] Microservices extraction plan
  - [ ] Database sharding strategy
  - [ ] Container orchestration
  - [ ] Auto-scaling configuration

- [ ] **Documentation**
  - [ ] API documentation complete
  - [ ] Deployment procedures documented
  - [ ] Troubleshooting guides
  - [ ] Developer onboarding guide

---

## Conclusion

This comprehensive backend architecture provides a robust, scalable, and secure foundation for the eBuildify platform. The design follows industry best practices and accommodates all the specific requirements outlined in your project documentation.

### Key Architectural Benefits:

1. **Scalability**: Designed to handle growth from hundreds to thousands of concurrent users
2. **Security**: Comprehensive security measures including Ghana Card protection and payment compliance
3. **Maintainability**: Clean code architecture with clear separation of concerns
4. **Performance**: Optimized database queries, caching strategies, and efficient algorithms
5. **Reliability**: Circuit breakers, retry mechanisms, and graceful error handling
6. **Observability**: Comprehensive monitoring, logging, and health checks

### Next Steps:

1. **Development Environment Setup**: Follow the environment setup guide
2. **Core Services Implementation**: Start with user management and authentication
3. **API Development**: Implement REST endpoints following the provided patterns
4. **Testing**: Comprehensive unit and integration testing
5. **Deployment**: Container-based deployment with proper CI/CD pipelines

This architecture will serve as the solid foundation for your eBuildify platform, ensuring it can handle the specific requirements of the Ghanaian building materials market while providing room for future growth and feature additions.