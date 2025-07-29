```
ebuildify-core/                    # From Modules 1 & 2
├── src/
│   ├── controllers/
│   │   ├── AuthController.js      # Authentication endpoints
│   │   └── UserController.js      # User profile management
│   ├── services/
│   │   ├── AuthService.js         # Authentication business logic
│   │   ├── TokenService.js        # JWT token management
│   │   ├── PasswordService.js     # Password operations
│   │   └── PermissionService.js   # Role-based permissions
│   ├── middleware/
│   │   ├── authenticate.js        # JWT authentication middleware
│   │   ├── authorize.js           # Role-based authorization
│   │   ├── rateLimiting.js        # Auth-specific rate limiting
│   │   └── validation.js          # Auth input validation
│   ├── routes/
│   │   ├── auth.js               # Authentication routes
│   │   └── users.js              # User management routes
│   ├── utils/
│   │   ├── jwt.js                # JWT utilities
│   │   ├── crypto.js             # Encryption utilities
│   │   └── otp.js                # OTP generation
│   └── validators/
│       ├── authValidators.js     # Authentication validators
│       └── userValidators.js     # User input validators
├── tests/
│   ├── auth/
│   │   ├── auth.test.js          # Authentication tests
│   │   ├── authorization.test.js  # Authorization tests
│   │   ├── tokens.test.js        # Token management tests
│   │   └── security.test.js      # Security feature tests
│   └── fixtures/
│       └── authData.json         # Test authentication data
└── docs/
    └── authentication.md         # Authentication documentation
```

---

## 🛠 Technology Stack

| Component | Technology | Version | Purpose |
|-----------|------------|---------|---------|
| **JWT** | jsonwebtoken | 9.x | Token generation and verification |
| **Password Hashing** | bcrypt | 5.x | Secure password hashing |
| **Validation** | Joi | 17.x | Input validation |
| **Rate Limiting** | express-rate-limit | 6.x | Brute force protection |
| **Crypto** | crypto (Node.js) | Built-in | Encryption and random generation |
| **OTP** | speakeasy | 2.x | Time-based OTP generation |
| **Email** | nodemailer | 6.x | Password reset emails |

---

## 📦 Additional Dependencies

### Package.json Updates
```json
{
  "dependencies": {
    "jsonwebtoken": "^9.0.2",
    "bcrypt": "^5.1.1",
    "speakeasy": "^2.0.0",
    "nodemailer": "^6.9.4",
    "express-rate-limit": "^6.10.0",
    "express-slow-down": "^1.6.0"
  },
  "scripts": {
    "test:auth": "jest tests/auth/ --verbose",
    "test:security": "jest tests/auth/security.test.js"
  }
}
```

---

## 🔐 Authentication Services

### src/services/TokenService.js
```javascript
const jwt = require('jsonwebtoken');
const crypto = require('crypto');
const logger = require('../utils/logger');
const config = require('../config/environment');

class TokenService {
  constructor() {
    this.accessTokenSecret = process.env.JWT_SECRET || 'fallback-secret';
    this.refreshTokenSecret = process.env.JWT_REFRESH_SECRET || 'fallback-refresh-secret';
    this.accessTokenExpiry = process.env.JWT_EXPIRES_IN || '1h';
    this.refreshTokenExpiry = process.env.JWT_REFRESH_EXPIRES_IN || '7d';
  }

  // Generate access token
  generateAccessToken(payload) {
    try {
      const tokenPayload = {
        userId: payload.userId,
        email: payload.email,
        userType: payload.userType,
        isActive: payload.isActive,
        type: 'access'
      };

      const token = jwt.sign(tokenPayload, this.accessTokenSecret, {
        expiresIn: this.accessTokenExpiry,
        issuer: 'ebuildify-api',
        audience: 'ebuildify-app'
      });

      logger.info('Access token generated', { userId: payload.userId });
      return token;
    } catch (error) {
      logger.error('Access token generation failed:', error);
      throw new Error('Token generation failed');
    }
  }

  // Generate refresh token
  generateRefreshToken(payload) {
    try {
      const tokenPayload = {
        userId: payload.userId,
        email: payload.email,
        type: 'refresh',
        jti: crypto.randomUUID() // Unique token ID
      };

      const token = jwt.sign(tokenPayload, this.refreshTokenSecret, {
        expiresIn: this.refreshTokenExpiry,
        issuer: 'ebuildify-api',
        audience: 'ebuildify-app'
      });

      logger.info('Refresh token generated', { userId: payload.userId });
      return token;
    } catch (error) {
      logger.error('Refresh token generation failed:', error);
      throw new Error('Refresh token generation failed');
    }
  }

  // Generate token pair
  generateTokenPair(user) {
    const payload = {
      userId: user.userId,
      email: user.email,
      userType: user.userType,
      isActive: user.isActive
    };

    return {
      accessToken: this.generateAccessToken(payload),
      refreshToken: this.generateRefreshToken(payload),
      tokenType: 'Bearer',
      expiresIn: this.getAccessTokenExpiryInSeconds()
    };
  }

  // Verify access token
  verifyAccessToken(token) {
    try {
      const decoded = jwt.verify(token, this.accessTokenSecret, {
        issuer: 'ebuildify-api',
        audience: 'ebuildify-app'
      });

      if (decoded.type !== 'access') {
        throw new Error('Invalid token type');
      }

      return decoded;
    } catch (error) {
      if (error.name === 'TokenExpiredError') {
        throw new Error('Token expired');
      } else if (error.name === 'JsonWebTokenError') {
        throw new Error('Invalid token');
      }
      throw error;
    }
  }

  // Verify refresh token
  verifyRefreshToken(token) {
    try {
      const decoded = jwt.verify(token, this.refreshTokenSecret, {
        issuer: 'ebuildify-api',
        audience: 'ebuildify-app'
      });

      if (decoded.type !== 'refresh') {
        throw new Error('Invalid token type');
      }

      return decoded;
    } catch (error) {
      if (error.name === 'TokenExpiredError') {
        throw new Error('Refresh token expired');
      } else if (error.name === 'JsonWebTokenError') {
        throw new Error('Invalid refresh token');
      }
      throw error;
    }
  }

  // Decode token without verification (for debugging)
  decodeToken(token) {
    try {
      return jwt.decode(token, { complete: true });
    } catch (error) {
      return null;
    }
  }

  // Get token expiry in seconds
  getAccessTokenExpiryInSeconds() {
    const expiry = this.accessTokenExpiry;
    if (expiry.endsWith('h')) {
      return parseInt(expiry) * 3600;
    } else if (expiry.endsWith('m')) {
      return parseInt(expiry) * 60;
    } else if (expiry.endsWith('d')) {
      return parseInt(expiry) * 86400;
    }
    return 3600; // Default 1 hour
  }

  // Generate password reset token
  generatePasswordResetToken(userId) {
    try {
      const payload = {
        userId,
        type: 'password_reset',
        nonce: crypto.randomBytes(16).toString('hex')
      };

      return jwt.sign(payload, this.accessTokenSecret, {
        expiresIn: '15m', // Short expiry for security
        issuer: 'ebuildify-api'
      });
    } catch (error) {
      logger.error('Password reset token generation failed:', error);
      throw new Error('Password reset token generation failed');
    }
  }

  // Verify password reset token
  verifyPasswordResetToken(token) {
    try {
      const decoded = jwt.verify(token, this.accessTokenSecret, {
        issuer: 'ebuildify-api'
      });

      if (decoded.type !== 'password_reset') {
        throw new Error('Invalid token type');
      }

      return decoded;
    } catch (error) {
      if (error.name === 'TokenExpiredError') {
        throw new Error('Password reset token expired');
      } else if (error.name === 'JsonWebTokenError') {
        throw new Error('Invalid password reset token');
      }
      throw error;
    }
  }
}

module.exports = new TokenService();
```

### src/services/AuthService.js
```javascript
const bcrypt = require('bcrypt');
const UserRepository = require('../repositories/UserRepository');
const TokenService = require('./TokenService');
const logger = require('../utils/logger');
const { AuthenticationError, ValidationError } = require('../utils/errors');

class AuthService {
  constructor() {
    this.userRepository = new UserRepository();
    this.maxLoginAttempts = 5;
    this.lockoutDuration = 15 * 60 * 1000; // 15 minutes
  }

  // User registration
  async register(userData) {
    try {
      // Check if user already exists
      const existingUser = await this.userRepository.findByEmail(userData.email);
      if (existingUser) {
        throw new ValidationError('User with this email already exists');
      }

      // Check if phone number exists
      const existingPhone = await this.userRepository.findByPhoneNumber(userData.phoneNumber);
      if (existingPhone) {
        throw new ValidationError('User with this phone number already exists');
      }

      // Create new user
      const newUser = await this.userRepository.createUser(userData);
      
      // Generate tokens
      const tokens = TokenService.generateTokenPair(newUser);

      // Log registration
      logger.info('User registered successfully', {
        userId: newUser.userId,
        email: newUser.email,
        userType: newUser.userType
      });

      return {
        user: newUser.toSafeJSON(),
        tokens
      };
    } catch (error) {
      logger.error('User registration failed:', error);
      throw error;
    }
  }

  // User login
  async login(email, password, ipAddress = null) {
    try {
      // Find user by email (include password for verification)
      const user = await this.userRepository.findByEmail(email, true);
      if (!user) {
        throw new AuthenticationError('Invalid email or password');
      }

      // Check if account is active
      if (!user.isActive) {
        throw new AuthenticationError('Account is deactivated');
      }

      // Verify password
      const isPasswordValid = await user.verifyPassword(password);
      if (!isPasswordValid) {
        // Log failed login attempt
        logger.warn('Failed login attempt', {
          email,
          ipAddress,
          reason: 'Invalid password'
        });
        throw new AuthenticationError('Invalid email or password');
      }

      // Update last login
      await this.userRepository.updateLastLogin(user.userId);

      // Generate tokens
      const tokens = TokenService.generateTokenPair(user);

      // Log successful login
      logger.info('User logged in successfully', {
        userId: user.userId,
        email: user.email,
        ipAddress
      });

      return {
        user: user.toSafeJSON(),
        tokens
      };
    } catch (error) {
      logger.error('User login failed:', error);
      throw error;
    }
  }

  // Refresh access token
  async refreshToken(refreshToken) {
    try {
      // Verify refresh token
      const decoded = TokenService.verifyRefreshToken(refreshToken);
      
      // Get user details
      const user = await this.userRepository.findById(decoded.userId);
      if (!user || !user.isActive) {
        throw new AuthenticationError('User not found or inactive');
      }

      // Generate new token pair
      const tokens = TokenService.generateTokenPair(user);

      logger.info('Token refreshed successfully', { userId: user.userId });

      return {
        user: user.toSafeJSON(),
        tokens
      };
    } catch (error) {
      logger.error('Token refresh failed:', error);
      throw new AuthenticationError('Invalid refresh token');
    }
  }

  // Logout (token blacklisting would be implemented here if needed)
  async logout(userId) {
    try {
      // In a production system, you might want to blacklist the token
      // For now, we'll just log the logout
      logger.info('User logged out', { userId });
      
      return { success: true };
    } catch (error) {
      logger.error('Logout failed:', error);
      throw error;
    }
  }

  // Request password reset
  async requestPasswordReset(email) {
    try {
      const user = await this.userRepository.findByEmail(email);
      if (!user) {
        // Don't reveal if email exists - security best practice
        logger.warn('Password reset requested for non-existent email', { email });
        return { success: true, message: 'If the email exists, a reset link has been sent' };
      }

      // Generate reset token
      const resetToken = TokenService.generatePasswordResetToken(user.userId);
      
      // In a real implementation, you would send this via email
      // For now, we'll log it (remove in production)
      logger.info('Password reset token generated', {
        userId: user.userId,
        resetToken: resetToken // Remove this in production
      });

      // TODO: Send email with reset link
      // await EmailService.sendPasswordResetEmail(user.email, resetToken);

      return {
        success: true,
        message: 'If the email exists, a reset link has been sent'
      };
    } catch (error) {
      logger.error('Password reset request failed:', error);
      throw error;
    }
  }

  // Reset password
  async resetPassword(resetToken, newPassword) {
    try {
      // Verify reset token
      const decoded = TokenService.verifyPasswordResetToken(resetToken);
      
      // Get user
      const user = await this.userRepository.findById(decoded.userId);
      if (!user) {
        throw new AuthenticationError('Invalid reset token');
      }

      // Hash new password
      const hashedPassword = await bcrypt.hash(newPassword, 12);
      
      // Update password
      await this.userRepository.update(user.userId, {
        password: hashedPassword
      });

      logger.info('Password reset successfully', { userId: user.userId });

      return { success: true, message: 'Password reset successfully' };
    } catch (error) {
      logger.error('Password reset failed:', error);
      throw new AuthenticationError('Invalid or expired reset token');
    }
  }

  // Change password (for authenticated users)
  async changePassword(userId, currentPassword, newPassword) {
    try {
      // Get user with password
      const user = await this.userRepository.findById(userId);
      if (!user) {
        throw new AuthenticationError('User not found');
      }

      // Get user with password for verification
      const userWithPassword = await this.userRepository.findByEmail(user.email, true);
      
      // Verify current password
      const isCurrentPasswordValid = await userWithPassword.verifyPassword(currentPassword);
      if (!isCurrentPasswordValid) {
        throw new AuthenticationError('Current password is incorrect');
      }

      // Hash new password
      const hashedPassword = await bcrypt.hash(newPassword, 12);
      
      // Update password
      await this.userRepository.update(userId, {
        password: hashedPassword
      });

      logger.info('Password changed successfully', { userId });

      return { success: true, message: 'Password changed successfully' };
    } catch (error) {
      logger.error('Password change failed:', error);
      throw error;
    }
  }

  // Verify token and get user
  async verifyTokenAndGetUser(token) {
    try {
      const decoded = TokenService.verifyAccessToken(token);
      const user = await this.userRepository.findById(decoded.userId);
      
      if (!user || !user.isActive) {
        throw new AuthenticationError('User not found or inactive');
      }

      return user;
    } catch (error) {
      throw new AuthenticationError('Invalid token');
    }
  }
}

module.exports = new AuthService();
```

### src/services/PermissionService.js
```javascript
const logger = require('../utils/logger');

class PermissionService {
  constructor() {
    // Define permissions for each user type
    this.permissions = {
      ADMIN: [
        '*' // Admin has all permissions
      ],
      CUSTOMER: [
        'profile:read',
        'profile:update',
        'order:create',
        'order:read',
        'product:read',
        'category:read',
        'cart:manage'
      ],
      CONTRACTOR: [
        'profile:read',
        'profile:update',
        'order:create',
        'order:read',
        'product:read',
        'category:read',
        'cart:manage',
        'credit:apply',
        'credit:read',
        'bulk:purchase'
      ],
      DRIVER: [
        'profile:read',
        'profile:update',
        'delivery:read',
        'delivery:update',
        'order:read'
      ],
      CONSULTANT: [
        'profile:read',
        'profile:update',
        'booking:read',
        'booking:update',
        'consultation:manage'
      ]
    };

    // Define resource-based permissions
    this.resourcePermissions = {
      'users': {
        'read': ['ADMIN'],
        'create': ['ADMIN'],
        'update': ['ADMIN', 'SELF'], // SELF means user can update their own profile
        'delete': ['ADMIN']
      },
      'products': {
        'read': ['*'], // Everyone can read products
        'create': ['ADMIN'],
        'update': ['ADMIN'],
        'delete': ['ADMIN']
      },
      'orders': {
        'read': ['ADMIN', 'CUSTOMER', 'CONTRACTOR', 'DRIVER'],
        'create': ['CUSTOMER', 'CONTRACTOR'],
        'update': ['ADMIN', 'DRIVER'],
        'delete': ['ADMIN']
      },
      'credit': {
        'read': ['ADMIN', 'CONTRACTOR'],
        'apply': ['CONTRACTOR'],
        'approve': ['ADMIN'],
        'manage': ['ADMIN']
      }
    };
  }

  // Check if user has specific permission
  hasPermission(userType, permission) {
    try {
      const userPermissions = this.permissions[userType] || [];
      
      // Admin has all permissions
      if (userPermissions.includes('*')) {
        return true;
      }

      // Check exact permission match
      return userPermissions.includes(permission);
    } catch (error) {
      logger.error('Permission check failed:', error);
      return false;
    }
  }

  // Check resource-based permission
  hasResourcePermission(userType, resource, action, userId = null, resourceOwnerId = null) {
    try {
      const resourcePerms = this.resourcePermissions[resource];
      if (!resourcePerms) {
        logger.warn('Unknown resource permission check', { resource, action });
        return false;
      }

      const actionPerms = resourcePerms[action];
      if (!actionPerms) {
        logger.warn('Unknown action permission check', { resource, action });
        return false;
      }

      // Check if everyone has permission
      if (actionPerms.includes('*')) {
        return true;
      }

      // Check if user type has permission
      if (actionPerms.includes(userType)) {
        return true;
      }

      // Check SELF permission (user accessing their own resource)
      if (actionPerms.includes('SELF') && userId && resourceOwnerId && userId === resourceOwnerId) {
        return true;
      }

      return false;
    } catch (error) {
      logger.error('Resource permission check failed:', error);
      return false;
    }
  }

  // Get all permissions for a user type
  getUserPermissions(userType) {
    return this.permissions[userType] || [];
  }

  // Check multiple permissions
  hasAllPermissions(userType, permissions) {
    return permissions.every(permission => this.hasPermission(userType, permission));
  }

  // Check if user has any of the permissions
  hasAnyPermission(userType, permissions) {
    return permissions.some(permission => this.hasPermission(userType, permission));
  }

  // Add custom permission (for dynamic permissions)
  addPermission(userType, permission) {
    try {
      if (!this.permissions[userType]) {
        this.permissions[userType] = [];
      }

      if (!this.permissions[userType].includes(permission)) {
        this.permissions[userType].push(permission);
        logger.info('Permission added', { userType, permission });
      }
    } catch (error) {
      logger.error('Failed to add permission:', error);
    }
  }

  // Remove permission
  removePermission(userType, permission) {
    try {
      if (this.permissions[userType]) {
        this.permissions[userType] = this.permissions[userType].filter(p => p !== permission);
        logger.info('Permission removed', { userType, permission });
      }
    } catch (error) {
      logger.error('Failed to remove permission:', error);
    }
  }

  // Get readable permission description
  getPermissionDescription(permission) {
    const descriptions = {
      'profile:read': 'View profile information',
      'profile:update': 'Update profile information',
      'order:create': 'Create new orders',
      'order:read': 'View order information',
      'order:update': 'Update order status',
      'product:read': 'View products',
      'product:create': 'Create new products',
      'product:update': 'Update product information',
      'credit:apply': 'Apply for credit',
      'credit:read': 'View credit information',
      'delivery:update': 'Update delivery status',
      'bulk:purchase': 'Make bulk purchases'
    };

    return descriptions[permission] || permission;
  }
}

module.exports = new PermissionService();
```

---

## 🛡️ Middleware Implementation

### src/middleware/authenticate.js
```javascript
const AuthService = require('../services/AuthService');
const TokenService = require('../services/TokenService');
const ResponseHandler = require('../utils/response');
const logger = require('../utils/logger');

// Main authentication middleware
const authenticate = async (req, res, next) => {
  try {
    // Get token from header
    const authHeader = req.headers.authorization;
    if (!authHeader) {
      return ResponseHandler.unauthorized(res, 'Authorization header missing');
    }

    // Extract token
    const token = extractTokenFromHeader(authHeader);
    if (!token) {
      return ResponseHandler.unauthorized(res, 'Invalid authorization format');
    }

    // Verify token and get user
    const user = await AuthService.verifyTokenAndGetUser(token);
    
    // Attach user to request
    req.user = user;
    req.token = token;

    // Log successful authentication
    logger.debug('User authenticated', {
      userId: user.userId,
      email: user.email,
      userType: user.userType
    });

    next();
  } catch (error) {
    logger.warn('Authentication failed', {
      error: error.message,
      ip: req.ip,
      userAgent: req.get('User-Agent')
    });

    if (error.message.includes('expired')) {
      return ResponseHandler.unauthorized(res, 'Token expired');
    } else if (error.message.includes('invalid')) {
      return ResponseHandler.unauthorized(res, 'Invalid token');
    } else {
      return ResponseHandler.unauthorized(res, 'Authentication failed');
    }
  }
};

// Optional authentication (doesn't fail if no token)
const optionalAuth = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader) {
      return next(); // No token, continue without user
    }

    const token = extractTokenFromHeader(authHeader);
    if (!token) {
      return next(); // Invalid format, continue without user
    }

    const user = await AuthService.verifyTokenAndGetUser(token);
    req.user = user;
    req.token = token;

    next();
  } catch (error) {
    // Log but don't fail
    logger.debug('Optional authentication failed', { error: error.message });
    next();
  }
};

// Extract token from Authorization header
function extractTokenFromHeader(authHeader) {
  const parts = authHeader.split(' ');
  
  if (parts.length !== 2) {
    return null;
  }

  const [scheme, token] = parts;
  
  if (!/^Bearer$/i.test(scheme)) {
    return null;
  }

  return token;
}

// Middleware to require verified email
const requireEmailVerification = (req, res, next) => {
  if (!req.user) {
    return ResponseHandler.unauthorized(res, 'Authentication required');
  }

  if (!req.user.isEmailVerified) {
    return ResponseHandler.forbidden(res, 'Email verification required');
  }

  next();
};

// Middleware to require active account
const requireActiveAccount = (req, res, next) => {
  if (!req.user) {
    return ResponseHandler.unauthorized(res, 'Authentication required');
  }

  if (!req.user.isActive) {
    return ResponseHandler.forbidden(res, 'Account is deactivated');
  }

  next();
};

module.exports = {
  authenticate,
  optionalAuth,
  requireEmailVerification,
  requireActiveAccount
};
```

### src/middleware/authorize.js
```javascript
const PermissionService = require('../services/PermissionService');
const ResponseHandler = require('../utils/response');
const logger = require('../utils/logger');

// Create authorization middleware for specific permissions
const authorize = (...permissions) => {
  return (req, res, next) => {
    try {
      // Check if user is authenticated
      if (!req.user) {
        return ResponseHandler.unauthorized(res, 'Authentication required');
      }

      const userType = req.user.userType;
      
      // Check if user has any of the required permissions
      const hasPermission = permissions.some(permission => 
        PermissionService.hasPermission(userType, permission)
      );

      if (!hasPermission) {
        logger.warn('Authorization failed', {
          userId: req.user.userId,
          userType,
          requiredPermissions: permissions,
          action: `${req.method} ${req.route?.path || req.path}`
        });

        return ResponseHandler.forbidden(res, 'Insufficient permissions');
      }

      // Log successful authorization
      logger.debug('User authorized', {
        userId: req.user.userId,
        userType,
        permissions: permissions
      });

      next();
    } catch (error) {
      logger.error('Authorization middleware error:', error);
      return ResponseHandler.error(res, 'Authorization check failed');
    }
  };
};

// Resource-based authorization
const authorizeResource = (resource, action) => {
  return (req, res, next) => {
    try {
      if (!req.user) {
        return ResponseHandler.unauthorized(res, 'Authentication required');
      }

      const userType = req.user.userType;
      const userId = req.user.userId;
      
      // Get resource owner ID from params or body
      const resourceOwnerId = req.params.userId || req.body.userId || req.params.id;

      const hasPermission = PermissionService.hasResourcePermission(
        userType,
        resource,
        action,
        userId,
        resourceOwnerId
      );

      if (!hasPermission) {
        logger.warn('Resource authorization failed', {
          userId,
          userType,
          resource,
          action,
          resourceOwnerId
        });

        return ResponseHandler.forbidden(res, `Cannot ${action} ${resource}`);
      }

      next();
    } catch (error) {
      logger.error('Resource authorization error:', error);
      return ResponseHandler.error(res, 'Authorization check failed');
    }
  };
};

// User type specific authorization
const requireUserType = (...userTypes) => {
  return (req, res, next) => {
    try {
      if (!req.user) {
        return ResponseHandler.unauthorized(res, 'Authentication required');
      }

      if (!userTypes.includes(req.user.userType)) {
        logger.warn('User type authorization failed', {
          userId: req.user.userId,
          currentUserType: req.user.userType,
          requiredUserTypes: userTypes
        });

        return ResponseHandler.forbidden(res, 'Access denied for your account type');
      }

      next();
    } catch (error) {
      logger.error('User type authorization error:', error);
      return ResponseHandler.error(res, 'Authorization check failed');
    }
  };
};

// Self-access authorization (user can only access their own resources)
const requireSelfAccess = (userIdParam = 'userId') => {
  return (req, res, next) => {
    try {
      if (!req.user) {
        return ResponseHandler.unauthorized(res, 'Authentication required');
      }

      const requestedUserId = req.params[userIdParam] || req.body[userIdParam];
      
      if (req.user.userType !== 'ADMIN' && req.user.userId !== requestedUserId) {
        logger.warn('Self-access authorization failed', {
          userId: req.user.userId,
          requestedUserId,
          userType: req.user.userType
        });

        return ResponseHandler.forbidden(res, 'Can only access your own resources');
      }

      next();
    } catch (error) {
      logger.error('Self-access authorization error:', error);
      return ResponseHandler.error(res, 'Authorization check failed');
    }
  };
};

// Admin only access
const requireAdmin = requireUserType('ADMIN');

// Customer or Contractor access
const requireCustomerOrContractor = requireUserType('CUSTOMER', 'CONTRACTOR');

module.exports = {
  authorize,
  authorizeResource,
  requireUserType,
  requireSelfAccess,
  requireAdmin,
  requireCustomerOrContractor
};
```

### src/middleware/rateLimiting.js
```javascript
const rateLimit = require('express-rate-limit');
const slowDown = require('express-slow-down');
const ResponseHandler = require('../utils/response');
const logger = require('../utils/logger');

// Create rate limiter with custom response
const createRateLimiter = (options) => {
  const defaultOptions = {
    standardHeaders: true,
    legacyHeaders: false,
    handler: (req, res) => {
      logger.warn('Rate limit exceeded', {
        ip: req.ip,
        path: req.path,
        userAgent: req# Module 3: Authentication System
**eBuildify Backend - Authentication & Authorization**
*Duration: 5-6 days*

---

## 🎯 Module Overview

**What This Module Does:**
- Implements JWT-based authentication system
- Creates user registration and login endpoints
- Adds role-based authorization middleware
- Implements password reset functionality
- Provides session management and token refresh
- Adds rate limiting for security

**Dependencies:**
- Module 1 (Core API Foundation) ✅
- Module 2 (Database & Models) ✅

**Success Criteria:**
- Users can register and login successfully
- JWT tokens are generated and validated
- Protected routes require authentication
- Role-based access control works
- Rate limiting prevents brute force attacks
- Password reset flow functional

---

## 📁 Project Structure Extensions

```
ebuildify-core/                    # From Modules 1 & 2
├── src/
│   ├── controllers/
│   │   ├── AuthController.js      # Authentication endpoints
│   │   └── UserController.js      # User profile management
│   ├── services/
│   │   ├── AuthService.js         # Authentication business logic
│   │   ├── TokenService.js        # JWT token management
│   │   ├── PasswordService.js     # Password operations
│   │   └── PermissionService.js   # Role-based permissions
│   ├── middleware/
│   │   ├── authenticate.js        # JWT authentication middleware
│   │   ├── authorize.js           # Role-based authorization
│   │   ├── rateLimiting.js        # Auth-specific rate limiting
│   │   └── validation.js          # Auth input validation
│   ├── routes/
│   │   ├── auth.js               # Authentication routes
│   │   └── users.js              # User management routes
│   ├── utils/
│   │   ├── jwt.js                # JWT utilities
│   │   ├── crypto.js             # Encryption utilities
│   │   └── otp.js                # OTP generation
│   └── validators/
│       ├── authValidators.js     # Authentication validators
│       └── userValidators.js     # User input validators
├── tests/
│   ├── auth/
│   │   ├── auth.test.js          # Authentication tests
│   │   ├── authorization.test.js  # Authorization tests
│   │   ├── tokens.