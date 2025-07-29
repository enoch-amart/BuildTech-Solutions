const createRateLimiter = (options) => {
  const defaultOptions = {
    standardHeaders: true,
    legacyHeaders: false,
    handler: (req, res) => {
      logger.warn('Rate limit exceeded', {
        ip: req.ip,
        path: req.path,
        userAgent: req.get('User-Agent'),
        userId: req.user?.userId
      });

      return ResponseHandler.error(res, 'Too many requests, please try again later', 429);
    }
  };

  return rateLimit({ ...defaultOptions, ...options });
};

// Strict rate limiting for authentication endpoints
const authRateLimit = createRateLimiter({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5, // 5 attempts per window
  skipSuccessfulRequests: true, // Don't count successful requests
  keyGenerator: (req) => {
    // Use IP + email combination for more specific limiting
    const email = req.body?.email || 'unknown';
    return `auth:${req.ip}:${email}`;
  }
});

// Login specific rate limiting
const loginRateLimit = createRateLimiter({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5, // 5 login attempts
  skipSuccessfulRequests: true,
  keyGenerator: (req) => `login:${req.ip}:${req.body?.email || 'unknown'}`
});

// Registration rate limiting
const registerRateLimit = createRateLimiter({
  windowMs: 60 * 60 * 1000, // 1 hour
  max: 3, // 3 registrations per hour per IP
  keyGenerator: (req) => `register:${req.ip}`
});

// Password reset rate limiting
const passwordResetRateLimit = createRateLimiter({
  windowMs: 60 * 60 * 1000, // 1 hour
  max: 3, // 3 reset requests per hour
  keyGenerator: (req) => `reset:${req.ip}:${req.body?.email || 'unknown'}`
});

// Token refresh rate limiting
const refreshTokenRateLimit = createRateLimiter({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 10, // 10 refresh attempts
  keyGenerator: (req) => `refresh:${req.ip}`
});

// Speed limiter for authentication endpoints
const authSpeedLimit = slowDown({
  windowMs: 15 * 60 * 1000, // 15 minutes
  delayAfter: 2, // Allow 2 requests per windowMs without delay
  delayMs: 500, // Add 500ms delay per request after delayAfter
  maxDelayMs: 20000, // Max delay of 20 seconds
  keyGenerator: (req) => `speed:${req.ip}`
});

// Progressive delay for failed attempts
const progressiveDelay = slowDown({
  windowMs: 15 * 60 * 1000, // 15 minutes
  delayAfter: 1, // Start delaying after 1 request
  delayMs: (hits) => {
    // Exponential backoff: 1s, 2s, 4s, 8s, etc.
    return Math.min(1000 * Math.pow(2, hits - 1), 30000);
  },
  keyGenerator: (req) => `progressive:${req.ip}:${req.body?.email || 'unknown'}`
});

module.exports = {
  authRateLimit,
  loginRateLimit,
  registerRateLimit,
  passwordResetRateLimit,
  refreshTokenRateLimit,
  authSpeedLimit,
  progressiveDelay,
  createRateLimiter
};
```

---

## 🎛️ Controllers Implementation

### src/controllers/AuthController.js
```javascript
const AuthService = require('../services/AuthService');
const ResponseHandler = require('../utils/response');
const logger = require('../utils/logger');

class AuthController {
  // User registration
  static async register(req, res) {
    try {
      const userData = req.body;
      
      const result = await AuthService.register(userData);
      
      logger.info('User registration successful', {
        userId: result.user.userId,
        email: result.user.email
      });

      return ResponseHandler.success(res, result, 'Registration successful', 201);
    } catch (error) {
      logger.error('Registration failed:', error);
      
      if (error.name === 'ValidationError') {
        return ResponseHandler.validationError(res, [{ message: error.message }]);
      }
      
      return ResponseHandler.error(res, error.message || 'Registration failed');
    }
  }

  // User login
  static async login(req, res) {
    try {
      const { email, password } = req.body;
      const ipAddress = req.ip;
      
      const result = await AuthService.login(email, password, ipAddress);
      
      logger.info('User login successful', {
        userId: result.user.userId,
        email: result.user.email,
        ipAddress
      });

      return ResponseHandler.success(res, result, 'Login successful');
    } catch (error) {
      logger.error('Login failed:', error);
      
      if (error.name === 'AuthenticationError') {
        return ResponseHandler.unauthorized(res, error.message);
      }
      
      return ResponseHandler.error(res, 'Login failed');
    }
  }

  // Refresh access token
  static async refreshToken(req, res) {
    try {
      const { refreshToken } = req.body;
      
      if (!refreshToken) {
        return ResponseHandler.validationError(res, [{ 
          field: 'refreshToken', 
          message: 'Refresh token is required' 
        }]);
      }
      
      const result = await AuthService.refreshToken(refreshToken);
      
      return ResponseHandler.success(res, result, 'Token refreshed successfully');
    } catch (error) {
      logger.error('Token refresh failed:', error);
      
      if (error.name === 'AuthenticationError') {
        return ResponseHandler.unauthorized(res, error.message);
      }
      
      return ResponseHandler.error(res, 'Token refresh failed');
    }
  }

  // User logout
  static async logout(req, res) {
    try {
      const userId = req.user.userId;
      
      await AuthService.logout(userId);
      
      return ResponseHandler.success(res, null, 'Logout successful');
    } catch (error) {
      logger.error('Logout failed:', error);
      return ResponseHandler.error(res, 'Logout failed');
    }
  }

  // Request password reset
  static async requestPasswordReset(req, res) {
    try {
      const { email } = req.body;
      
      if (!email) {
        return ResponseHandler.validationError(res, [{ 
          field: 'email', 
          message: 'Email is required' 
        }]);
      }
      
      const result = await AuthService.requestPasswordReset(email);
      
      return ResponseHandler.success(res, null, result.message);
    } catch (error) {
      logger.error('Password reset request failed:', error);
      return ResponseHandler.error(res, 'Password reset request failed');
    }
  }

  // Reset password with token
  static async resetPassword(req, res) {
    try {
      const { token, newPassword } = req.body;
      
      if (!token || !newPassword) {
        return ResponseHandler.validationError(res, [
          { field: 'token', message: 'Reset token is required' },
          { field: 'newPassword', message: 'New password is required' }
        ].filter(error => !req.body[error.field]));
      }
      
      const result = await AuthService.resetPassword(token, newPassword);
      
      return ResponseHandler.success(res, null, result.message);
    } catch (error) {
      logger.error('Password reset failed:', error);
      
      if (error.name === 'AuthenticationError') {
        return ResponseHandler.unauthorized(res, error.message);
      }
      
      return ResponseHandler.error(res, 'Password reset failed');
    }
  }

  // Change password (for authenticated users)
  static async changePassword(req, res) {
    try {
      const { currentPassword, newPassword } = req.body;
      const userId = req.user.userId;
      
      if (!currentPassword || !newPassword) {
        return ResponseHandler.validationError(res, [
          { field: 'currentPassword', message: 'Current password is required' },
          { field: 'newPassword', message: 'New password is required' }
        ].filter(error => !req.body[error.field]));
      }
      
      const result = await AuthService.changePassword(userId, currentPassword, newPassword);
      
      return ResponseHandler.success(res, null, result.message);
    } catch (error) {
      logger.error('Password change failed:', error);
      
      if (error.name === 'AuthenticationError') {
        return ResponseHandler.unauthorized(res, error.message);
      }
      
      return ResponseHandler.error(res, 'Password change failed');
    }
  }

  // Get current user profile
  static async getProfile(req, res) {
    try {
      const user = req.user;
      
      return ResponseHandler.success(res, user.toSafeJSON(), 'Profile retrieved successfully');
    } catch (error) {
      logger.error('Get profile failed:', error);
      return ResponseHandler.error(res, 'Failed to retrieve profile');
    }
  }

  // Verify token (health check for tokens)
  static async verifyToken(req, res) {
    try {
      const user = req.user;
      
      return ResponseHandler.success(res, {
        valid: true,
        user: {
          userId: user.userId,
          email: user.email,
          userType: user.userType,
          isActive: user.isActive
        }
      }, 'Token is valid');
    } catch (error) {
      logger.error('Token verification failed:', error);
      return ResponseHandler.unauthorized(res, 'Invalid token');
    }
  }
}

module.exports = AuthController;
```

### src/controllers/UserController.js
```javascript
const UserRepository = require('../repositories/UserRepository');
const AuthService = require('../services/AuthService');
const ResponseHandler = require('../utils/response');
const logger = require('../utils/logger');

class UserController {
  constructor() {
    this.userRepository = new UserRepository();
  }

  // Get user profile
  async getProfile(req, res) {
    try {
      const userId = req.params.userId || req.user.userId;
      
      const user = await this.userRepository.findById(userId);
      if (!user) {
        return ResponseHandler.notFound(res, 'User not found');
      }

      return ResponseHandler.success(res, user.toSafeJSON(), 'Profile retrieved successfully');
    } catch (error) {
      logger.error('Get profile failed:', error);
      return ResponseHandler.error(res, 'Failed to retrieve profile');
    }
  }

  // Update user profile
  async updateProfile(req, res) {
    try {
      const userId = req.params.userId || req.user.userId;
      const updateData = req.body;

      // Remove sensitive fields that shouldn't be updated via this endpoint
      delete updateData.password;
      delete updateData.email;
      delete updateData.userType;
      delete updateData.isActive;

      const updatedUser = await this.userRepository.updateProfile(userId, updateData);
      
      logger.info('Profile updated successfully', { userId });
      
      return ResponseHandler.success(res, updatedUser.toSafeJSON(), 'Profile updated successfully');
    } catch (error) {
      logger.error('Profile update failed:', error);
      
      if (error.message.includes('Validation failed')) {
        return ResponseHandler.validationError(res, [{ message: error.message }]);
      }
      
      return ResponseHandler.error(res, 'Failed to update profile');
    }
  }

  // Get all users (Admin only)
  async getAllUsers(req, res) {
    try {
      const page = parseInt(req.query.page) || 1;
      const limit = parseInt(req.query.limit) || 20;
      const userType = req.query.userType;
      const isActive = req.query.isActive;

      const filters = {};
      if (userType) filters.userType = userType;
      if (isActive !== undefined) filters.isActive = isActive === 'true';

      const result = await this.userRepository.findPaginated(filters, page, limit, {
        orderBy: { createdAt: 'desc' }
      });

      // Remove sensitive data
      result.data = result.data.map(user => ({
        userId: user.userId,
        email: user.email,
        firstName: user.firstName,
        lastName: user.lastName,
        phoneNumber: user.phoneNumber,
        userType: user.userType,
        isActive: user.isActive,
        isEmailVerified: user.isEmailVerified,
        createdAt: user.createdAt,
        lastLoginAt: user.lastLoginAt
      }));

      return ResponseHandler.success(res, result, 'Users retrieved successfully');
    } catch (error) {
      logger.error('Get all users failed:', error);
      return ResponseHandler.error(res, 'Failed to retrieve users');
    }
  }

  // Deactivate user account (Admin only)
  async deactivateUser(req, res) {
    try {
      const { userId } = req.params;
      
      const user = await this.userRepository.findById(userId);
      if (!user) {
        return ResponseHandler.notFound(res, 'User not found');
      }

      await this.userRepository.update(userId, { isActive: false });
      
      logger.info('User deactivated', { 
        deactivatedUserId: userId, 
        adminUserId: req.user.userId 
      });

      return ResponseHandler.success(res, null, 'User deactivated successfully');
    } catch (error) {
      logger.error('User deactivation failed:', error);
      return ResponseHandler.error(res, 'Failed to deactivate user');
    }
  }

  // Activate user account (Admin only)
  async activateUser(req, res) {
    try {
      const { userId } = req.params;
      
      const user = await this.userRepository.findById(userId);
      if (!user) {
        return ResponseHandler.notFound(res, 'User not found');
      }

      await this.userRepository.update(userId, { isActive: true });
      
      logger.info('User activated', { 
        activatedUserId: userId, 
        adminUserId: req.user.userId 
      });

      return ResponseHandler.success(res, null, 'User activated successfully');
    } catch (error) {
      logger.error('User activation failed:', error);
      return ResponseHandler.error(res, 'Failed to activate user');
    }
  }

  // Get user statistics (Admin only)
  async getUserStats(req, res) {
    try {
      const stats = await this.userRepository.getUserStats();
      
      return ResponseHandler.success(res, stats, 'User statistics retrieved successfully');
    } catch (error) {
      logger.error('Get user stats failed:', error);
      return ResponseHandler.error(res, 'Failed to retrieve user statistics');
    }
  }

  // Verify Ghana Card
  async verifyGhanaCard(req, res) {
    try {
      const userId = req.user.userId;
      const { ghanaCardNumber, personalInfo } = req.body;

      if (!ghanaCardNumber) {
        return ResponseHandler.validationError(res, [{ 
          field: 'ghanaCardNumber', 
          message: 'Ghana Card number is required' 
        }]);
      }

      // In a real implementation, you would validate with Ghana Card API
      // For now, we'll do basic format validation
      const ghanaCardRegex = /^GHA-\d{9}-\d$/;
      if (!ghanaCardRegex.test(ghanaCardNumber)) {
        return ResponseHandler.validationError(res, [{ 
          field: 'ghanaCardNumber', 
          message: 'Invalid Ghana Card format' 
        }]);
      }

      await this.userRepository.verifyGhanaCard(userId, {
        cardNumber: ghanaCardNumber,
        personalInfo
      });

      logger.info('Ghana Card verified', { userId, ghanaCardNumber });

      return ResponseHandler.success(res, null, 'Ghana Card verified successfully');
    } catch (error) {
      logger.error('Ghana Card verification failed:', error);
      return ResponseHandler.error(res, 'Ghana Card verification failed');
    }
  }
}

module.exports = new UserController();
```

---

## 🛣️ Routes Implementation

### src/routes/auth.js
```javascript
const express = require('express');
const AuthController = require('../controllers/AuthController');
const { authenticate } = require('../middleware/authenticate');
const { 
  loginRateLimit, 
  registerRateLimit, 
  passwordResetRateLimit,
  refreshTokenRateLimit,
  authSpeedLimit,
  progressiveDelay
} = require('../middleware/rateLimiting');
const { validateRegistration, validateLogin, validatePasswordReset } = require('../validators/authValidators');

const router = express.Router();

// Apply speed limiting to all auth routes
router.use(authSpeedLimit);

/**
 * @route   POST /api/v1/auth/register
 * @desc    Register a new user
 * @access  Public
 */
router.post('/register', 
  registerRateLimit,
  validateRegistration,
  AuthController.register
);

/**
 * @route   POST /api/v1/auth/login
 * @desc    Login user
 * @access  Public
 */
router.post('/login', 
  loginRateLimit,
  progressiveDelay,
  validateLogin,
  AuthController.login
);

/**
 * @route   POST /api/v1/auth/refresh
 * @desc    Refresh access token
 * @access  Public
 */
router.post('/refresh', 
  refreshTokenRateLimit,
  AuthController.refreshToken
);

/**
 * @route   POST /api/v1/auth/logout
 * @desc    Logout user
 * @access  Private
 */
router.post('/logout', 
  authenticate,
  AuthController.logout
);

/**
 * @route   POST /api/v1/auth/forgot-password
 * @desc    Request password reset
 * @access  Public
 */
router.post('/forgot-password', 
  passwordResetRateLimit,
  AuthController.requestPasswordReset
);

/**
 * @route   POST /api/v1/auth/reset-password
 * @desc    Reset password with token
 * @access  Public
 */
router.post('/reset-password', 
  passwordResetRateLimit,
  validatePasswordReset,
  AuthController.resetPassword
);

/**
 * @route   POST /api/v1/auth/change-password
 * @desc    Change password (authenticated users)
 * @access  Private
 */
router.post('/change-password', 
  authenticate,
  validatePasswordReset,
  AuthController.changePassword
);

/**
 * @route   GET /api/v1/auth/profile
 * @desc    Get current user profile
 * @access  Private
 */
router.get('/profile', 
  authenticate,
  AuthController.getProfile
);

/**
 * @route   GET /api/v1/auth/verify
 * @desc    Verify token validity
 * @access  Private
 */
router.get('/verify', 
  authenticate,
  AuthController.verifyToken
);

module.exports = router;
```

### src/routes/users.js
```javascript
const express = require('express');
const UserController = require('../controllers/UserController');
const { authenticate } = require('../middleware/authenticate');
const { requireAdmin, requireSelfAccess } = require('../middleware/authorize');
const { createRateLimiter } = require('../middleware/rateLimiting');
const { validateProfileUpdate } = require('../validators/userValidators');

const router = express.Router();

// General rate limiting for user endpoints
const userRateLimit = createRateLimiter({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 50 // 50 requests per window
});

router.use(userRateLimit);

/**
 * @route   GET /api/v1/users
 * @desc    Get all users (Admin only)
 * @access  Private (Admin)
 */
router.get('/', 
  authenticate,
  requireAdmin,
  UserController.getAllUsers
);

/**
 * @route   GET /api/v1/users/stats
 * @desc    Get user statistics (Admin only)
 * @access  Private (Admin)
 */
router.get('/stats', 
  authenticate,
  requireAdmin,
  UserController.getUserStats
);

/**
 * @route   GET /api/v1/users/:userId
 * @desc    Get user profile
 * @access  Private (Self or Admin)
 */
router.get('/:userId', 
  authenticate,
  requireSelfAccess(),
  UserController.getProfile
);

/**
 * @route   PUT /api/v1/users/:userId
 * @desc    Update user profile
 * @access  Private (Self or Admin)
 */
router.put('/:userId', 
  authenticate,
  requireSelfAccess(),
  validateProfileUpdate,
  UserController.updateProfile
);

/**
 * @route   POST /api/v1/users/:userId/deactivate
 * @desc    Deactivate user account
 * @access  Private (Admin)
 */
router.post('/:userId/deactivate', 
  authenticate,
  requireAdmin,
  UserController.deactivateUser
);

/**
 * @route   POST /api/v1/users/:userId/activate
 * @desc    Activate user account
 * @access  Private (Admin)
 */
router.post('/:userId/activate', 
  authenticate,
  requireAdmin,
  UserController.activateUser
);

/**
 * @route   POST /api/v1/users/verify-ghana-card
 * @desc    Verify Ghana Card
 * @access  Private
 */
router.post('/verify-ghana-card', 
  authenticate,
  UserController.verifyGhanaCard
);

module.exports = router;
```

---

## ✅ Validation Implementation

### src/validators/authValidators.js
```javascript
const Joi = require('joi');
const ResponseHandler = require('../utils/response');

// Registration validation schema
const registrationSchema = Joi.object({
  email: Joi.string()
    .email()
    .lowercase()
    .required()
    .messages({
      'string.email': 'Please provide a valid email address',
      'any.required': 'Email is required'
    }),
    
  phoneNumber: Joi.string()
    .pattern(/^\+233[0-9]{9}$/)
    .required()
    .messages({
      'string.pattern.base': 'Phone number must be in format +233XXXXXXXXX',
      'any.required': 'Phone number is required'
    }),
    
  password: Joi.string()
    .min(8)
    .pattern(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]/)
    .required()
    .messages({
      'string.min': 'Password must be at least 8 characters long',
      'string.pattern.base': 'Password must contain at least one lowercase letter, one uppercase letter, one number, and one special character',
      'any.required': 'Password is required'
    }),
    
  firstName: Joi.string()
    .min(2)
    .max(50)
    .pattern(/^[A-Za-z\s]+$/)
    .required()
    .messages({
      'string.min': 'First name must be at least 2 characters',
      'string.max': 'First name must not exceed 50 characters',
      'string.pattern.base': 'First name can only contain letters and spaces',
      'any.required': 'First name is required'
    }),
    
  lastName: Joi.string()
    .min(2)
    .max(50)
    .pattern(/^[A-Za-z\s]+$/)
    .required()
    .messages({
      'string.min': 'Last name must be at least 2 characters',
      'string.max': 'Last name must not exceed 50 characters',
      'string.pattern.base': 'Last name can only contain letters and spaces',
      'any.required': 'Last name is required'
    }),
    
  dateOfBirth: Joi.date()
    .max('now')
    .min('1900-01-01')
    .required()
    .messages({
      'date.max': 'Date of birth cannot be in the future',
      'date.min': 'Please provide a valid date of birth',
      'any.required': 'Date of birth is required'
    }),
    
  ghanaCardNumber: Joi.string()
    .pattern(/^GHA-\d{9}-\d$/)
    .optional()
    .messages({
      'string.pattern.base': 'Ghana Card number must be in format GHA-XXXXXXXXX-X'
    }),
    
  userType: Joi.string()
    .valid('CUSTOMER', 'CONTRACTOR')
    .default('CUSTOMER')
    .messages({
      'any.only': 'User type must be either CUSTOMER or CONTRACTOR'
    })
});

// Login validation schema
const loginSchema = Joi.object({
  email: Joi.string()
    .email()
    .lowercase()
    .required()
    .messages({
      'string.email': 'Please provide a valid email address',
      'any.required': 'Email is required'
    }),
    
  password: Joi.string()
    .required()
    .messages({
      'any.required': 'Password is required'
    })
});

// Password reset validation schema
const passwordResetSchema = Joi.object({
  newPassword: Joi.string()
    .min(8)
    .pattern(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]/)
    .required()
    .messages({
      'string.min': 'Password must be at least 8 characters long',
      'string.pattern.base': 'Password must contain at least one lowercase letter, one uppercase letter, one number, and one special character',
      'any.required': 'New password is required'
    }),
    
  confirmPassword: Joi.string()
    .valid(Joi.ref('newPassword'))
    .required()
    .messages({
      'any.only': 'Passwords do not match',
      'any.required': 'Password confirmation is required'
    })
});

// Validation middleware functions
const validateRegistration = (req, res, next) => {
  const { error } = registrationSchema.validate(req.body, { abortEarly: false });
  
  if (error) {
    const errors = error.details.map(detail => ({
      field: detail.path.join('.'),
      message: detail.message
    }));
    
    return ResponseHandler.validationError(res, errors);
  }
  
  next();
};

const validateLogin = (req, res, next) => {
  const { error } = loginSchema.validate(req.body, { abortEarly: false });
  
  if (error) {
    const errors = error.details.map(detail => ({
      field: detail.path.join('.'),
      message: detail.message
    }));
    
    return ResponseHandler.validationError(res, errors);
  }
  
  next();
};

const validatePasswordReset = (req, res, next) => {
  const { error } = passwordResetSchema.validate(req.body, { abortEarly: false });
  
  if (error) {
    const errors = error.details.map(detail => ({
      field: detail.path.join('.'),
      message: detail.message
    }));
    
    return ResponseHandler.validationError(res, errors);
  }
  
  next();
};

module.exports = {
  validateRegistration,
  validateLogin,
  validatePasswordReset,
  registrationSchema,
  loginSchema,
  passwordResetSchema
};
```

---

## 🧪 Testing Implementation

### tests/auth/auth.test.js
```javascript
const request = require('supertest');
const app = require('../../src/app');
const DatabaseConnection = require('../../src/database/connection');
const { setupTest, teardownTest, createTestUser, cleanupTestData } = require('../helpers/testSetup');

describe('Authentication Endpoints', () => {
  beforeAll(async () => {
    await setupTest();
  });

  afterAll(async () => {
    await teardownTest();
  });

  beforeEach(async () => {
    await cleanupTestData();
  });

  describe('POST /api/v1/auth/register', () => {
    const validUserData = {
      email: 'test@example.com',
      phoneNumber: '+233501234567',
      password: 'TestPass123!',
      firstName: 'Test',
      lastName: 'User',
      dateOfBirth: '1990-01-01',
      userType: 'CUSTOMER'
    };

    test('should register user with valid data', async () => {
      const response = await request(app)
        .post('/api/v1/auth/register')
        .send(validUserData)
        .expect(201);

      expect(response.body.success).toBe(true);
      expect(response.body.data.user.email).toBe(validUserData.email);
      expect(response.body.data.tokens.accessToken).toBeDefined();
      expect(response.body.data.tokens.refreshToken).toBeDefined();
    });

    test('should reject registration with invalid email', async () => {
      const response = await request(app)
        .post('/api/v1/auth/register')
        .send({ ...validUserData, email: 'invalid-email' })
        .expect(400);

      expect(response.body.success).toBe(false);
      expect(response.body.errors).toContainEqual(
        expect.objectContaining({
          field: 'email',
          message: expect.stringContaining('valid email')
        })
      );
    });

    test('should reject registration with weak password', async () => {
      const response = await request(app)
        .post('/api/v1/auth/register')
        .send({ ...validUserData, password: '123' })
        .expect(400);

      expect(response.body.success).toBe(false);
      expect(response.body.errors).toContainEqual(
        expect.objectContaining({
          field: 'password'
        })
      );
    });

    test('should reject duplicate email registration', async () => {
      // First registration
      await request(app)
        .post('/api/v1/auth/register')
        .send(validUserData)
        .expect(201);

      // Second registration with same email
      const response = await request(app)
        .post('/api/v1/auth/register')
        .send({ ...validUserData, phoneNumber: '+233507654321' })
        .expect(400);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain('already exists');
    });
  });

  describe('POST /api/v1/auth/login', () => {
    let testUser;

    beforeEach(async () => {
      testUser = await createTestUser({
        email: 'login@example.com',
        password: 'LoginPass123!'
      });
    });

    test('should login with valid credentials', async () => {
      const response = await request(app)
        .post('/api/v1/auth/login')
        .send({
          email: 'login@example.com',
          password: 'LoginPass123!'
        })
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data.user.email).toBe('login@example.com');
      expect(response.body.data.tokens.accessToken).toBeDefined();
    });

    test('should reject login with invalid email', async () => {
      const response = await request(app)
        .post('/api/v1/auth/login')
        .send({
          email: 'nonexistent@example.com',
          password: 'LoginPass123!'
        })
        .expect(401);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain('Invalid email or password');
    });

    test('should reject login with invalid password', async () => {
      const response = await request(app)
        .post('/api/v1/auth/login')
        .send({
          email: 'login@example.com',
          password: 'WrongPassword'
        })
        .expect(401);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain('Invalid email or password');
    });

    test('should reject login for inactive user', async () => {
      // Deactivate user
      const client = DatabaseConnection.getClient();
      await client.user.update({
        where: { userId: testUser.userId },
        data: { isActive: false }
      });

      const response = await request(app)
        .post('/api/v1/auth/login')
        .send({
          email: 'login@example.com',
          password: 'LoginPass123!'
        })
        .expect(401);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain('deactivated');
    });
  });

  describe('POST /api/v1/auth/refresh', () => {
    let tokens;

    beforeEach(async () => {
      const user = await createTestUser();
      const loginResponse = await request(app)
        .post('/api/v1/auth/login')
        .send({
          email: user.email,
          password: 'TestPass123!'
        });
      
      tokens = loginResponse.body.data.tokens;
    });

    test('should refresh token with valid refresh token', async () => {
      const response = await request(app)
        .post('/api/v1/auth/refresh')
        .send({
          refreshToken: tokens.refreshToken
        })
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data.tokens.accessToken).toBeDefined();
      expect(response.body.data.tokens.refreshToken).toBeDefined();
      expect(response.body.data.tokens.accessToken).not.toBe(tokens.accessToken);
    });

    test('should reject refresh with invalid token', async () => {
      const response = await request(app)
        .post('/api/v1/auth/refresh')
        .send({
          refreshToken: 'invalid-token'
        })
        .expect(401);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain('Invalid refresh token');
    });

    test('should reject refresh without token', async () => {
      const response = await request(app)
        .post('/api/v1/auth/refresh')
        .send({})
        .expect(400);

      expect(response.body.success).toBe(false);
    });
  });

  describe('POST /api/v1/auth/logout', () => {
    let authToken;

    beforeEach(async () => {
      const user = await createTestUser();
      const loginResponse = await request(app)
        .post('/api/v1/auth/login')
        .send({
          email: user.email,
          password: 'TestPass123!'
        });
      
      authToken = loginResponse.body.data.tokens.accessToken;
    });

    test('should logout authenticated user', async () => {
      const response = await request(app)
        .post('/api/v1/auth/logout')
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.message).toContain('Logout successful');
    });

    test('should reject logout without authentication', async () => {
      const response = await request(app)
        .post('/api/v1/auth/logout')
        .expect(401);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain('Authorization header missing');
    });
  });

  describe('GET /api/v1/auth/profile', () => {
    let authToken;
    let testUser;

    beforeEach(async () => {
      testUser = await createTestUser();
      const loginResponse = await request(app)
        .post('/api/v1/auth/login')
        .send({
          email: testUser.email,
          password: 'TestPass123!'
        });
      
      authToken = loginResponse.body.data.tokens.accessToken;
    });

    test('should get profile for authenticated user', async () => {
      const response = await request(app)
        .get('/api/v1/auth/profile')
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data.email).toBe(testUser.email);
      expect(response.body.data.password).toBeUndefined(); // Password should not be returned
    });

    test('should reject profile request without authentication', async () => {
      const response = await request(app)
        .get('/api/v1/auth/profile')
        .expect(401);

      expect(response.body.success).toBe(false);
    });
  });

  describe('POST /api/v1/auth/change-password', () => {
    let authToken;
    let testUser;

    beforeEach(async () => {
      testUser = await createTestUser();
      const loginResponse = await request(app)
        .post('/api/v1/auth/login')
        .send({
          email: testUser.email,
          password: 'TestPass123!'
        });
      
      authToken = loginResponse.body.data.tokens.accessToken;
    });

    test('should change password with valid data', async () => {
      const response = await request(app)
        .post('/api/v1/auth/change-password')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          currentPassword: 'TestPass123!',
          newPassword: 'NewPass123!',
          confirmPassword: 'NewPass123!'
        })
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.message).toContain('Password changed successfully');

      // Verify can login with new password
      const loginResponse = await request(app)
        .post('/api/v1/auth/login')
        .send({
          email: testUser.email,
          password: 'NewPass123!'
        })
        .expect(200);

      expect(loginResponse.body.success).toBe(true);
    });

    test('should reject password change with wrong current password', async () => {
      const response = await request(app)
        .post('/api/v1/auth/change-password')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          currentPassword: 'WrongPassword',
          newPassword: 'NewPass123!',
          confirmPassword: 'NewPass123!'
        })
        .expect(401);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain('Current password is incorrect');
    });

    test('should reject password change without authentication', async () => {
      const response = await request(app)
        .post('/api/v1/auth/change-password')
        .send({
          currentPassword: 'TestPass123!',
          newPassword: 'NewPass123!',
          confirmPassword: 'NewPass123!'
        })
        .expect(401);

      expect(response.body.success).toBe(false);
    });
  });
});
```

### tests/auth/authorization.test.js
```javascript
const request = require('supertest');
const app = require('../../src/app');
const { setupTest, teardownTest, createTestUser, cleanupTestData } = require('../helpers/testSetup');

describe('Authorization Middleware', () => {
  beforeAll(async () => {
    await setupTest();
  });

  afterAll(async () => {
    await teardownTest();
  });

  beforeEach(async () => {
    await cleanupTestData();
  });

  describe('Role-based Authorization', () => {
    let customerToken, adminToken, contractorToken;
    let customerUser, adminUser, contractorUser;

    beforeEach(async () => {
      // Create users with different roles
      customerUser = await createTestUser({ userType: 'CUSTOMER' });
      adminUser = await createTestUser({ 
        email: 'admin@test.com',
        phoneNumber: '+233501111111',
        userType: 'ADMIN' 
      });
      contractorUser = await createTestUser({ 
        email: 'contractor@test.com',
        phoneNumber: '+233502222222',
        userType: 'CONTRACTOR' 
      });

      // Get tokens
      const customerLogin = await request(app)
        .post('/api/v1/auth/login')
        .send({
          email: customerUser.email,
          password: 'TestPass123!'
        });
      customerToken = customerLogin.body.data.tokens.accessToken;

      const adminLogin = await request(app)
        .post('/api/v1/auth/login')
        .send({
          email: adminUser.email,
          password: 'TestPass123!'
        });
      adminToken = adminLogin.body.data.tokens.accessToken;

      const contractorLogin = await request(app)
        .post('/api/v1/auth/login')
        .send({
          email: contractorUser.email,
          password: 'TestPass123!'
        });
      contractorToken = contractorLogin.body.data.tokens.accessToken;
    });

    test('admin should access admin-only endpoints', async () => {
      const response = await request(app)
        .get('/api/v1/users')
        .set('Authorization', `Bearer ${adminToken}`)
        .expect(200);

      expect(response.body.success).toBe(true);
    });

    test('customer should not access admin-only endpoints', async () => {
      const response = await request(app)
        .get('/api/v1/users')
        .set('Authorization', `Bearer ${customerToken}`)
        .expect(403);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain('Insufficient permissions');
    });

    test('contractor should not access admin-only endpoints', async () => {
      const response = await request(app)
        .get('/api/v1/users')
        .set('Authorization', `Bearer ${contractorToken}`)
        .expect(403);

      expect(response.body.success).toBe(false);
    });

    test('users should access their own profile', async () => {
      const response = await request(app)
        .get(`/api/v1/users/${customerUser.userId}`)
        .set('Authorization', `Bearer ${customerToken}`)
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data.userId).toBe(customerUser.userId);
    });

    test('users should not access other users profiles', async () => {
      const response = await request(app)
        .get(`/api/v1/users/${adminUser.userId}`)
        .set('Authorization', `Bearer ${customerToken}`)
        .expect(403);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain('Can only access your own resources');
    });

    test('admin should access any user profile', async () => {
      const response = await request(app)
        .get(`/api/v1/users/${customerUser.userId}`)
        .set('Authorization', `Bearer ${adminToken}`)
        .expect(200);

      expect(response.body.success).toBe(true);
    });
  });

  describe('Token Validation', () => {
    test('should reject invalid token format', async () => {
      const response = await request(app)
        .get('/api/v1/auth/profile')
        .set('Authorization', 'InvalidToken')
        .expect(401);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain('Invalid authorization format');
    });

    test('should reject malformed token', async () => {
      const response = await request(app)
        .get('/api/v1/auth/profile')
        .set('Authorization', 'Bearer invalid.token.here')
        .expect(401);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain('Invalid token');
    });

    test('should reject expired token', async () => {
      // This would require creating an expired token
      // For now, we'll test with a clearly invalid token
      const response = await request(app)
        .get('/api/v1/auth/profile')
        .set('Authorization', 'Bearer expired.token.here')
        .expect(401);

      expect(response.body.success).toBe(false);
    });
  });
});
```

### tests/auth/security.test.js
```javascript
const request = require('supertest');
const app = require('../../src/app');
const { setupTest, teardownTest, cleanupTestData } = require('../helpers/testSetup');

describe('Security Features', () => {
  beforeAll(async () => {
    await setupTest();
  });

  afterAll(async () => {
    await teardownTest();
  });

  beforeEach(async () => {
    await cleanupTestData();
  });

  describe('Rate Limiting', () => {
    test('should limit login attempts', async () => {
      const loginData = {
        email: 'test@example.com',
        password: 'wrongpassword'
      };

      // Make multiple failed login attempts
      const attempts = [];
      for (let i = 0; i < 6; i++) {
        attempts.push(
          request(app)
            .post('/api/v1/auth/login')
            .send(loginData)
        );
      }

      const responses = await Promise.all(attempts);
      
      // First few should return 401 (unauthorized)
      expect(responses[0].status).toBe(401);
      expect(responses[1].status).toBe(401);
      
      // Later attempts should be rate limited (429)
      const rateLimitedResponse = responses.find(r => r.status === 429);
      expect(rateLimitedResponse).toBeDefined();
    }, 10000); // Increase timeout for this test

    test('should limit registration attempts', async () => {
      const baseUserData = {
        phoneNumber: '+233501234567',
        password: 'TestPass123!',
        firstName: 'Test',
        lastName: 'User',
        dateOfBirth: '1990-01-01'
      };

      // Make multiple registration attempts
      const attempts = [];
      for (let i = 0; i < 5; i++) {
        attempts.push(
          request(app)
            .post('/api/v1/auth/register')
            .send({
              ...baseUserData,
              email: `test${i}@example.com`,
              phoneNumber: `+23350123456${i}`
            })
        );
      }

      const responses = await Promise.all(attempts);
      
      // Should eventually get rate limited
      const rateLimitedResponse = responses.find(r => r.status === 429);
      expect(rateLimitedResponse).toBeDefined();
    }, 10000);
  });

  describe('Input Validation', () => {
    test('should sanitize email input', async () => {
      const response = await request(app)
        .post('/api/v1/auth/register')
        .send({
          email: '  TEST@EXAMPLE.COM  ',
          phoneNumber: '+233501234567',
          password: 'TestPass123!',
          firstName: 'Test',
          lastName: 'User',
          dateOfBirth: '1990-01-01'
        })
        .expect(201);

      expect(response.body.data.user.email).toBe('test@example.com');
    });

    test('should reject XSS attempts in names', async () => {
      const response = await request(app)
        .post('/api/v1/auth/register')
        .send({
          email: 'test@example.com',
          phoneNumber: '+233501234567',
          password: 'TestPass123!',
          firstName: '<script>alert("xss")</script>',
          lastName: 'User',
          dateOfBirth: '1990-01-01'
        })
        .expect(400);

      expect(response.body.success).toBe(false);
      expect(response.body.errors).toContainEqual(
        expect.objectContaining({
          field: 'firstName'
        })
      );
    });

    test('should enforce password complexity', async () => {
      const weakPasswords = [
        'password',
        '12345678',
        'PASSWORD',
        'Pass123', // Missing special character
        'pass123!', // Missing uppercase
        'PASS123!', // Missing lowercase
      ];

      for (const password of weakPasswords) {
        const response = await request(app)
          .post('/api/v1/auth/register')
          .send({
            email: `test${Date.now()}@example.com`,
            phoneNumber: `+23350123456${Math.random()}`,
            password,
            firstName: 'Test',
            lastName: 'User',
            dateOfBirth: '1990-01-01'
          })
          .expect(400);

        expect(response.body.success).toBe(false);
        expect(response.body.errors).toContainEqual(
          expect.objectContaining({
            field: 'password'
          })
        );
      }
    });
  });

  describe('Security Headers', () => {
    test('should include security headers', async () => {
      const response = await request(app)
        .get('/api/v1/health')
        .expect(200);

      expect(response.headers['x-frame-options']).toBe('DENY');
      expect(response.headers['x-content-type-options']).toBe('nosniff');
      expect(response.headers['x-xss-protection']).toBe('0');
    });

    test('should include CORS headers', async () => {
      const response = await request(app)
        .get('/api/v1/health')
        .expect(200);

      expect(response.headers['access-control-allow-origin']).toBeDefined();
    });
  });

  describe('Password Security', () => {
    test('should not return password in any response', async () => {
      const userData = {
        email: 'security@example.com',
        phoneNumber: '+233501234567',
        password: 'TestPass123!',
        firstName: 'Security',
        lastName: 'Test',
        dateOfBirth: '1990-01-01'
      };

      // Registration response
      const registerResponse = await request(app)
        .post('/api/v1/auth/register')
        .send(userData)
        .expect(201);

      expect(registerResponse.body.data.user.password).toBeUndefined();

      // Login response
      const loginResponse = await request(app)
        .post('/api/v1/auth/login')
        .send({
          email: userData.email,
          password: userData.password
        })
        .expect(200);

      expect(loginResponse.body.data.user.password).toBeUndefined();

      // Profile response
      const token = loginResponse.body.data.tokens.accessToken;
      const profileResponse = await request(app)
        .get('/api/v1/auth/profile')
        .set('Authorization', `Bearer ${token}`)
        .expect(200);

      expect(profileResponse.body.data.password).toBeUndefined();
    });
  });
});
```

---

## 📄 Environment Variables Update

### .env.example (Additional Variables)
```bash
# JWT Configuration
JWT_SECRET=your-super-secret-jwt-key-here-make-it-long-and-random
JWT_REFRESH_SECRET=your-super-secret-refresh-key-different-from-jwt-secret
JWT_EXPIRES_IN=1h
JWT_REFRESH_EXPIRES_IN=7d

# Password Reset Configuration
PASSWORD_RESET_EXPIRY=15m

# Rate Limiting Configuration
AUTH_RATE_LIMIT_WINDOW=900000
AUTH_RATE_LIMIT_MAX=5
LOGIN_RATE_LIMIT_MAX=5
REGISTER_RATE_LIMIT_MAX=3

# Security Configuration
BCRYPT_ROUNDS=12
MAX_LOGIN_ATTEMPTS=5
LOCKOUT_DURATION=900000

# Session Configuration
SESSION_SECRET=your-session-secret-key
SESSION_TIMEOUT=3600000
```

---

## 📋 App.js Updates

### src/app.js (Add Authentication Routes)
```javascript
// ... existing imports and configuration ...

// Import new authentication routes
const authRoutes = require('./routes/auth');
const userRoutes = require('./routes/users');

// ... existing middleware ...

// API routes with authentication
app.use(`${config.API_PREFIX}/${config.API_VERSION}/auth`, authRoutes);
app.use(`${config.API_PREFIX}/${config.API_VERSION}/users`, userRoutes);

// ... rest of existing configuration ...
```

---

## ✅ Module Completion Checklist

### Authentication Features ✅
- [ ] User registration with validation
- [ ] User login with JWT tokens
- [ ] Token refresh mechanism
- [ ] Password reset functionality
- [ ] Password change for authenticated users
- [ ] Token verification endpoints

### Authorization Features ✅
- [ ] Role-based access control (RBAC)
- [ ] Resource-based permissions
- [ ] Self-access restrictions
- [ ] Admin-only endpoints
- [ ] Permission service implementation

### Security Features ✅
- [ ] Rate limiting on auth endpoints
- [ ] Progressive delay for failed attempts
- [ ] Password complexity validation
- [ ] Input sanitization and validation
- [ ] JWT token security
- [ ] No password exposure in responses

### Middleware ✅
- [ ] Authentication middleware
- [ ] Authorization middleware
- [ ] Rate limiting middleware
- [ ] Input validation middleware
- [ ] Security headers middleware

### Testing & Documentation ✅
- [ ] Authentication endpoint tests
- [ ] Authorization middleware tests
- [ ] Security feature tests
- [ ] Rate limiting tests
- [ ] Token validation tests

---

## 🚀 Quick Start Commands

```bash
# Install new dependencies
npm install jsonwebtoken bcrypt speakeasy nodemailer

# Generate JWT secrets
node -e "console.log('JWT_SECRET=' + require('crypto').randomBytes(64).toString('hex'))"
node -e "console.log('JWT_REFRESH_SECRET=' + require('crypto').randomBytes(64).toString('hex'))"

# Test authentication
npm run test:auth

# Start with authentication
npm run dev

# Test endpoints
curl -X POST http://localhost:3000/api/v1/auth/register -H "Content-Type: application/json" -d '{"email":"test@example.com","password":"TestPass123!","firstName":"Test","lastName":"User","phoneNumber":"+233501234567","dateOfBirth":"1990-01-01"}'
```

---

## 🎯 Success Verification

### Manual Testing Checklist:
```bash
# 1. User Registration
curl -X POST http://localhost:3000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "TestPass123!",
    "firstName": "Test",
    "lastName": "User",
    "phoneNumber": "+233501234567",
    "dateOfBirth": "1990-01-01"
  }'

# 2. User Login
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "TestPass123!"
  }'

# 3. Protected Route Access
TOKEN="your-access-token-here"
curl -X GET http://localhost:3000/api/v1/auth/profile \
  -H "Authorization: Bearer $TOKEN"

# 4. Rate Limiting Test
for i in {1..10}; do
  curl -X POST http://localhost:3000/api/v1/auth/login \
    -H "Content-Type: application/json" \
    -d '{"email":"wrong@example.com","password":"wrong"}'
done
```

**You've successfully completed Module 3 when:**
- ✅ Users can register and login
- ✅ JWT tokens are generated and validated
- ✅ Protected routes require authentication
- ✅ Role-based access control works
- ✅ Rate limiting prevents abuse
- ✅ All authentication tests pass

**Next:** Ready for Module 4 (Product Catalog Service) 🛍️```
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