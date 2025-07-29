# Module 3: Authentication System
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