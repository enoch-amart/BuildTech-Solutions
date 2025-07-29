# Module 1: Core API Foundation
**eBuildify Backend - Foundation Module**
*Duration: 4-5 days*

---

## 🎯 Module Overview

**What This Module Does:**
- Sets up basic Express.js server with essential middleware
- Implements global error handling and logging
- Provides health check endpoints
- Establishes Docker containerization
- Creates the foundation for all other modules

**Success Criteria:**
- Server starts without errors
- Health endpoint returns 200 status
- Error handling works gracefully
- Logs are clean and readable
- Docker container runs successfully

---

## 📁 Project Structure

```
ebuildify-core/
├── src/
│   ├── app.js                 # Express app configuration
│   ├── server.js              # Server startup
│   ├── config/
│   │   ├── environment.js     # Environment variables
│   │   └── constants.js       # Application constants
│   ├── middleware/
│   │   ├── errorHandler.js    # Global error handling
│   │   ├── logger.js          # Request logging
│   │   ├── security.js        # Security headers
│   │   └── cors.js           # CORS configuration
│   ├── routes/
│   │   ├── index.js          # Main router
│   │   └── health.js         # Health check routes
│   ├── utils/
│   │   ├── response.js       # Standardized responses
│   │   ├── logger.js         # Winston logger setup
│   │   └── validator.js      # Input validation helpers
│   └── constants/
│       └── httpStatus.js     # HTTP status codes
├── tests/
│   ├── app.test.js           # Application tests
│   ├── health.test.js        # Health endpoint tests
│   └── helpers/
│       └── testSetup.js      # Test configuration
├── logs/                     # Log files directory
├── package.json
├── Dockerfile
├── docker-compose.yml
├── .env.example
├── .gitignore
├── .dockerignore
└── README.md
```

---

## 🛠 Technology Stack

| Component | Technology | Version | Purpose |
|-----------|------------|---------|---------|
| **Runtime** | Node.js | 20.x LTS | JavaScript runtime |
| **Framework** | Express.js | 4.18+ | Web application framework |
| **Logging** | Winston | 3.x | Application logging |
| **Security** | Helmet | 7.x | Security headers |
| **CORS** | cors | 2.x | Cross-origin requests |
| **Validation** | Joi | 17.x | Input validation |
| **Testing** | Jest | 29.x | Testing framework |
| **Testing** | Supertest | 6.x | HTTP testing |
| **Process** | PM2 | 5.x | Process management |

---

## 📦 Dependencies Setup

### package.json
```json
{
  "name": "ebuildify-core",
  "version": "1.0.0",
  "description": "eBuildify Core API Foundation",
  "main": "src/server.js",
  "scripts": {
    "start": "node src/server.js",
    "dev": "nodemon src/server.js",
    "test": "jest",
    "test:watch": "jest --watch",
    "test:coverage": "jest --coverage",
    "lint": "eslint src/",
    "lint:fix": "eslint src/ --fix"
  },
  "dependencies": {
    "express": "^4.18.2",
    "helmet": "^7.0.0",
    "cors": "^2.8.5",
    "compression": "^1.7.4",
    "winston": "^3.10.0",
    "winston-daily-rotate-file": "^4.7.1",
    "joi": "^17.9.2",
    "dotenv": "^16.3.1",
    "express-rate-limit": "^6.8.1",
    "express-slow-down": "^1.6.0"
  },
  "devDependencies": {
    "nodemon": "^3.0.1",
    "jest": "^29.6.2",
    "supertest": "^6.3.3",
    "eslint": "^8.45.0"
  }
}
```

---

## 🔧 Core Implementation

### 1. Environment Configuration

#### src/config/environment.js
```javascript
const dotenv = require('dotenv');

// Load environment variables
dotenv.config();

const config = {
  // Server Configuration
  PORT: process.env.PORT || 3000,
  NODE_ENV: process.env.NODE_ENV || 'development',
  
  // API Configuration
  API_VERSION: process.env.API_VERSION || 'v1',
  API_PREFIX: process.env.API_PREFIX || '/api',
  
  // Security Configuration
  CORS_ORIGIN: process.env.CORS_ORIGIN || 'http://localhost:3000',
  RATE_LIMIT_WINDOW: parseInt(process.env.RATE_LIMIT_WINDOW) || 15 * 60 * 1000, // 15 min
  RATE_LIMIT_MAX: parseInt(process.env.RATE_LIMIT_MAX) || 100,
  
  // Logging Configuration
  LOG_LEVEL: process.env.LOG_LEVEL || 'info',
  LOG_FILE: process.env.LOG_FILE || 'logs/app.log',
  
  // Application Metadata
  APP_NAME: 'eBuildify API',
  APP_VERSION: '1.0.0'
};

// Validate required environment variables
const requiredEnvVars = ['NODE_ENV'];
requiredEnvVars.forEach(envVar => {
  if (!process.env[envVar] && !config[envVar]) {
    throw new Error(`Required environment variable ${envVar} is missing`);
  }
});

module.exports = config;
```

#### src/config/constants.js
```javascript
module.exports = {
  // HTTP Status Codes
  HTTP_STATUS: {
    OK: 200,
    CREATED: 201,
    BAD_REQUEST: 400,
    UNAUTHORIZED: 401,
    FORBIDDEN: 403,
    NOT_FOUND: 404,
    INTERNAL_SERVER_ERROR: 500,
    SERVICE_UNAVAILABLE: 503
  },
  
  // Response Messages
  MESSAGES: {
    SERVER_STARTED: 'Server started successfully',
    HEALTH_CHECK_OK: 'Service is healthy',
    NOT_FOUND: 'Resource not found',
    INTERNAL_ERROR: 'Internal server error',
    VALIDATION_ERROR: 'Validation failed'
  },
  
  // Application Constants
  DEFAULT_PAGE_SIZE: 20,
  MAX_PAGE_SIZE: 100
};
```

### 2. Logging System

#### src/utils/logger.js
```javascript
const winston = require('winston');
const DailyRotateFile = require('winston-daily-rotate-file');
const config = require('../config/environment');

// Define log format
const logFormat = winston.format.combine(
  winston.format.timestamp({ format: 'YYYY-MM-DD HH:mm:ss' }),
  winston.format.errors({ stack: true }),
  winston.format.json()
);

// Console format for development
const consoleFormat = winston.format.combine(
  winston.format.colorize(),
  winston.format.timestamp({ format: 'HH:mm:ss' }),
  winston.format.printf(({ timestamp, level, message, stack }) => {
    return `${timestamp} [${level}]: ${stack || message}`;
  })
);

// Create logger instance
const logger = winston.createLogger({
  level: config.LOG_LEVEL,
  format: logFormat,
  defaultMeta: { service: config.APP_NAME },
  transports: [
    // Error log file
    new DailyRotateFile({
      filename: 'logs/error-%DATE%.log',
      datePattern: 'YYYY-MM-DD',
      level: 'error',
      maxSize: '20m',
      maxFiles: '14d'
    }),
    
    // Combined log file
    new DailyRotateFile({
      filename: 'logs/app-%DATE%.log',
      datePattern: 'YYYY-MM-DD',
      maxSize: '20m',
      maxFiles: '14d'
    })
  ]
});

// Console logging in development
if (config.NODE_ENV !== 'production') {
  logger.add(new winston.transports.Console({
    format: consoleFormat
  }));
}

module.exports = logger;
```

### 3. Response Utilities

#### src/utils/response.js
```javascript
const { HTTP_STATUS } = require('../config/constants');

class ResponseHandler {
  static success(res, data = null, message = 'Success', statusCode = HTTP_STATUS.OK) {
    return res.status(statusCode).json({
      success: true,
      message,
      data,
      timestamp: new Date().toISOString()
    });
  }

  static error(res, message = 'Internal Server Error', statusCode = HTTP_STATUS.INTERNAL_SERVER_ERROR, errors = null) {
    return res.status(statusCode).json({
      success: false,
      message,
      errors,
      timestamp: new Date().toISOString()
    });
  }

  static validationError(res, errors) {
    return this.error(res, 'Validation failed', HTTP_STATUS.BAD_REQUEST, errors);
  }

  static notFound(res, message = 'Resource not found') {
    return this.error(res, message, HTTP_STATUS.NOT_FOUND);
  }

  static unauthorized(res, message = 'Unauthorized') {
    return this.error(res, message, HTTP_STATUS.UNAUTHORIZED);
  }

  static forbidden(res, message = 'Forbidden') {
    return this.error(res, message, HTTP_STATUS.FORBIDDEN);
  }
}

module.exports = ResponseHandler;
```

### 4. Middleware Implementation

#### src/middleware/security.js
```javascript
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const slowDown = require('express-slow-down');
const config = require('../config/environment');

// Rate limiting configuration
const createRateLimit = (windowMs = config.RATE_LIMIT_WINDOW, max = config.RATE_LIMIT_MAX) => {
  return rateLimit({
    windowMs,
    max,
    message: {
      success: false,
      message: 'Too many requests, please try again later',
      retryAfter: Math.ceil(windowMs / 1000)
    },
    standardHeaders: true,
    legacyHeaders: false
  });
};

// Speed limiting for heavy endpoints
const speedLimiter = slowDown({
  windowMs: 15 * 60 * 1000, // 15 minutes
  delayAfter: 50, // Allow 50 requests per windowMs without delay
  delayMs: 500, // Add 500ms delay per request after delayAfter
  maxDelayMs: 20000 // Max delay of 20 seconds
});

// Security headers
const securityHeaders = helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      scriptSrc: ["'self'"],
      imgSrc: ["'self'", "data:", "https:"]
    }
  },
  hsts: {
    maxAge: 31536000,
    includeSubDomains: true,
    preload: true
  }
});

module.exports = {
  securityHeaders,
  createRateLimit,
  speedLimiter,
  // General rate limit for all endpoints
  generalRateLimit: createRateLimit()
};
```

#### src/middleware/cors.js
```javascript
const cors = require('cors');
const config = require('../config/environment');

const corsOptions = {
  origin: function (origin, callback) {
    // Allow requests with no origin (mobile apps, Postman, etc.)
    if (!origin) return callback(null, true);
    
    const allowedOrigins = config.CORS_ORIGIN.split(',');
    
    if (allowedOrigins.includes(origin) || config.NODE_ENV === 'development') {
      callback(null, true);
    } else {
      callback(new Error('Not allowed by CORS'));
    }
  },
  credentials: true,
  optionsSuccessStatus: 200,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With']
};

module.exports = cors(corsOptions);
```

#### src/middleware/logger.js
```javascript
const logger = require('../utils/logger');

const requestLogger = (req, res, next) => {
  const start = Date.now();
  
  // Log request
  logger.info('Incoming request', {
    method: req.method,
    url: req.url,
    ip: req.ip,
    userAgent: req.get('User-Agent')
  });

  // Log response when finished
  res.on('finish', () => {
    const duration = Date.now() - start;
    
    logger.info('Request completed', {
      method: req.method,
      url: req.url,
      statusCode: res.statusCode,
      duration: `${duration}ms`,
      ip: req.ip
    });
  });

  next();
};

module.exports = requestLogger;
```

#### src/middleware/errorHandler.js
```javascript
const logger = require('../utils/logger');
const ResponseHandler = require('../utils/response');
const { HTTP_STATUS } = require('../config/constants');

const errorHandler = (err, req, res, next) => {
  // Log error
  logger.error('Application error:', {
    message: err.message,
    stack: err.stack,
    url: req.url,
    method: req.method,
    ip: req.ip,
    userAgent: req.get('User-Agent')
  });

  // Joi validation error
  if (err.isJoi) {
    return ResponseHandler.validationError(res, err.details.map(detail => ({
      field: detail.path.join('.'),
      message: detail.message
    })));
  }

  // CORS error
  if (err.message === 'Not allowed by CORS') {
    return ResponseHandler.forbidden(res, 'CORS policy violation');
  }

  // Rate limit error
  if (err.status === 429) {
    return ResponseHandler.error(res, 'Rate limit exceeded', 429);
  }

  // Default to 500 server error
  if (process.env.NODE_ENV === 'production') {
    return ResponseHandler.error(res, 'Something went wrong');
  } else {
    return ResponseHandler.error(res, err.message, err.status || HTTP_STATUS.INTERNAL_SERVER_ERROR);
  }
};

// 404 handler
const notFoundHandler = (req, res) => {
  ResponseHandler.notFound(res, `Route ${req.method} ${req.url} not found`);
};

module.exports = {
  errorHandler,
  notFoundHandler
};
```

### 5. Route Implementation

#### src/routes/health.js
```javascript
const express = require('express');
const ResponseHandler = require('../utils/response');
const { MESSAGES } = require('../config/constants');

const router = express.Router();

// Basic health check
router.get('/', (req, res) => {
  const healthData = {
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    environment: process.env.NODE_ENV,
    version: require('../../package.json').version,
    memory: {
      used: Math.round(process.memoryUsage().heapUsed / 1024 / 1024),
      total: Math.round(process.memoryUsage().heapTotal / 1024 / 1024)
    }
  };

  ResponseHandler.success(res, healthData, MESSAGES.HEALTH_CHECK_OK);
});

// Detailed health check (for monitoring systems)
router.get('/detailed', (req, res) => {
  const healthData = {
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    environment: process.env.NODE_ENV,
    version: require('../../package.json').version,
    system: {
      platform: process.platform,
      nodeVersion: process.version,
      memory: process.memoryUsage(),
      cpuUsage: process.cpuUsage()
    },
    checks: {
      server: 'healthy'
      // Add more checks here as other modules are added
    }
  };

  ResponseHandler.success(res, healthData, 'Detailed health check');
});

module.exports = router;
```

#### src/routes/index.js
```javascript
const express = require('express');
const healthRoutes = require('./health');

const router = express.Router();

// Health check routes
router.use('/health', healthRoutes);

// API info endpoint
router.get('/', (req, res) => {
  res.json({
    name: 'eBuildify API',
    version: '1.0.0',
    description: 'Building Materials E-commerce Platform API',
    endpoints: {
      health: '/health',
      detailedHealth: '/health/detailed'
    }
  });
});

module.exports = router;
```

### 6. Main Application

#### src/app.js
```javascript
const express = require('express');
const compression = require('compression');
const config = require('./config/environment');
const logger = require('./utils/logger');

// Middleware
const corsMiddleware = require('./middleware/cors');
const requestLogger = require('./middleware/logger');
const { securityHeaders, generalRateLimit } = require('./middleware/security');
const { errorHandler, notFoundHandler } = require('./middleware/errorHandler');

// Routes
const routes = require('./routes');

// Create Express application
const app = express();

// Trust proxy (for rate limiting and IP detection)
app.set('trust proxy', 1);

// Security middleware
app.use(securityHeaders);
app.use(corsMiddleware);

// Rate limiting
app.use(generalRateLimit);

// Body parsing middleware
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Compression middleware
app.use(compression());

// Request logging
app.use(requestLogger);

// API routes with version prefix
app.use(`${config.API_PREFIX}/${config.API_VERSION}`, routes);

// Root endpoint
app.get('/', (req, res) => {
  res.json({
    name: config.APP_NAME,
    version: config.APP_VERSION,
    status: 'running',
    apiVersion: config.API_VERSION,
    endpoints: {
      health: `${config.API_PREFIX}/${config.API_VERSION}/health`,
      api: `${config.API_PREFIX}/${config.API_VERSION}/`
    }
  });
});

// Error handling middleware (must be last)
app.use(notFoundHandler);
app.use(errorHandler);

module.exports = app;
```

#### src/server.js
```javascript
const app = require('./app');
const config = require('./config/environment');
const logger = require('./utils/logger');

// Create HTTP server
const server = app.listen(config.PORT, () => {
  logger.info(`${config.APP_NAME} started successfully`, {
    port: config.PORT,
    environment: config.NODE_ENV,
    version: config.APP_VERSION,
    timestamp: new Date().toISOString()
  });
});

// Graceful shutdown handling
process.on('SIGTERM', () => {
  logger.info('SIGTERM received, shutting down gracefully');
  server.close(() => {
    logger.info('Process terminated');
    process.exit(0);
  });
});

process.on('SIGINT', () => {
  logger.info('SIGINT received, shutting down gracefully');
  server.close(() => {
    logger.info('Process terminated');
    process.exit(0);
  });
});

// Handle uncaught exceptions
process.on('uncaughtException', (err) => {
  logger.error('Uncaught Exception:', err);
  process.exit(1);
});

process.on('unhandledRejection', (reason, promise) => {
  logger.error('Unhandled Rejection at:', promise, 'reason:', reason);
  process.exit(1);
});

module.exports = server;
```

---

## 🧪 Testing Implementation

### tests/helpers/testSetup.js
```javascript
const request = require('supertest');
const app = require('../../src/app');

// Test helper functions
const createTestRequest = () => request(app);

// Setup and teardown helpers
const setupTest = async () => {
  // Setup test environment
  process.env.NODE_ENV = 'test';
};

const teardownTest = async () => {
  // Cleanup after tests
};

module.exports = {
  createTestRequest,
  setupTest,
  teardownTest
};
```

### tests/app.test.js
```javascript
const { createTestRequest, setupTest, teardownTest } = require('./helpers/testSetup');

describe('Core API Foundation', () => {
  beforeAll(async () => {
    await setupTest();
  });

  afterAll(async () => {
    await teardownTest();
  });

  describe('Application Startup', () => {
    test('should create Express application', () => {
      const app = require('../src/app');
      expect(app).toBeDefined();
    });
  });

  describe('Middleware', () => {
    test('should handle CORS headers', async () => {
      const response = await createTestRequest()
        .get('/')
        .expect(200);

      expect(response.headers['access-control-allow-origin']).toBeDefined();
    });

    test('should compress responses', async () => {
      const response = await createTestRequest()
        .get('/')
        .set('Accept-Encoding', 'gzip');

      // Check if compression middleware is working
      expect(response.headers['content-encoding']).toBe('gzip');
    });

    test('should add security headers', async () => {
      const response = await createTestRequest()
        .get('/');

      expect(response.headers['x-frame-options']).toBe('DENY');
      expect(response.headers['x-content-type-options']).toBe('nosniff');
    });
  });

  describe('Error Handling', () => {
    test('should handle 404 errors', async () => {
      const response = await createTestRequest()
        .get('/nonexistent-route')
        .expect(404);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain('not found');
    });

    test('should handle malformed JSON', async () => {
      const response = await createTestRequest()
        .post('/api/v1/test')
        .send('{"invalid": json}')
        .set('Content-Type', 'application/json')
        .expect(400);

      expect(response.body.success).toBe(false);
    });
  });
});
```

### tests/health.test.js
```javascript
const { createTestRequest } = require('./helpers/testSetup');

describe('Health Check Endpoints', () => {
  describe('GET /api/v1/health', () => {
    test('should return health status', async () => {
      const response = await createTestRequest()
        .get('/api/v1/health')
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data.status).toBe('healthy');
      expect(response.body.data.timestamp).toBeDefined();
      expect(response.body.data.uptime).toBeDefined();
    });
  });

  describe('GET /api/v1/health/detailed', () => {
    test('should return detailed health information', async () => {
      const response = await createTestRequest()
        .get('/api/v1/health/detailed')
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data.system).toBeDefined();
      expect(response.body.data.checks).toBeDefined();
      expect(response.body.data.system.memory).toBeDefined();
    });
  });
});
```

---

## 🐳 Docker Configuration

### Dockerfile
```dockerfile
# Use official Node.js LTS image
FROM node:20-alpine

# Set working directory
WORKDIR /app

# Create app user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production && npm cache clean --force

# Copy application code
COPY --chown=nodejs:nodejs . .

# Create logs directory
RUN mkdir -p logs && chown -R nodejs:nodejs logs

# Switch to non-root user
USER nodejs

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/api/v1/health', (res) => { process.exit(res.statusCode === 200 ? 0 : 1) })"

# Start application
CMD ["npm", "start"]
```

### docker-compose.yml
```yaml
version: '3.8'

services:
  ebuildify-core:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=development
      - PORT=3000
      - LOG_LEVEL=info
    volumes:
      - ./logs:/app/logs
      - ./.env:/app/.env:ro
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/api/v1/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
```

---

## 🔧 Configuration Files

### .env.example
```bash
# Server Configuration
NODE_ENV=development
PORT=3000

# API Configuration
API_VERSION=v1
API_PREFIX=/api

# Security Configuration
CORS_ORIGIN=http://localhost:3000
RATE_LIMIT_WINDOW=900000
RATE_LIMIT_MAX=100

# Logging Configuration
LOG_LEVEL=info
LOG_FILE=logs/app.log

# Application
APP_NAME=eBuildify API
APP_VERSION=1.0.0
```

### .gitignore
```bash
# Dependencies
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Environment variables
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# Logs
logs/
*.log

# Runtime data
pids/
*.pid
*.seed
*.pid.lock

# Coverage directory used by tools like istanbul
coverage/

# IDE
.vscode/
.idea/

# OS
.DS_Store
Thumbs.db

# Docker
.dockerignore
```

---

## ✅ Module Completion Checklist

### Functionality Tests
- [ ] Server starts without errors
- [ ] Health endpoints return correct responses
- [ ] CORS headers are present
- [ ] Rate limiting works
- [ ] Error handling catches exceptions
- [ ] Logging writes to files and console

### Security Checks
- [ ] Security headers are set
- [ ] Rate limiting prevents abuse
- [ ] CORS policy is enforced
- [ ] No sensitive data in logs
- [ ] Input size limits are enforced

### Performance Validation
- [ ] Response times < 100ms for health checks
- [ ] Memory usage is stable
- [ ] Compression reduces response size
- [ ] No memory leaks detected

### Documentation & Deployment
- [ ] README.md is complete
- [ ] Environment variables documented
- [ ] Docker container builds successfully
- [ ] Health checks pass in container
- [ ] All tests pass

---

## 🚀 Quick Start Guide

### 1. Project Setup
```bash
# Create project directory
mkdir ebuildify-core
cd ebuildify-core

# Initialize npm project
npm init -y

# Install dependencies
npm install express helmet cors compression winston winston-daily-rotate-file joi dotenv express-rate-limit express-slow-down

# Install dev dependencies
npm install --save-dev nodemon jest supertest eslint
```

### 2. Create Directory Structure
```bash
mkdir -p src/{config,middleware,routes,utils,constants}
mkdir -p tests/helpers
mkdir -p logs
```

### 3. Environment Setup
```bash
# Copy environment template
cp .env.example .env

# Edit environment variables
nano .env
```

### 4. Start Development
```bash
# Start in development mode
npm run dev

# Run tests
npm test

# Check health
curl http://localhost:3000/api/v1/health
```

---

## 📝 Next Steps

After completing this module:

1. **Test thoroughly** - All endpoints should work
2. **Deploy to staging** - Verify in Docker container
3. **Document any issues** - Keep notes for improvements
4. **Prepare for Module 2** - Database integration will build on this foundation

This module creates the solid foundation that all other modules will build upon. Take time to get it right! 🏗️