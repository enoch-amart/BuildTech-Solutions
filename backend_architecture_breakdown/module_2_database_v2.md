---

## 🛠 Technology Stack

| Component | Technology | Version | Purpose |
|-----------|------------|---------|---------|
| **Database** | PostgreSQL | 15+ | Primary database |
| **ORM** | Prisma | 5.x | Database toolkit and ORM |
| **Connection Pool** | Built-in Prisma | - | Connection management |
| **Migration Tool** | Prisma Migrate | - | Schema migrations |
| **Seeding** | Prisma Seed | - | Initial data population |
| **Validation** | Joi | 17.x | Data validation |
| **Testing DB** | SQLite | - | Test database (optional) |

---

## 📦 Additional Dependencies

### Package.json Updates
```json
{
  "dependencies": {
    "@prisma/client": "^5.2.0",
    "uuid": "^9.0.0"
  },
  "devDependencies": {
    "prisma": "^5.2.0"
  },
  "prisma": {
    "seed": "node prisma/seeds/index.js"
  },
  "scripts": {
    "db:generate": "prisma generate",
    "db:migrate": "prisma migrate dev",
    "db:migrate:prod": "prisma migrate deploy",
    "db:seed": "prisma db seed",
    "db:reset": "prisma migrate reset",
    "db:studio": "prisma studio",
    "db:setup": "node scripts/db-setup.js"
  }
}
```

---

## 🗄️ Database Schema Design

### prisma/schema.prisma
```prisma
// This is your Prisma schema file,
// learn more about it in the docs: https://pris.ly/d/prisma-schema

generator client {
  provider = "prisma-client-js"
  binaryTargets = ["native", "linux-musl"]
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

// User Model
model User {
  // Primary Key
  userId            String   @id @default(uuid()) @db.Uuid
  
  // Authentication Fields
  email             String   @unique @db.VarChar(255)
  phoneNumber       String   @unique @db.VarChar(20)
  password          String   @db.VarChar(255)
  
  // Personal Information
  firstName         String   @db.VarChar(100)
  lastName          String   @db.VarChar(100)
  dateOfBirth       DateTime @db.Date
  
  // Ghana Card Information (encrypted)
  ghanaCardNumber   String?  @db.VarChar(255)
  ghanaCardVerified Boolean  @default(false)
  
  // User Type and Status
  userType          UserType @default(CUSTOMER)
  isActive          Boolean  @default(true)
  isEmailVerified   Boolean  @default(false)
  isPhoneVerified   Boolean  @default(false)
  
  // Timestamps
  createdAt         DateTime @default(now())
  updatedAt         DateTime @updatedAt
  lastLoginAt       DateTime?
  
  // Relations
  addresses         UserAddress[]
  orders            Order[]
  creditAccount     CreditAccount?
  
  @@map("users")
  @@index([email])
  @@index([phoneNumber])
  @@index([userType])
}

// User Types Enum
enum UserType {
  CUSTOMER
  CONTRACTOR
  ADMIN
  DRIVER
  CONSULTANT
}

// User Address Model
model UserAddress {
  // Primary Key
  addressId     String  @id @default(uuid()) @db.Uuid
  
  // Address Information
  addressType   AddressType @default(DELIVERY)
  addressLine1  String  @db.VarChar(255)
  addressLine2  String? @db.VarChar(255)
  city          String  @db.VarChar(100)
  region        String  @db.VarChar(100)
  postalCode    String? @db.VarChar(20)
  
  // GPS Coordinates
  latitude      Decimal? @db.Decimal(10, 8)
  longitude     Decimal? @db.Decimal(11, 8)
  
  // Status
  isDefault     Boolean @default(false)
  isActive      Boolean @default(true)
  
  // Timestamps
  createdAt     DateTime @default(now())
  updatedAt     DateTime @updatedAt
  
  // Relations
  userId        String   @db.Uuid
  user          User     @relation(fields: [userId], references: [userId], onDelete: Cascade)
  orders        Order[]
  
  @@map("user_addresses")
  @@index([userId])
}

enum AddressType {
  DELIVERY
  BILLING
  BOTH
}

// Product Category Model
model ProductCategory {
  // Primary Key
  categoryId    String  @id @default(uuid()) @db.Uuid
  
  // Category Information
  categoryName  String  @unique @db.VarChar(100)
  description   String? @db.Text
  imageUrl      String? @db.VarChar(500)
  
  // Hierarchy
  parentId      String? @db.Uuid
  parent        ProductCategory? @relation("CategoryHierarchy", fields: [parentId], references: [categoryId])
  children      ProductCategory[] @relation("CategoryHierarchy")
  
  // Display Order
  sortOrder     Int     @default(0)
  isActive      Boolean @default(true)
  
  // Timestamps
  createdAt     DateTime @default(now())
  updatedAt     DateTime @updatedAt
  
  // Relations
  products      Product[]
  
  @@map("product_categories")
  @@index([categoryName])
  @@index([isActive])
}

// Product Model
model Product {
  // Primary Key
  productId     String  @id @default(uuid()) @db.Uuid
  
  // Product Information
  productName   String  @db.VarChar(255)
  description   String? @db.Text
  brand         String? @db.VarChar(100)
  model         String? @db.VarChar(100)
  sku           String? @unique @db.VarChar(100)
  
  // Pricing
  unitPrice     Decimal @db.Decimal(10, 2)
  costPrice     Decimal? @db.Decimal(10, 2)
  currency      String  @default("GHS") @db.VarChar(3)
  
  // Physical Properties
  weight        Decimal? @db.Decimal(8, 3)
  dimensions    String? @db.VarChar(100) // "L x W x H"
  color         String? @db.VarChar(50)
  material      String? @db.VarChar(100)
  
  // Business Rules
  isBulkItem    Boolean  @default(false)
  bulkMinQty    Int?     // Minimum quantity for bulk discount
  bulkDiscount  Decimal? @db.Decimal(5, 2) // Percentage discount
  
  // Status
  isActive      Boolean  @default(true)
  isPublished   Boolean  @default(false)
  
  // Timestamps
  createdAt     DateTime @default(now())
  updatedAt     DateTime @updatedAt
  
  // Relations
  categoryId    String   @db.Uuid
  category      ProductCategory @relation(fields: [categoryId], references: [categoryId])
  inventory     Inventory?
  images        ProductImage[]
  orderItems    OrderItem[]
  cartItems     CartItem[]
  
  @@map("products")
  @@index([productName])
  @@index([categoryId])
  @@index([isActive, isPublished])
  @@index([brand])
}

// Product Image Model
model ProductImage {
  // Primary Key
  imageId       String  @id @default(uuid()) @db.Uuid
  
  // Image Information
  imageUrl      String  @db.VarChar(500)
  altText       String? @db.VarChar(255)
  isPrimary     Boolean @default(false)
  sortOrder     Int     @default(0)
  
  // Timestamps
  uploadedAt    DateTime @default(now())
  
  // Relations
  productId     String   @db.Uuid
  product       Product  @relation(fields: [productId], references: [productId], onDelete: Cascade)
  
  @@map("product_images")
  @@index([productId])
}

// Inventory Model
model Inventory {
  // Primary Key
  inventoryId     String  @id @default(uuid()) @db.Uuid
  
  // Stock Information
  availableStock  Int     @default(0)
  reservedStock   Int     @default(0)
  reorderLevel    Int     @default(10)
  maxStockLevel   Int?
  
  // Location
  warehouseLocation String? @db.VarChar(255)
  shelfLocation     String? @db.VarChar(100)
  
  // Timestamps
  lastStockUpdate   DateTime @default(now())
  createdAt         DateTime @default(now())
  updatedAt         DateTime @updatedAt
  
  // Relations
  productId       String  @unique @db.Uuid
  product         Product @relation(fields: [productId], references: [productId], onDelete: Cascade)
  
  @@map("inventory")
  @@index([availableStock])
  @@index([reorderLevel])
}

// Order Model (Basic structure for Module 5)
model Order {
  // Primary Key
  orderId         String      @id @default(uuid()) @db.Uuid
  orderNumber     String      @unique @db.VarChar(50)
  
  // Order Information
  totalAmount     Decimal     @db.Decimal(12, 2)
  orderStatus     OrderStatus @default(PENDING)
  
  // Timestamps
  orderPlacedAt   DateTime    @default(now())
  createdAt       DateTime    @default(now())
  updatedAt       DateTime    @updatedAt
  
  // Relations
  customerId      String      @db.Uuid
  customer        User        @relation(fields: [customerId], references: [userId])
  
  deliveryAddressId String?   @db.Uuid
  deliveryAddress   UserAddress? @relation(fields: [deliveryAddressId], references: [addressId])
  
  orderItems      OrderItem[]
  
  @@map("orders")
  @@index([customerId])
  @@index([orderStatus])
  @@index([orderPlacedAt])
}

enum OrderStatus {
  PENDING
  CONFIRMED
  PROCESSING
  SHIPPED
  DELIVERED
  CANCELLED
  RETURNED
}

// Order Item Model (Basic structure for Module 5)
model OrderItem {
  // Primary Key
  orderItemId   String  @id @default(uuid()) @db.Uuid
  
  // Item Information
  quantity      Int
  unitPrice     Decimal @db.Decimal(10, 2)
  totalPrice    Decimal @db.Decimal(12, 2)
  
  // Relations
  orderId       String  @db.Uuid
  order         Order   @relation(fields: [orderId], references: [orderId], onDelete: Cascade)
  
  productId     String  @db.Uuid
  product       Product @relation(fields: [productId], references: [productId])
  
  @@map("order_items")
  @@index([orderId])
  @@index([productId])
}

// Cart Item Model (Basic structure for Module 5)
model CartItem {
  // Primary Key
  cartItemId    String  @id @default(uuid()) @db.Uuid
  
  // Item Information
  quantity      Int
  
  // Timestamps
  addedAt       DateTime @default(now())
  updatedAt     DateTime @updatedAt
  
  // Relations
  userId        String  @db.Uuid
  user          User    @relation(fields: [userId], references: [userId], onDelete: Cascade)
  
  productId     String  @db.Uuid
  product       Product @relation(fields: [productId], references: [productId], onDelete: Cascade)
  
  @@map("cart_items")
  @@unique([userId, productId])
  @@index([userId])
}

// Credit Account Model (Basic structure for Module 6)
model CreditAccount {
  // Primary Key
  creditAccountId String  @id @default(uuid()) @db.Uuid
  
  // Account Information
  creditLimit     Decimal @db.Decimal(10, 2)
  currentBalance  Decimal @db.Decimal(10, 2) @default(0)
  availableCredit Decimal @db.Decimal(10, 2)
  
  // Status
  isActive        Boolean @default(true)
  
  // Timestamps
  createdAt       DateTime @default(now())
  updatedAt       DateTime @updatedAt
  
  // Relations
  userId          String  @unique @db.Uuid
  user            User    @relation(fields: [userId], references: [userId], onDelete: Cascade)
  
  @@map("credit_accounts")
}
```

---

## 🔧 Database Connection & Client

### src/database/client.js
```javascript
const { PrismaClient } = require('@prisma/client');
const logger = require('../utils/logger');

class DatabaseClient {
  constructor() {
    this.prisma = null;
  }

  async connect() {
    if (this.prisma) {
      return this.prisma;
    }

    try {
      this.prisma = new PrismaClient({
        log: [
          {
            emit: 'event',
            level: 'query',
          },
          {
            emit: 'event',
            level: 'error',
          },
          {
            emit: 'event',
            level: 'info',
          },
          {
            emit: 'event',
            level: 'warn',
          },
        ],
        errorFormat: 'colorless'
      });

      // Setup logging
      this.setupLogging();

      // Test connection
      await this.prisma.$connect();
      
      logger.info('Database connected successfully');
      return this.prisma;
    } catch (error) {
      logger.error('Database connection failed:', error);
      throw error;
    }
  }

  setupLogging() {
    if (process.env.NODE_ENV === 'development') {
      this.prisma.$on('query', (e) => {
        logger.debug('Database query:', {
          query: e.query,
          params: e.params,
          duration: `${e.duration}ms`
        });
      });
    }

    this.prisma.$on('error', (e) => {
      logger.error('Database error:', e);
    });

    this.prisma.$on('info', (e) => {
      logger.info('Database info:', e.message);
    });

    this.prisma.$on('warn', (e) => {
      logger.warn('Database warning:', e.message);
    });
  }

  async disconnect() {
    if (this.prisma) {
      await this.prisma.$disconnect();
      this.prisma = null;
      logger.info('Database disconnected');
    }
  }

  getClient() {
    if (!this.prisma) {
      throw new Error('Database not connected. Call connect() first.');
    }
    return this.prisma;
  }
}

// Create singleton instance
const databaseClient = new DatabaseClient();

module.exports = databaseClient;
```

### src/database/connection.js
```javascript
const databaseClient = require('./client');
const logger = require('../utils/logger');

class DatabaseConnection {
  static async initialize() {
    try {
      await databaseClient.connect();
      logger.info('Database initialized successfully');
      return true;
    } catch (error) {
      logger.error('Database initialization failed:', error);
      throw error;
    }
  }

  static async testConnection() {
    try {
      const client = databaseClient.getClient();
      await client.$queryRaw`SELECT 1 as connection_test`;
      return true;
    } catch (error) {
      logger.error('Database connection test failed:', error);
      return false;
    }
  }

  static async getConnectionInfo() {
    try {
      const client = databaseClient.getClient();
      const result = await client.$queryRaw`
        SELECT 
          current_database() as database_name,
          current_user as user_name,
          version() as version
      `;
      return result[0];
    } catch (error) {
      logger.error('Failed to get connection info:', error);
      return null;
    }
  }

  static async healthCheck() {
    try {
      const isConnected = await this.testConnection();
      const connectionInfo = await this.getConnectionInfo();
      
      return {
        status: isConnected ? 'healthy' : 'unhealthy',
        connected: isConnected,
        info: connectionInfo,
        timestamp: new Date().toISOString()
      };
    } catch (error) {
      return {
        status: 'unhealthy',
        connected: false,
        error: error.message,
        timestamp: new Date().toISOString()
      };
    }
  }

  static getClient() {
    return databaseClient.getClient();
  }

  static async shutdown() {
    await databaseClient.disconnect();
  }
}

module.exports = DatabaseConnection;
```

---

## 🏗️ Model Implementation

### src/models/base/BaseModel.js
```javascript
const { v4: uuidv4 } = require('uuid');
const logger = require('../../utils/logger');

class BaseModel {
  constructor(data = {}) {
    this.id = data.id || uuidv4();
    this.createdAt = data.createdAt || new Date();
    this.updatedAt = data.updatedAt || new Date();
  }

  // Convert model to plain object
  toJSON() {
    const obj = { ...this };
    
    // Remove undefined values
    Object.keys(obj).forEach(key => {
      if (obj[key] === undefined) {
        delete obj[key];
      }
    });
    
    return obj;
  }

  // Convert model to database format
  toDatabase() {
    const obj = this.toJSON();
    
    // Convert dates to ISO strings
    if (obj.createdAt instanceof Date) {
      obj.createdAt = obj.createdAt.toISOString();
    }
    if (obj.updatedAt instanceof Date) {
      obj.updatedAt = obj.updatedAt.toISOString();
    }
    
    return obj;
  }

  // Update model properties
  update(data) {
    Object.keys(data).forEach(key => {
      if (key !== 'id' && key !== 'createdAt') {
        this[key] = data[key];
      }
    });
    
    this.updatedAt = new Date();
    return this;
  }

  // Validate model data (override in child classes)
  validate() {
    return { isValid: true, errors: [] };
  }

  // Log model operations
  static logOperation(operation, modelName, data) {
    logger.info(`${modelName} ${operation}`, {
      model: modelName,
      operation,
      data: typeof data === 'object' ? JSON.stringify(data) : data
    });
  }
}

module.exports = BaseModel;
```

### src/models/User.js
```javascript
const BaseModel = require('./base/BaseModel');
const bcrypt = require('bcrypt');
const Joi = require('joi');

class User extends BaseModel {
  constructor(data = {}) {
    super(data);
    
    // User-specific properties
    this.userId = data.userId || this.id;
    this.email = data.email;
    this.phoneNumber = data.phoneNumber;
    this.password = data.password;
    this.firstName = data.firstName;
    this.lastName = data.lastName;
    this.dateOfBirth = data.dateOfBirth;
    this.ghanaCardNumber = data.ghanaCardNumber;
    this.ghanaCardVerified = data.ghanaCardVerified || false;
    this.userType = data.userType || 'CUSTOMER';
    this.isActive = data.isActive !== undefined ? data.isActive : true;
    this.isEmailVerified = data.isEmailVerified || false;
    this.isPhoneVerified = data.isPhoneVerified || false;
    this.lastLoginAt = data.lastLoginAt;
    
    // Relations
    this.addresses = data.addresses || [];
    this.orders = data.orders || [];
    this.creditAccount = data.creditAccount || null;
  }

  // Validation schema
  static getValidationSchema() {
    return {
      create: Joi.object({
        email: Joi.string().email().required(),
        phoneNumber: Joi.string().pattern(/^\+233[0-9]{9}$/).required(),
        password: Joi.string().min(8).pattern(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/).required(),
        firstName: Joi.string().min(2).max(50).required(),
        lastName: Joi.string().min(2).max(50).required(),
        dateOfBirth: Joi.date().max('now').required(),
        ghanaCardNumber: Joi.string().pattern(/^GHA-\d{9}-\d$/).optional(),
        userType: Joi.string().valid('CUSTOMER', 'CONTRACTOR', 'ADMIN', 'DRIVER', 'CONSULTANT').default('CUSTOMER')
      }),
      
      update: Joi.object({
        firstName: Joi.string().min(2).max(50).optional(),
        lastName: Joi.string().min(2).max(50).optional(),
        phoneNumber: Joi.string().pattern(/^\+233[0-9]{9}$/).optional(),
        dateOfBirth: Joi.date().max('now').optional(),
        ghanaCardNumber: Joi.string().pattern(/^GHA-\d{9}-\d$/).optional()
      })
    };
  }

  // Validate user data
  validate(operation = 'create') {
    const schema = User.getValidationSchema()[operation];
    if (!schema) {
      return { isValid: false, errors: ['Invalid operation'] };
    }

    const { error } = schema.validate(this.toJSON());
    
    if (error) {
      return {
        isValid: false,
        errors: error.details.map(detail => ({
          field: detail.path.join('.'),
          message: detail.message
        }))
      };
    }

    return { isValid: true, errors: [] };
  }

  // Hash password
  async hashPassword() {
    if (this.password) {
      const saltRounds = 12;
      this.password = await bcrypt.hash(this.password, saltRounds);
    }
    return this;
  }

  // Verify password
  async verifyPassword(plainPassword) {
    if (!this.password) {
      return false;
    }
    return await bcrypt.compare(plainPassword, this.password);
  }

  // Get full name
  getFullName() {
    return `${this.firstName} ${this.lastName}`.trim();
  }

  // Check if user can access resource
  canAccess(resource, action) {
    const permissions = {
      ADMIN: ['*'],
      CUSTOMER: ['profile:read', 'profile:update', 'order:create', 'order:read'],
      CONTRACTOR: ['profile:read', 'profile:update', 'order:create', 'order:read', 'credit:apply'],
      DRIVER: ['delivery:update', 'order:read'],
      CONSULTANT: ['booking:read', 'booking:update']
    };

    const userPermissions = permissions[this.userType] || [];
    return userPermissions.includes('*') || userPermissions.includes(`${resource}:${action}`);
  }

  // Convert to safe JSON (without password)
  toSafeJSON() {
    const obj = this.toJSON();
    delete obj.password;
    return obj;
  }

  // Update last login
  updateLastLogin() {
    this.lastLoginAt = new Date();
    return this;
  }

  // Check if account is locked
  isAccountLocked() {
    return !this.isActive;
  }

  // Static factory methods
  static fromDatabase(dbUser) {
    return new User({
      userId: dbUser.userId,
      email: dbUser.email,
      phoneNumber: dbUser.phoneNumber,
      password: dbUser.password,
      firstName: dbUser.firstName,
      lastName: dbUser.lastName,
      dateOfBirth: dbUser.dateOfBirth,
      ghanaCardNumber: dbUser.ghanaCardNumber,
      ghanaCardVerified: dbUser.ghanaCardVerified,
      userType: dbUser.userType,
      isActive: dbUser.isActive,
      isEmailVerified: dbUser.isEmailVerified,
      isPhoneVerified: dbUser.isPhoneVerified,
      lastLoginAt: dbUser.lastLoginAt,
      createdAt: dbUser.createdAt,
      updatedAt: dbUser.updatedAt,
      addresses: dbUser.addresses || [],
      orders: dbUser.orders || [],
      creditAccount: dbUser.creditAccount
    });
  }
}

module.exports = User;
```

### src/models/Product.js
```javascript
const BaseModel = require('./base/BaseModel');
const Joi = require('joi');

class Product extends BaseModel {
  constructor(data = {}) {
    super(data);
    
    // Product-specific properties
    this.productId = data.productId || this.id;
    this.productName = data.productName;
    this.description = data.description;
    this.brand = data.brand;
    this.model = data.model;
    this.sku = data.sku;
    this.unitPrice = data.unitPrice;
    this.costPrice = data.costPrice;
    this.currency = data.currency || 'GHS';
    this.weight = data.weight;
    this.dimensions = data.dimensions;
    this.color = data.color;
    this.material = data.material;
    this.isBulkItem = data.isBulkItem || false;
    this.bulkMinQty = data.bulkMinQty;
    this.bulkDiscount = data.bulkDiscount;
    this.isActive = data.isActive !== undefined ? data.isActive : true;
    this.isPublished = data.isPublished || false;
    this.categoryId = data.categoryId;
    
    // Relations
    this.category = data.category || null;
    this.inventory = data.inventory || null;
    this.images = data.images || [];
  }

  // Validation schema
  static getValidationSchema() {
    return {
      create: Joi.object({
        productName: Joi.string().min(2).max(255).required(),
        description: Joi.string().max(1000).optional(),
        brand: Joi.string().max(100).optional(),
        model: Joi.string().max(100).optional(),
        sku: Joi.string().max(100).optional(),
        unitPrice: Joi.number().positive().precision(2).required(),
        costPrice: Joi.number().positive().precision(2).optional(),
        currency: Joi.string().length(3).default('GHS'),
        weight: Joi.number().positive().optional(),
        dimensions: Joi.string().max(100).optional(),
        color: Joi.string().max(50).optional(),
        material: Joi.string().max(100).optional(),
        isBulkItem: Joi.boolean().optional(),
        bulkMinQty: Joi.number().integer().min(1).optional(),
        bulkDiscount: Joi.number().min(0).max(100).precision(2).optional(),
        isActive: Joi.boolean().optional(),
        isPublished: Joi.boolean().optional(),
        categoryId: Joi.string().uuid().optional()
      })
    };
  }

  // Validate product data
  validate(operation = 'create') {
    const schema = Product.getValidationSchema()[operation];
    if (!schema) {
      return { isValid: false, errors: ['Invalid operation'] };
    }

    const { error } = schema.validate(this.toJSON());
    
    if (error) {
      return {
        isValid: false,
        errors: error.details.map(detail => ({
          field: detail.path.join('.'),
          message: detail.message
        }))
      };
    }

    return { isValid: true, errors: [] };
  }

  // Calculate discounted price for bulk orders
  calculateBulkPrice(quantity) {
    if (!this.isBulkItem || !this.bulkMinQty || quantity < this.bulkMinQty) {
      return this.unitPrice;
    }

    const discount = this.bulkDiscount || 0;
    const discountAmount = (this.unitPrice * discount) / 100;
    return this.unitPrice - discountAmount;
  }

  // Get total price for quantity
  getTotalPrice(quantity) {
    const unitPrice = this.calculateBulkPrice(quantity);
    return unitPrice * quantity;
  }

  // Check if product is available
  isAvailable() {
    return this.isActive && this.isPublished;
  }

  // Check if product has sufficient stock
  hasStock(requestedQuantity = 1) {
    if (!this.inventory) {
      return false;
    }
    return this.inventory.availableStock >= requestedQuantity;
  }

  // Get available stock
  getAvailableStock() {
    return this.inventory ? this.inventory.availableStock : 0;
  }

  // Get primary image
  getPrimaryImage() {
    return this.images.find(image => image.isPrimary) || this.images[0] || null;
  }

  // Generate SKU if not provided
  generateSKU() {
    if (!this.sku) {
      const brandPrefix = this.brand ? this.brand.substring(0, 3).toUpperCase() : 'PRD';
      const namePrefix = this.productName.substring(0, 3).toUpperCase();
      const timestamp = Date.now().toString().slice(-6);
      this.sku = `${brandPrefix}-${namePrefix}-${timestamp}`;
    }
    return this.sku;
  }

  // Static factory methods
  static fromDatabase(dbProduct) {
    return new Product({
      productId: dbProduct.productId,
      productName: dbProduct.productName,
      description: dbProduct.description,
      brand: dbProduct.brand,
      model: dbProduct.model,
      sku: dbProduct.sku,
      unitPrice: parseFloat(dbProduct.unitPrice),
      costPrice: dbProduct.costPrice ? parseFloat(dbProduct.costPrice) : null,
      currency: dbProduct.currency,
      weight: dbProduct.weight ? parseFloat(dbProduct.weight) : null,
      dimensions: dbProduct.dimensions,
      color: dbProduct.color,
      material: dbProduct.material,
      isBulkItem: dbProduct.isBulkItem,
      bulkMinQty: dbProduct.bulkMinQty,
      bulkDiscount: dbProduct.bulkDiscount ? parseFloat(dbProduct.bulkDiscount) : null,
      isActive: dbProduct.isActive,
      isPublished: dbProduct.isPublished,
      categoryId: dbProduct.categoryId,
      createdAt: dbProduct.createdAt,
      updatedAt: dbProduct.updatedAt,
      category: dbProduct.category,
      inventory: dbProduct.inventory,
      images: dbProduct.images || []
    });
  }
}

module.exports = Product;
```

### src/models/Category.js
```javascript
const BaseModel = require('./base/BaseModel');
const Joi = require('joi');

class Category extends BaseModel {
  constructor(data = {}) {
    super(data);
    
    // Category-specific properties
    this.categoryId = data.categoryId || this.id;
    this.categoryName = data.categoryName;
    this.description = data.description;
    this.imageUrl = data.imageUrl;
    this.parentId = data.parentId;
    this.sortOrder = data.sortOrder || 0;
    this.isActive = data.isActive !== undefined ? data.isActive : true;
    
    // Relations
    this.parent = data.parent || null;
    this.children = data.children || [];
    this.products = data.products || [];
  }

  // Validation schema
  static getValidationSchema() {
    return {
      create: Joi.object({
        categoryName: Joi.string().min(2).max(100).required(),
        description: Joi.string().max(500).optional(),
        imageUrl: Joi.string().uri().optional(),
        parentId: Joi.string().uuid().optional(),
        sortOrder: Joi.number().integer().min(0).default(0)
      }),
      
      update: Joi.object({
        categoryName: Joi.string().min(2).max(100).optional(),
        description: Joi.string().max(500).optional(),
        imageUrl: Joi.string().uri().optional(),
        parentId: Joi.string().uuid().optional(),
        sortOrder: Joi.number().integer().min(0).optional(),
        isActive: Joi.boolean().optional()
      })
    };
  }

  // Validate category data
  validate(operation = 'create') {
    const schema = Category.getValidationSchema()[operation];
    if (!schema) {
      return { isValid: false, errors: ['Invalid operation'] };
    }

    const { error } = schema.validate(this.toJSON());
    
    if (error) {
      return {
        isValid: false,
        errors: error.details.map(detail => ({
          field: detail.path.join('.'),
          message: detail.message
        }))
      };
    }

    return { isValid: true, errors: [] };
  }

  // Check if category is root level
  isRootCategory() {
    return !this.parentId;
  }

  // Check if category has children
  hasChildren() {
    return this.children && this.children.length > 0;
  }

  // Get category hierarchy path
  getHierarchyPath() {
    const path = [this.categoryName];
    let current = this.parent;
    
    while (current) {
      path.unshift(current.categoryName);
      current = current.parent;
    }
    
    return path.join(' > ');
  }

  // Get product count
  getProductCount() {
    return this.products ? this.products.length : 0;
  }

  // Static factory methods
  static fromDatabase(dbCategory) {
    return new Category({
      categoryId: dbCategory.categoryId,
      categoryName: dbCategory.categoryName,
      description: dbCategory.description,
      imageUrl: dbCategory.imageUrl,
      parentId: dbCategory.parentId,
      sortOrder: dbCategory.sortOrder,
      isActive: dbCategory.isActive,
      createdAt: dbCategory.createdAt,
      updatedAt: dbCategory.updatedAt,
      parent: dbCategory.parent,
      children: dbCategory.children || [],
      products: dbCategory.products || []
    });
  }
}

module.exports = Category;
```

---

## 🗃️ Repository Implementation

### src/repositories/base/BaseRepository.js
```javascript
const DatabaseConnection = require('../../database/connection');
const logger = require('../../utils/logger');

class BaseRepository {
  constructor(modelName) {
    this.modelName = modelName;
    this.client = null;
  }

  // Get Prisma client
  getClient() {
    if (!this.client) {
      this.client = DatabaseConnection.getClient();
    }
    return this.client;
  }

  // Get model from Prisma client
  getModel() {
    const client = this.getClient();
    const modelName = this.modelName.toLowerCase();
    
    if (!client[modelName]) {
      throw new Error(`Model ${modelName} not found in Prisma client`);
    }
    
    return client[modelName];
  }

  // Generic create method
  async create(data) {
    try {
      const model = this.getModel();
      const result = await model.create({ data });
      
      logger.info(`${this.modelName} created`, { id: result.id || result[this.getIdField()] });
      return result;
    } catch (error) {
      logger.error(`Failed to create ${this.modelName}:`, error);
      throw error;
    }
  }

  // Generic find by ID method
  async findById(id, include = null) {
    try {
      const model = this.getModel();
      const options = { where: { [this.getIdField()]: id } };
      
      if (include) {
        options.include = include;
      }
      
      const result = await model.findUnique(options);
      return result;
    } catch (error) {
      logger.error(`Failed to find ${this.modelName} by ID:`, error);
      throw error;
    }
  }

  // Generic find many method
  async findMany(where = {}, options = {}) {
    try {
      const model = this.getModel();
      const queryOptions = { where, ...options };
      
      const result = await model.findMany(queryOptions);
      return result;
    } catch (error) {
      logger.error(`Failed to find ${this.modelName} records:`, error);
      throw error;
    }
  }

  // Generic update method
  async update(id, data) {
    try {
      const model = this.getModel();
      const result = await model.update({
        where: { [this.getIdField()]: id },
        data
      });
      
      logger.info(`${this.modelName} updated`, { id });
      return result;
    } catch (error) {
      logger.error(`Failed to update ${this.modelName}:`, error);
      throw error;
    }
  }

  // Generic delete method
  async delete(id) {
    try {
      const model = this.getModel();
      const result = await model.delete({
        where: { [this.getIdField()]: id }
      });
      
      logger.info(`${this.modelName} deleted`, { id });
      return result;
    } catch (error) {
      logger.error(`Failed to delete ${this.modelName}:`, error);
      throw error;
    }
  }

  // Generic soft delete method
  async softDelete(id) {
    try {
      return await this.update(id, { isActive: false });
    } catch (error) {
      logger.error(`Failed to soft delete ${this.modelName}:`, error);
      throw error;
    }
  }

  // Count records
  async count(where = {}) {
    try {
      const model = this.getModel();
      const count = await model.count({ where });
      return count;
    } catch (error) {
      logger.error(`Failed to count ${this.modelName} records:`, error);
      throw error;
    }
  }

  // Check if record exists
  async exists(where) {
    try {
      const count = await this.count(where);
      return count > 0;
    } catch (error) {
      logger.error(`Failed to check ${this.modelName} existence:`, error);
      throw error;
    }
  }

  // Paginated find
  async findPaginated(where = {}, page = 1, limit = 20, options = {}) {
    try {
      const skip = (page - 1) * limit;
      const model = this.getModel();
      
      const [data, total] = await Promise.all([
        model.findMany({
          where,
          skip,
          take: limit,
          ...options
        }),
        model.count({ where })
      ]);

      return {
        data,
        pagination: {
          page,
          limit,
          total,
          totalPages: Math.ceil(total / limit),
          hasNext: page < Math.ceil(total / limit),
          hasPrev: page > 1
        }
      };
    } catch (error) {
      logger.error(`Failed to find paginated ${this.modelName} records:`, error);
      throw error;
    }
  }

  // Get primary key field name (override in child classes if different)
  getIdField() {
    return `${this.modelName.toLowerCase()}Id`;
  }

  // Transaction wrapper
  async transaction(callback) {
    const client = this.getClient();
    return await client.$transaction(callback);
  }
}

module.exports = BaseRepository;
```

### src/repositories/UserRepository.js
```javascript
const BaseRepository = require('./base/BaseRepository');
const User = require('../models/User');

class UserRepository extends BaseRepository {
  constructor() {
    super('User');
  }

  // Find user by email
  async findByEmail(email, includePassword = false) {
    try {
      const model = this.getModel();
      const user = await model.findUnique({
        where: { email },
        include: {
          addresses: true,
          creditAccount: true
        }
      });

      if (user && !includePassword) {
        delete user.password;
      }

      return user ? User.fromDatabase(user) : null;
    } catch (error) {
      logger.error('Failed to find user by email:', error);
      throw error;
    }
  }

  // Find user by phone number
  async findByPhoneNumber(phoneNumber) {
    try {
      const model = this.getModel();
      const user = await model.findUnique({
        where: { phoneNumber },
        include: {
          addresses: true,
          creditAccount: true
        }
      });

      return user ? User.fromDatabase(user) : null;
    } catch (error) {
      logger.error('Failed to find user by phone:', error);
      throw error;
    }
  }

  // Create user with hashed password
  async createUser(userData) {
    try {
      const user = new User(userData);
      
      // Validate user data
      const validation = user.validate('create');
      if (!validation.isValid) {
        throw new Error(`Validation failed: ${validation.errors.map(e => e.message).join(', ')}`);
      }

      // Hash password
      await user.hashPassword();

      // Generate SKU if needed
      if (!user.sku) {
        user.generateSKU();
      }

      const createdUser = await this.create(user.toDatabase());
      return User.fromDatabase(createdUser);
    } catch (error) {
      logger.error('Failed to create user:', error);
      throw error;
    }
  }

  // Update user profile
  async updateProfile(userId, profileData) {
    try {
      const user = new User(profileData);
      
      // Validate update data
      const validation = user.validate('update');
      if (!validation.isValid) {
        throw new Error(`Validation failed: ${validation.errors.map(e => e.message).join(', ')}`);
      }

      const updatedUser = await this.update(userId, profileData);
      return User.fromDatabase(updatedUser);
    } catch (error) {
      logger.error('Failed to update user profile:', error);
      throw error;
    }
  }

  // Update last login
  async updateLastLogin(userId) {
    try {
      return await this.update(userId, { lastLoginAt: new Date() });
    } catch (error) {
      logger.error('Failed to update last login:', error);
      throw error;
    }
  }

  // Verify Ghana Card
  async verifyGhanaCard(userId, ghanaCardData) {
    try {
      return await this.update(userId, {
        ghanaCardNumber: ghanaCardData.cardNumber,
        ghanaCardVerified: true
      });
    } catch (error) {
      logger.error('Failed to verify Ghana Card:', error);
      throw error;
    }
  }

  // Get users by type
  async findByUserType(userType, options = {}) {
    try {
      return await this.findMany({ userType }, options);
    } catch (error) {
      logger.error('Failed to find users by type:', error);
      throw error;
    }
  }

  // Get active users
  async findActiveUsers(options = {}) {
    try {
      return await this.findMany({ isActive: true }, options);
    } catch (error) {
      logger.error('Failed to find active users:', error);
      throw error;
    }
  }

  // Check if email exists
  async emailExists(email, excludeUserId = null) {
    try {
      const where = { email };
      if (excludeUserId) {
        where.userId = { not: excludeUserId };
      }
      return await this.exists(where);
    } catch (error) {
      logger.error('Failed to check email existence:', error);
      throw error;
    }
  }

  // Check if phone exists
  async phoneExists(phoneNumber, excludeUserId = null) {
    try {
      const where = { phoneNumber };
      if (excludeUserId) {
        where.userId = { not: excludeUserId };
      }
      return await this.exists(where);
    } catch (error) {
      logger.error('Failed to check phone existence:', error);
      throw error;
    }
  }

  // Get user statistics
  async getUserStats() {
    try {
      const client = this.getClient();
      
      const stats = await client.user.groupBy({
        by: ['userType'],
        _count: {
          userId: true
        }
      });

      const totalUsers = await this.count();
      const activeUsers = await this.count({ isActive: true });
      const verifiedUsers = await this.count({ isEmailVerified: true });

      return {
        total: totalUsers,
        active: activeUsers,
        verified: verifiedUsers,
        byType: stats.reduce((acc, stat) => {
          acc[stat.userType] = stat._count.userId;
          return acc;
        }, {})
      };
    } catch (error) {
      logger.error('Failed to get user stats:', error);
      throw error;
    }
  }
}

module.exports = UserRepository;
```

### src/repositories/ProductRepository.js
```javascript
const BaseRepository = require('./base/BaseRepository');
const Product = require('../models/Product');

class ProductRepository extends BaseRepository {
  constructor() {
    super('Product');
  }

  // Find product with full details
  async findByIdWithDetails(productId) {
    try {
      const model = this.getModel();
      const product = await model.findUnique({
        where: { productId },
        include: {
          category: true,
          inventory: true,
          images: {
            orderBy: { sortOrder: 'asc' }
          }
        }
      });

      return product ? Product.fromDatabase(product) : null;
    } catch (error) {
      logger.error('Failed to find product with details:', error);
      throw error;
    }
  }

  // Find products by category
  async findByCategory(categoryId, options = {}) {
    try {
      const where = { 
        categoryId,
        isActive: true,
        isPublished: true
      };

      return await this.findMany(where, {
        include: {
          category: true,
          inventory: true,
          images: {
            where: { isPrimary: true }
          }
        },
        orderBy: { createdAt: 'desc' },
        ...options
      });
    } catch (error) {
      logger.error('Failed to find products by category:', error);
      throw error;
    }
  }

  // Search products
  async searchProducts(searchParams, page = 1, limit = 20) {
    try {
      const { search, categoryId, minPrice, maxPrice, brand, inStock } = searchParams;
      
      const where = {
        isActive: true,
        isPublished: true
      };

      // Text search
      if (search) {
        where.OR = [
          { productName: { contains: search, mode: 'insensitive' } },
          { description: { contains: search, mode: 'insensitive' } },
          { brand: { contains: search, mode: 'insensitive' } }
        ];
      }

      // Category filter
      if (categoryId) {
        where.categoryId = categoryId;
      }

      // Price range filter
      if (minPrice !== undefined || maxPrice !== undefined) {
        where.unitPrice = {};
        if (minPrice !== undefined) where.unitPrice.gte = minPrice;
        if (maxPrice !== undefined) where.unitPrice.lte = maxPrice;
      }

      // Brand filter
      if (brand) {
        where.brand = { contains: brand, mode: 'insensitive' };
      }

      // Stock filter
      if (inStock) {
        where.inventory = {
          availableStock: { gt: 0 }
        };
      }

      return await this.findPaginated(where, page, limit, {
        include: {
          category: true,
          inventory: true,
          images: {
            where: { isPrimary: true }
          }
        },
        orderBy: { createdAt: 'desc' }
      });
    } catch (error) {
      logger.error('Failed to search products:', error);
      throw error;
    }
  }

  // Create product with inventory
  async createProductWithInventory(productData, inventoryData = {}) {
    try {
      const product = new Product(productData);
      
      // Validate product data
      const validation = product.validate('create');
      if (!validation.isValid) {
        throw new Error(`Validation failed: ${validation.errors.map(e => e.message).join(', ')}`);
      }

      // Generate SKU if not provided
      product.generateSKU();

      return await this.transaction(async (prisma) => {
        // Create product
        const createdProduct = await prisma.product.create({
          data: product.toDatabase()
        });

        // Create inventory record
        await prisma.inventory.create({
          data: {
            productId: createdProduct.productId,
            availableStock: inventoryData.availableStock || 0,
            reservedStock: 0,
            reorderLevel: inventoryData.reorderLevel || 10,
            maxStockLevel: inventoryData.maxStockLevel,
            warehouseLocation: inventoryData.warehouseLocation,
            shelfLocation: inventoryData.shelfLocation
          }
        });

        // Return product with inventory
        return await this.findByIdWithDetails(createdProduct.productId);
      });
    } catch (error) {
      logger.error('Failed to create product with inventory:', error);
      throw error;
    }
  }

  // Update stock level
  async updateStock(productId, quantity, operation = 'set') {
    try {
      const client = this.getClient();
      
      if (operation === 'set') {
        await client.inventory.update({
          where: { productId },
          data: { 
            availableStock: quantity,
            lastStockUpdate: new Date()
          }
        });
      } else if (operation === 'add') {
        await client.inventory.update({
          where: { productId },
          data: { 
            availableStock: { increment: quantity },
            lastStockUpdate: new Date()
          }
        });
      } else if (operation === 'subtract') {
        await client.inventory.update({
          where: { productId },
          data: { 
            availableStock: { decrement: quantity },
            lastStockUpdate: new Date()
          }
        });
      }

      return await this.findByIdWithDetails(productId);
    } catch (error) {
      logger.error('Failed to update stock:', error);
      throw error;
    }
  }

  // Get low stock products
  async getLowStockProducts() {
    try {
      const client = this.getClient();
      
      const products = await client.product.findMany({
        where: {
          isActive: true,
          inventory: {
            availableStock: {
              lte: client.inventory.fields.reorderLevel
            }
          }
        },
        include: {
          inventory: true,
          category: true
        },
        orderBy: {
          inventory: {
            availableStock: 'asc'
          }
        }
      });

      return products.map(product => Product.fromDatabase(product));
    } catch (error) {
      logger.error('Failed to get low stock products:', error);
      throw error;
    }
  }

  // Get product statistics
  async getProductStats() {
    try {
      const client = this.getClient();
      
      const totalProducts = await this.count();
      const activeProducts = await this.count({ isActive: true });
      const publishedProducts = await this.count({ isPublished: true });
      const outOfStockProducts = await client.product.count({
        where: {
          inventory: {
            availableStock: 0
          }
        }
      });

      const categoryStats = await client.product.groupBy({
        by: ['categoryId'],
        _count: {
          productId: true
        },
        where: {
          isActive: true
        }
      });

      return {
        total: totalProducts,
        active: activeProducts,
        published: publishedProducts,
        outOfStock: outOfStockProducts,
        byCategory: categoryStats
      };
    } catch (error) {
      logger.error('Failed to get product stats:', error);
      throw error;
    }
  }

  // Find products by SKU
  async findBySKU(sku) {
    try {
      const model = this.getModel();
      const product = await model.findUnique({
        where: { sku },
        include: {
          category: true,
          inventory: true,
          images: true
        }
      });

      return product ? Product.fromDatabase(product) : null;
    } catch (error) {
      logger.error('Failed to find product by SKU:', error);
      throw error;
    }
  }

  // Get featured products
  async getFeaturedProducts(limit = 10) {
    try {
      const products = await this.findMany(
        { 
          isActive: true, 
          isPublished: true,
          inventory: {
            availableStock: { gt: 0 }
          }
        },
        {
          take: limit,
          include: {
            category: true,
            inventory: true,
            images: {
              where: { isPrimary: true }
            }
          },
          orderBy: { createdAt: 'desc' }
        }
      );

      return products.map(product => Product.fromDatabase(product));
    } catch (error) {
      logger.error('Failed to get featured products:', error);
      throw error;
    }
  }
}

module.exports = ProductRepository;
```

---

## 🌱 Database Seeding

### prisma/seeds/categories.js
```javascript
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

const categories = [
  {
    categoryId: '550e8400-e29b-41d4-a716-446655440001',
    categoryName: 'Cement & Concrete',
    description: 'All types of cement, concrete blocks, and related materials',
    sortOrder: 1
  },
  {
    categoryId: '550e8400-e29b-41d4-a716-446655440002',
    categoryName: 'Steel & Iron',
    description: 'Steel bars, iron rods, and metal construction materials',
    sortOrder: 2
  },
  {
    categoryId: '550e8400-e29b-41d4-a716-446655440003',
    categoryName: 'Roofing Materials',
    description: 'Roofing sheets, tiles, and accessories',
    sortOrder: 3
  },
  {
    categoryId: '550e8400-e29b-41d4-a716-446655440004',
    categoryName: 'Plumbing & Electrical',
    description: 'Pipes, fittings, cables, and electrical components',
    sortOrder: 4
  },
  {
    categoryId: '550e8400-e29b-41d4-a716-446655440005',
    categoryName: 'Paints & Finishes',
    description: 'Paints, varnishes, and finishing materials',
    sortOrder: 5
  }
];

const subcategories = [
  {
    categoryId: '550e8400-e29b-41d4-a716-446655440011',
    categoryName: 'Portland Cement',
    parentId: '550e8400-e29b-41d4-a716-446655440001',
    sortOrder: 1
  },
  {
    categoryId: '550e8400-e29b-41d4-a716-446655440012',
    categoryName: 'Concrete Blocks',
    parentId: '550e8400-e29b-41d4-a716-446655440001',
    sortOrder: 2
  },
  {
    categoryId: '550e8400-e29b-41d4-a716-446655440021',
    categoryName: 'Reinforcement Bars',
    parentId: '550e8400-e29b-41d4-a716-446655440002',
    sortOrder: 1
  }
];

async function seedCategories() {
  console.log('Seeding categories...');
  
  // Seed main categories
  for (const category of categories) {
    await prisma.productCategory.upsert({
      where: { categoryId: category.categoryId },
      update: category,
      create: category
    });
  }
  
  // Seed subcategories
  for (const subcategory of subcategories) {
    await prisma.productCategory.upsert({
      where: { categoryId: subcategory.categoryId },
      update: subcategory,
      create: subcategory
    });
  }
  
  console.log('Categories seeded successfully');
}

module.exports = { seedCategories };
```

### prisma/seeds/products.js
```javascript
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

const products = [
  {
    productId: '660e8400-e29b-41d4-a716-446655440001',
    productName: 'Diamond Portland Cement',
    description: 'High-quality Portland cement suitable for all construction needs',
    brand: 'Diamond Cement',
    sku: 'DIA-CEM-001',
    unitPrice: 28.50,
    costPrice: 25.00,
    weight: 50.0,
    isBulkItem: true,
    bulkMinQty: 100,
    bulkDiscount: 5.0,
    categoryId: '550e8400-e29b-41d4-a716-446655440011',
    isActive: true,
    isPublished: true
  },
  {
    productId: '660e8400-e29b-41d4-a716-446655440002',
    productName: 'Ghacem Portland Cement',
    description: 'Premium quality cement from Ghana Cement Works',
    brand: 'Ghacem',
    sku: 'GHA-CEM-001',
    unitPrice: 29.00,
    costPrice: 26.00,
    weight: 50.0,
    isBulkItem: true,
    bulkMinQty: 100,
    bulkDiscount: 4.5,
    categoryId: '550e8400-e29b-41d4-a716-446655440011',
    isActive: true,
    isPublished: true
  },
  {
    productId: '660e8400-e29b-41d4-a716-446655440003',
    productName: 'Steel Reinforcement Bar 12mm',
    description: 'High tensile steel reinforcement bar 12mm diameter',
    brand: 'ArcelorMittal',
    sku: 'ARC-STL-12MM',
    unitPrice: 45.00,
    costPrice: 40.00,
    weight: 8.88,
    dimensions: '12mm x 12m',
    isBulkItem: true,
    bulkMinQty: 50,
    bulkDiscount: 8.0,
    categoryId: '550e8400-e29b-41d4-a716-446655440021',
    isActive: true,
    isPublished: true
  },
  {
    productId: '660e8400-e29b-41d4-a716-446655440004',
    productName: 'Concrete Block 6 inch',
    description: 'Standard concrete masonry block 6 inch',
    brand: 'BlockMaster',
    sku: 'BLK-CON-6IN',
    unitPrice: 2.50,
    costPrice: 2.00,
    weight: 18.0,
    dimensions: '6in x 8in x 16in',
    isBulkItem: true,
    bulkMinQty: 200,
    bulkDiscount: 10.0,
    categoryId: '550e8400-e29b-41d4-a716-446655440012',
    isActive: true,
    isPublished: true
  },
  {
    productId: '660e8400-e29b-41d4-a716-446655440005',
    productName: 'Roofing Sheet Aluminum',
    description: 'Corrugated aluminum roofing sheet',
    brand: 'RoofTech',
    sku: 'ROF-ALU-001',
    unitPrice: 85.00,
    costPrice: 75.00,
    weight: 5.2,
    dimensions: '3m x 0.76m',
    material: 'Aluminum',
    color: 'Silver',
    categoryId: '550e8400-e29b-41d4-a716-446655440003',
    isActive: true,
    isPublished: true
  }
];

const inventoryData = [
  { productId: '660e8400-e29b-41d4-a716-446655440001', availableStock: 500, reorderLevel: 50 },
  { productId: '660e8400-e29b-41d4-a716-446655440002', availableStock: 300, reorderLevel: 50 },
  { productId: '660e8400-e29b-41d4-a716-446655440003', availableStock: 200, reorderLevel: 25 },
  { productId: '660e8400-e29b-41d4-a716-446655440004', availableStock: 1000, reorderLevel: 100 },
  { productId: '660e8400-e29b-41d4-a716-446655440005', availableStock: 150, reorderLevel: 20 }
];

async function seedProducts() {
  console.log('Seeding products...');
  
  // Seed products
  for (const product of products) {
    await prisma.product.upsert({
      where: { productId: product.productId },
      update: product,
      create: product
    });
  }
  
  // Seed inventory
  for (const inventory of inventoryData) {
    await prisma.inventory.upsert({
      where: { productId: inventory.productId },
      update: {
        availableStock: inventory.availableStock,
        reorderLevel: inventory.reorderLevel,
        lastStockUpdate: new Date()
      },
      create: {
        inventoryId: require('uuid').v4(),
        ...inventory,
        reservedStock: 0,
        lastStockUpdate: new Date()
      }
    });
  }
  
  console.log('Products seeded successfully');
}

module.exports = { seedProducts };(),
        material: Joi.string().max(100).optional(),
        isBulkItem: Joi.boolean().default(false),
        bulkMinQty: Joi.number().integer().min(1).optional(),
        bulkDiscount: Joi.number().min(0).max(100).precision(2).optional(),
        categoryId: Joi.string().uuid().required()
      }),
      
      update: Joi.object({
        productName: Joi.string().min(2).max(255).optional(),
        description: Joi.string().max(1000).optional(),
        brand: Joi.string().max(100).optional(),
        model: Joi.string().max(100).optional(),
        unitPrice: Joi.number().positive().precision(2).optional(),
        costPrice: Joi.number().positive().precision(2).optional(),
        weight: Joi.number().positive().optional(),
        dimensions: Joi.string().max(100).optional(),
        color: Joi.string().max(50).optional# Module 2: Database & Models
**eBuildify Backend - Database Foundation**
*Duration: 3-4 days*

---

## 🎯 Module Overview

**What This Module Does:**
- Sets up PostgreSQL database connection
- Implements Prisma ORM with core models
- Creates database migrations and seeders
- Establishes data access patterns
- Provides database utilities and helpers

**Dependencies:**
- Module 1 (Core API Foundation) must be completed

**Success Criteria:**
- Database connects successfully
- Can create, read, update, delete users and products
- Migrations run smoothly
- Seed data populates correctly
- Connection pooling works efficiently

---

## 📁 Project Structure Extensions

```
ebuildify-core/                    # From Module 1
├── prisma/
│   ├── schema.prisma              # Database schema definition
│   ├── migrations/                # Auto-generated migrations
│   │   └── 001_initial_setup/
│   ├── seeds/
│   │   ├── users.js              # User seed data
│   │   ├── categories.js         # Category seed data
│   │   ├── products.js           # Product seed data
│   │   └── index.js              # Main seeder
│   └── dev.db                    # SQLite for development (optional)
├── src/
│   ├── database/
│   │   ├── connection.js         # Database connection utility
│   │   ├── client.js             # Prisma client singleton
│   │   └── health.js             # Database health checks
│   ├── models/
│   │   ├── User.js               # User model with methods
│   │   ├── Product.js            # Product model with methods
│   │   ├── Category.js           # Category model with methods
│   │   └── base/
│   │       └── BaseModel.js      # Base model with common methods
│   ├── repositories/
│   │   ├── UserRepository.js     # User data access layer
│   │   ├── ProductRepository.js  # Product data access layer
│   │   ├── CategoryRepository.js # Category data access layer
│   │   └── base/
│   │       └── BaseRepository.js # Base repository pattern
│   └── utils/
│       ├── database.js           # Database utilities
│       └── validation.js         # Database validation helpers
├── tests/
│   ├── database/
│   │   ├── connection.test.js    # Connection tests
│   │   ├── models.test.js        # Model tests
│   │   └── repositories.test.js  # Repository tests
│   └── fixtures/
│       ├── users.json            # Test user data
│       └── products.json         # Test product data
└── scripts/
    ├── db-setup.js               # Database setup script
    ├── db-reset.js               # Database reset script
    └── db-migrate.js             # Migration runner
```