# eBuildify API Specification & Documentation v2.0

**BuildTech Solutions - RESTful API Design**  
**Client:** SOL LITTLE BY LITTLE ENTERPRISE  
**Project:** eBuildify Platform  
**Version:** 2.0  
**Base URL:** `https://api.ebuildify.com/v1`

---

## Table of Contents

1. [API Overview](#api-overview)
2. [Authentication & Authorization](#authentication--authorization)
3. [Common Response Formats](#common-response-formats)
4. [User Management APIs](#user-management-apis)
5. [Product Catalog APIs](#product-catalog-apis)
6. [Order Management APIs](#order-management-apis)
7. [Payment & Credit APIs](#payment--credit-apis)
8. [Service Booking APIs](#service-booking-apis)
9. [Delivery & Logistics APIs](#delivery--logistics-apis)
10. [Admin & Analytics APIs](#admin--analytics-apis)
11. [Notification APIs](#notification-apis)
12. [Error Handling](#error-handling)
13. [Rate Limiting](#rate-limiting)
14. [API Testing](#api-testing)

---

## API Overview

### Architecture Principles
- **RESTful Design**: Standard HTTP methods (GET, POST, PUT, DELETE)
- **JSON Format**: All requests and responses in JSON
- **Stateless**: Each request contains all necessary information
- **Versioning**: URL-based versioning (/v1/)
- **Microservices Ready**: Modular endpoints for service separation

### Base Response Structure
```json
{
  "success": true,
  "message": "Operation completed successfully",
  "data": {},
  "meta": {
    "timestamp": "2024-12-15T10:30:00Z",
    "version": "v1",
    "request_id": "req_abc123"
  }
}
```

### Pagination Structure
```json
{
  "success": true,
  "data": [],
  "pagination": {
    "current_page": 1,
    "per_page": 20,
    "total_items": 150,
    "total_pages": 8,
    "has_next": true,
    "has_prev": false
  }
}
```

---

## Authentication & Authorization

### JWT Token Authentication
All authenticated endpoints require a JWT token in the Authorization header:
```
Authorization: Bearer <jwt_token>
```

### Authentication Endpoints

#### POST /auth/register
**Description:** Register a new user with Ghana Card verification  
**Access:** Public

**Request Body:**
```json
{
  "email": "john.doe@example.com",
  "phone_number": "+233501234567",
  "password": "SecurePass123!",
  "first_name": "John",
  "last_name": "Doe",
  "user_type": "customer",
  "ghana_card_number": "GHA-123456789-0",
  "ghana_card_image": "base64_encoded_image",
  "date_of_birth": "1990-05-15",
  "address": {
    "address_line_1": "123 Main Street",
    "city": "Accra",
    "region": "Greater Accra"
  }
}
```

**Response (201):**
```json
{
  "success": true,
  "message": "Registration successful. Please verify your email and phone.",
  "data": {
    "user_id": "uuid-123",
    "email": "john.doe@example.com",
    "verification_required": true,
    "is_first_20_customer": true
  }
}
```

#### POST /auth/login  
**Description:** Authenticate user and receive JWT token  
**Access:** Public

**Request Body:**
```json
{
  "email": "john.doe@example.com",
  "password": "SecurePass123!"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "user": {
      "user_id": "uuid-123",
      "email": "john.doe@example.com",
      "first_name": "John",
      "last_name": "Doe",
      "user_type": "customer",
      "ghana_card_verified": true
    },
    "tokens": {
      "access_token": "jwt_access_token",
      "refresh_token": "jwt_refresh_token",
      "expires_in": 3600
    }
  }
}
```

#### POST /auth/refresh
**Description:** Refresh JWT access token  
**Access:** Authenticated (Refresh Token)

#### POST /auth/logout
**Description:** Logout and invalidate tokens  
**Access:** Authenticated

#### POST /auth/verify-ghana-card
**Description:** Verify Ghana Card details  
**Access:** Authenticated

---

## User Management APIs

### User Profile Endpoints

#### GET /users/profile
**Description:** Get current user's profile  
**Access:** Authenticated

**Response (200):**
```json
{
  "success": true,
  "data": {
    "user_id": "uuid-123",
    "email": "john.doe@example.com",
    "first_name": "John",
    "last_name": "Doe",
    "phone_number": "+233501234567",
    "user_type": "customer",
    "ghana_card_verified": true,
    "profile": {
      "customer_tier": "bronze",
      "is_first_20_customer": true,
      "credit_limit": 5000.00,
      "loyalty_points": 150
    },
    "addresses": [
      {
        "address_id": "uuid-addr1",
        "address_line_1": "123 Main Street",
        "city": "Accra",
        "region": "Greater Accra",
        "is_primary": true
      }
    ]
  }
}
```

#### PUT /users/profile
**Description:** Update user profile  
**Access:** Authenticated

#### POST /users/addresses
**Description:** Add new address  
**Access:** Authenticated

#### PUT /users/addresses/{address_id}
**Description:** Update specific address  
**Access:** Authenticated

#### DELETE /users/addresses/{address_id}
**Description:** Delete address  
**Access:** Authenticated

---

## Product Catalog APIs

### Product Endpoints

#### GET /products
**Description:** Get paginated list of products with filtering  
**Access:** Public

**Query Parameters:**
- `page` (int): Page number (default: 1)
- `per_page` (int): Items per page (default: 20, max: 100)
- `category_id` (uuid): Filter by category
- `search` (string): Search in product names
- `brand` (string): Filter by brand
- `min_price` (decimal): Minimum price filter
- `max_price` (decimal): Maximum price filter
- `in_stock` (boolean): Show only in-stock items
- `featured` (boolean): Show only featured products
- `sort_by` (string): Sort by field (name, price, created_at)
- `sort_order` (string): asc or desc

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "product_id": "uuid-prod1",
      "product_name": "Diamond Cement (50kg bag)",
      "sku": "CEM-DIA-50KG",
      "description": "High quality Portland cement",
      "unit_price": 45.00,
      "unit_of_measure": "bag",
      "category": {
        "category_id": "uuid-cat1",
        "category_name": "Cement & Concrete"
      },
      "brand": "Diamond",
      "is_bulk_item": true,
      "bulk_threshold": 100,
      "bulk_discount_percentage": 1.50,
      "stock_info": {
        "available_stock": 450,
        "in_stock": true
      },
      "images": [
        {
          "image_url": "https://cdn.ebuildify.com/products/cement1.jpg",
          "is_primary": true
        }
      ],
      "batch_number": "BT2024001"
    }
  ],
  "pagination": {
    "current_page": 1,
    "per_page": 20,
    "total_items": 150,
    "total_pages": 8
  }
}
```

#### GET /products/{product_id}
**Description:** Get detailed product information  
**Access:** Public

**Response (200):**
```json
{
  "success": true,
  "data": {
    "product_id": "uuid-prod1",
    "product_name": "Diamond Cement (50kg bag)",
    "sku": "CEM-DIA-50KG",
    "description": "High quality Portland cement, 50kg bag",
    "specifications": "Portland Cement CEM I 42.5N",
    "unit_price": 45.00,
    "unit_of_measure": "bag",
    "minimum_order_quantity": 10,
    "category": {
      "category_id": "uuid-cat1",
      "category_name": "Cement & Concrete"
    },
    "brand": "Diamond",
    "is_bulk_item": true,
    "bulk_threshold": 100,
    "bulk_discount_percentage": 1.50,
    "stock_info": {
      "available_stock": 450,
      "reserved_stock": 50,
      "in_stock": true,
      "reorder_level": 50
    },
    "images": [
      {
        "image_id": "uuid-img1",
        "image_url": "https://cdn.ebuildify.com/products/cement1.jpg",
        "alt_text": "Diamond Cement 50kg bag",
        "is_primary": true
      }
    ],
    "batch_number": "BT2024001",
    "safety_data_sheet_url": "https://cdn.ebuildify.com/sds/cement_sds.pdf",
    "weight_kg": 50.0,
    "dimensions": "40cm x 30cm x 10cm"
  }
}
```

#### GET /products/categories
**Description:** Get all product categories  
**Access:** Public

#### GET /products/search
**Description:** Advanced product search  
**Access:** Public

#### POST /products/compare
**Description:** Compare multiple products  
**Access:** Public

**Request Body:**
```json
{
  "product_ids": ["uuid-prod1", "uuid-prod2", "uuid-prod3"]
}
```

---

## Order Management APIs

### Cart Management

#### GET /cart
**Description:** Get user's current cart  
**Access:** Authenticated

**Response (200):**
```json
{
  "success": true,
  "data": {
    "cart_id": "uuid-cart1",
    "items": [
      {
        "cart_item_id": "uuid-item1",
        "product": {
          "product_id": "uuid-prod1",
          "product_name": "Diamond Cement (50kg bag)",
          "unit_price": 45.00,
          "unit_of_measure": "bag"
        },
        "quantity": 50,
        "unit_price": 45.00,
        "line_total": 2250.00,
        "bulk_discount_applied": false
      }
    ],
    "summary": {
      "items_count": 1,
      "subtotal": 2250.00,
      "bulk_discount_amount": 0.00,
      "estimated_delivery_fee": 25.00,
      "estimated_total": 2275.00
    },
    "saved_offline": false,
    "last_updated": "2024-12-15T10:30:00Z"
  }
}
```

#### POST /cart/items
**Description:** Add item to cart  
**Access:** Authenticated

**Request Body:**
```json
{
  "product_id": "uuid-prod1",
  "quantity": 50,
  "notes": "Special handling required"
}
```

#### PUT /cart/items/{cart_item_id}
**Description:** Update cart item quantity  
**Access:** Authenticated

#### DELETE /cart/items/{cart_item_id}
**Description:** Remove item from cart  
**Access:** Authenticated

#### DELETE /cart
**Description:** Clear entire cart  
**Access:** Authenticated

### Order Processing

#### POST /orders
**Description:** Create new order from cart  
**Access:** Authenticated

**Request Body:**
```json
{
  "delivery_address": {
    "address_line_1": "456 Construction Site",
    "address_line_2": "Near Police Station",
    "city": "Tema",
    "region": "Greater Accra",
    "latitude": 5.6698,
    "longitude": -0.0167
  },
  "delivery_instructions": "Call upon arrival",
  "delivery_time_slot": "morning",
  "project_tag": "Site A - Phase 1",
  "pickup_assignment": {
    "pickup_person_name": "Mary Asante",
    "pickup_person_phone": "+233244567890",
    "pickup_person_id": "GHA-987654321-0"
  },
  "payment_method": "mtn_momo",
  "special_instructions": "Handle cement bags carefully"
}
```

**Response (201):**
```json
{
  "success": true,
  "message": "Order created successfully",
  "data": {
    "order_id": "uuid-order1",
    "order_number": "EB241215-0001",
    "status": "pending",
    "total_amount": 2275.00,
    "items": [
      {
        "product_name": "Diamond Cement (50kg bag)",
        "quantity": 50,
        "unit_price": 45.00,
        "line_total": 2250.00
      }
    ],
    "delivery_info": {
      "estimated_delivery_fee": 25.00,
      "estimated_delivery_date": "2024-12-16",
      "delivery_address": "456 Construction Site, Tema"
    },
    "payment_info": {
      "payment_status": "pending",
      "payment_method": "mtn_momo",
      "amount_due": 2275.00
    }
  }
}
```

#### GET /orders
**Description:** Get user's order history  
**Access:** Authenticated

**Query Parameters:**
- `page` (int): Page number
- `per_page` (int): Items per page
- `status` (string): Filter by order status
- `project_tag` (string): Filter by project tag
- `date_from` (date): Start date filter
- `date_to` (date): End date filter

#### GET /orders/{order_id}
**Description:** Get detailed order information  
**Access:** Authenticated (Owner or Admin)

#### POST /orders/{order_id}/reorder
**Description:** Create new order from previous order  
**Access:** Authenticated

#### PUT /orders/{order_id}/cancel
**Description:** Cancel order (if eligible)  
**Access:** Authenticated

---

## Payment & Credit APIs

### Payment Processing

#### POST /payments/initialize
**Description:** Initialize payment for an order  
**Access:** Authenticated

**Request Body:**
```json
{
  "order_id": "uuid-order1",
  "payment_method": "mtn_momo",
  "phone_number": "+233501234567",
  "amount": 2275.00
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Payment initialized",
  "data": {
    "payment_id": "uuid-pay1",
    "payment_reference": "PAY_abc123xyz",
    "status": "pending",
    "gateway_reference": "flw_ref_123",
    "payment_url": "https://checkout.flutterwave.com/pay/abc123",
    "expires_at": "2024-12-15T11:00:00Z"
  }
}
```

#### POST /payments/webhook
**Description:** Handle payment gateway webhooks  
**Access:** System (Gateway)

#### GET /payments/{payment_id}/status
**Description:** Check payment status  
**Access:** Authenticated

### Credit Management

#### GET /credit/account
**Description:** Get user's credit account details  
**Access:** Authenticated

**Response (200):**
```json
{
  "success": true,
  "data": {
    "credit_account_id": "uuid-credit1",
    "credit_limit": 10000.00,
    "current_balance": 2500.00,
    "available_credit": 7500.00,
    "account_status": "active",
    "linked_accounts": [
      {
        "account_type": "mtn_momo",
        "account_number": "*****4567",
        "account_name": "John Doe",
        "is_active": true
      }
    ],
    "payment_terms_days": 30,
    "next_payment_due": {
      "amount": 1200.00,
      "due_date": "2024-12-30"
    }
  }
}
```

#### POST /credit/apply
**Description:** Apply for credit facility  
**Access:** Authenticated

#### POST /credit/link-account
**Description:** Link payment account for auto-deduction  
**Access:** Authenticated

**Request Body:**
```json
{
  "account_type": "mtn_momo",
  "phone_number": "+233501234567",
  "account_name": "John Doe"
}
```

#### GET /credit/transactions
**Description:** Get credit transaction history  
**Access:** Authenticated

#### POST /credit/manual-payment
**Description:** Make manual credit payment  
**Access:** Authenticated

---

## Service Booking APIs

### Service Management

#### GET /services
**Description:** Get available services  
**Access:** Public

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "service_id": "uuid-serv1",
      "service_name": "Architectural Drawing Service",
      "service_type": "architectural",
      "description": "Professional architectural drawings and blueprints",
      "base_price": 500.00,
      "pricing_unit": "project",
      "estimated_duration_hours": 72,
      "requires_site_visit": true,
      "available_consultants": 3
    }
  ]
}
```

#### GET /services/{service_id}
**Description:** Get detailed service information  
**Access:** Public

#### GET /services/{service_id}/consultants
**Description:** Get available consultants for service  
**Access:** Public

### Service Booking

#### POST /bookings
**Description:** Book a service  
**Access:** Authenticated

**Request Body:**
```json
{
  "service_id": "uuid-serv1",
  "consultant_id": "uuid-consultant1",
  "project_name": "Residential Building - Accra",
  "project_description": "3-bedroom house design with modern finish",
  "requirements": "Must include electrical and plumbing layouts",
  "preferred_start_date": "2024-12-20",
  "site_address": {
    "address_line_1": "Plot 123, East Legon",
    "city": "Accra",
    "region": "Greater Accra"
  }
}
```

**Response (201):**
```json
{
  "success": true,
  "message": "Service booking created successfully",
  "data": {
    "booking_id": "uuid-booking1",
    "status": "pending",
    "service_name": "Architectural Drawing Service",
    "consultant": {
      "name": "Arch. Samuel Osei",
      "specialization": "Residential Architecture",
      "hourly_rate": 75.00
    },
    "quoted_price": 1500.00,
    "estimated_completion": "2024-12-25"
  }
}
```

#### GET /bookings
**Description:** Get user's service bookings  
**Access:** Authenticated

#### GET /bookings/{booking_id}
**Description:** Get booking details  
**Access:** Authenticated

#### PUT /bookings/{booking_id}/status
**Description:** Update booking status (consultant/admin)  
**Access:** Authenticated (Consultant/Admin)

---

## Delivery & Logistics APIs

### Delivery Management

#### GET /delivery/zones
**Description:** Get delivery zones and pricing  
**Access:** Public

#### POST /delivery/calculate-fee
**Description:** Calculate delivery fee based on location  
**Access:** Public

**Request Body:**
```json
{
  "delivery_address": {
    "latitude": 5.6698,
    "longitude": -0.0167
  },
  "items": [
    {
      "product_id": "uuid-prod1",
      "quantity": 50,
      "weight_kg": 2500
    }
  ]
}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "delivery_zone": "Greater Accra - Extended",
    "distance_km": 15.2,
    "base_fee": 25.00,
    "distance_fee": 38.00,
    "total_delivery_fee": 63.00,
    "estimated_delivery_time": "1-2 business days",
    "same_day_available": true,
    "same_day_additional_fee": 20.00
  }
}
```

#### GET /orders/{order_id}/delivery/track
**Description:** Track order delivery status  
**Access:** Authenticated

**Response (200):**
```json
{
  "success": true,
  "data": {
    "order_number": "EB241215-0001",
    "status": "in_transit",
    "driver": {
      "name": "Kwame Asante",
      "phone": "+233245678901",
      "vehicle": "Toyota Hilux - GR 1234-20"
    },
    "timeline": [
      {
        "status": "confirmed",
        "timestamp": "2024-12-15T09:00:00Z",
        "description": "Order confirmed and processing"
      },
      {
        "status": "dispatched",
        "timestamp": "2024-12-15T14:30:00Z",
        "description": "Order dispatched from warehouse"
      },
      {
        "status": "in_transit",
        "timestamp": "2024-12-15T15:45:00Z",
        "description": "Driver en route to delivery location"
      }
    ],
    "estimated_arrival": "2024-12-15T17:00:00Z",
    "delivery_instructions": "Call upon arrival"
  }
}
```

### Damage Reporting

#### POST /orders/{order_id}/damage-report
**Description:** Report damaged goods (time-limited)  
**Access:** Authenticated

**Request Body:**
```json
{
  "product_id": "uuid-prod1",
  "damage_type": "broken",
  "description": "5 cement bags arrived with tears and spillage",
  "photo_evidence": ["base64_image1", "base64_image2"],
  "damage_discovered_at": "2024-12-15T16:30:00Z"
}
```

**Response (201):**
```json
{
  "success": true,
  "message": "Damage report submitted successfully",
  "data": {
    "report_id": "uuid-report1",
    "status": "pending",
    "tracking_id": "DMG-EB241215-001",
    "is_within_deadline": true,
    "report_deadline": "2024-12-15T18:00:00Z",
    "expected_response_time": "1 business hour"
  }
}
```

---

## Admin & Analytics APIs

### Admin Dashboard

#### GET /admin/dashboard
**Description:** Get admin dashboard summary  
**Access:** Admin

**Response (200):**
```json
{
  "success": true,
  "data": {
    "overview": {
      "total_orders_today": 25,
      "total_revenue_today": 45600.00,
      "pending_orders": 8,
      "low_stock_alerts": 3
    },
    "recent_orders": [
      {
        "order_number": "EB241215-0025",
        "customer_name": "John Doe",
        "total_amount": 2275.00,
        "status": "pending",
        "created_at": "2024-12-15T16:45:00Z"
      }
    ],
    "top_products": [
      {
        "product_name": "Diamond Cement (50kg bag)",
        "quantity_sold": 450,
        "revenue": 20250.00
      }
    ],
    "alerts": [
      {
        "type": "low_stock",
        "message": "Diamond Cement stock below reorder level",
        "priority": "high"
      }
    ]
  }
}
```

#### GET /admin/orders
**Description:** Get all orders with advanced filtering  
**Access:** Admin/Warehouse

#### PUT /admin/orders/{order_id}/status
**Description:** Update order status  
**Access:** Admin/Warehouse

#### GET /admin/inventory
**Description:** Get inventory management interface  
**Access:** Admin/Warehouse

#### PUT /admin/inventory/{product_id}/stock
**Description:** Manually adjust stock levels  
**Access:** Admin/Warehouse

**Request Body:**
```json
{
  "new_stock": 500,
  "reason": "Physical stock count adjustment",
  "reference_number": "SC-2024-001"
}
```

### Analytics & Reporting

#### GET /analytics/sales
**Description:** Sales analytics and reports  
**Access:** Admin/Finance

**Query Parameters:**
- `date_from` (date): Start date
- `date_to` (date): End date  
- `group_by` (string): day/month/category/product
- `format` (string): json/csv

#### GET /analytics/customers
**Description:** Customer analytics  
**Access:** Admin

#### GET /analytics/inventory
**Description:** Inventory performance analytics  
**Access:** Admin

---

## Notification APIs

### Notification Management

#### GET /notifications
**Description:** Get user notifications  
**Access:** Authenticated

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "notification_id": "uuid-notif1",
      "title": "Order Delivered Successfully",
      "message": "Your order EB241215-0001 has been delivered to 456 Construction Site, Tema",
      "type": "delivery",
      "status": "unread",
      "created_at": "2024-12-15T17:00:00Z",
      "metadata": {
        "order_id": "uuid-order1",
        "order_number": "EB241215-0001"
      }
    }
  ],
  "unread_count": 3
}
```

#### PUT /notifications/{notification_id}/read
**Description:** Mark notification as read  
**Access:** Authenticated

#### PUT /notifications/mark-all-read
**Description:** Mark all notifications as read  
**Access:** Authenticated

#### POST /notifications/preferences
**Description:** Update notification preferences  
**Access:** Authenticated

---

## Error Handling

### Standard Error Response Format
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input data provided",
    "details": [
      {
        "field": "email",
        "message": "Invalid email format"
      }
    ]
  },
  "meta": {
    "timestamp": "2024-12-15T10:30:00Z",
    "request_id": "req_abc123"
  }
}
```

### Common Error Codes

| HTTP Status | Error Code | Description |
|-------------|------------|-------------|
| 400 | VALIDATION_ERROR | Request validation failed |
| 401 | UNAUTHORIZED | Authentication required |
| 403 | FORBIDDEN | Insufficient permissions |
| 404 | NOT_FOUND | Resource not found |
| 409 | CONFLICT | Resource conflict (e.g., duplicate) |
| 422 | BUSINESS_LOGIC_ERROR | Business rule violation |
| 429 | RATE_LIMIT_EXCEEDED | Too many requests |
| 500 | INTERNAL_ERROR | Server error |
| 503 | SERVICE_UNAVAILABLE | Service temporarily unavailable |

### Specific Business Error Codes

| Error Code | Description |
|------------|-------------|
| INSUFFICIENT_STOCK | Product out of stock |
| CREDIT_LIMIT_EXCEEDED | Credit limit exceeded |
| DAMAGE_REPORT_EXPIRED | Damage report window expired |
| GHANA_CARD_VERIFICATION_FAILED | Ghana Card verification failed |
| PAYMENT_GATEWAY_ERROR | Payment processing error |
| DELIVERY_ZONE_UNAVAILABLE | Delivery not available to location |

---

## Rate Limiting

### Rate Limit Headers
All API responses include rate limiting headers:
```
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 999
X-RateLimit-Reset: 1640443200
```

### Rate Limits by User Type

| User Type | Requests/Hour | Burst Limit |
|-----------|---------------|-------------|
| Anonymous | 100 | 10/minute |
| Customer | 1000 | 50/minute |
| Contractor | 2000 | 100/minute |
| Admin | 5000 | 200/minute |
| System | Unlimited | Unlimited |

### Rate Limit Exceeded Response (429)
```json
{
  "success": false,
  "error": {
    "code": "RATE_LIMIT_EXCEEDED",
    "message": "Too many requests. Please try again later.",
    "retry_after": 3600
  }
}
```

---

## API Testing

### Postman Collection
A comprehensive Postman collection is available with:
- Pre-request scripts for authentication
- Environment variables for different stages
- Test assertions for response validation
- Mock data for testing

### Test Scenarios Covered

#### Authentication Tests
- User registration with Ghana Card
- Login/logout flows
- Token refresh mechanisms
- Invalid credential handling

#### Product Catalog Tests
- Product search and filtering
- Category browsing
- Bulk pricing calculations
- Stock availability checks

#### Order Management Tests
- Cart operations (add/update/remove)
- Order creation and validation
- Bulk discount applications
- Project tagging functionality

#### Payment Processing Tests
- Multiple payment methods
- Credit account operations
- Payment gateway integrations
- Failed payment handling

#### Service Booking Tests
- Service availability checks
- Consultant assignment
- Booking status updates
- Quote generation

#### Delivery Management Tests
- Distance-based pricing
- Zone availability checks
- Damage reporting (within time window)
- Delivery tracking

### Sample Test Data

#### Test Users
```json
{
  "admin": {
    "email": "admin@ebuildify.com",
    "password": "AdminTest123!"
  },
  "customer": {
    "email": "customer@test.com", 
    "password": "CustomerTest123!"
  },
  "contractor": {
    "email": "contractor@test.com",
    "password": "ContractorTest123!"
  }
}
```

#### Test Products
- Diamond Cement (50kg) - Bulk eligible
- Iron Rods (12mm x 6m) - Bulk eligible  
- Roofing Sheets - Regular item
- Paint Emulsion (20L) - Regular item

#### Test Orders
- Small order (< 100 units) - No bulk discount
- Large order (≥ 100 units) - 1.5% bulk discount
- Credit purchase order
- COD order with specific delivery time

---

## API Versioning Strategy

### Version Management
- **Current Version:** v1
- **Versioning Method:** URL-based (`/v1/`, `/v2/`)
- **Backward Compatibility:** Maintained for 1 year minimum
- **Deprecation Notice:** 6 months advance notice

### Version Migration Path
```
v1 (Current) → v2 (Future)
- Enhanced Ghana Card integration
- Advanced analytics endpoints
- Multi-language support
- Enhanced search capabilities
```

---

## Security Considerations

### Data Protection
- **Encryption:** All sensitive data encrypted at rest and in transit
- **PCI-DSS Compliance:** No card data storage, tokenization only
- **Ghana Card Security:** Encrypted storage with access logging
- **HTTPS Only:** All API endpoints require HTTPS

### Input Validation
- **Request Validation:** All inputs validated against schemas
- **SQL Injection Prevention:** Parameterized queries only
- **XSS Protection:** Input sanitization and output encoding
- **File Upload Security:** Type validation and virus scanning

### Access Control
- **Role-Based Access:** Granular permissions by user type
- **Resource Ownership:** Users can only access their own data
- **Admin Privileges:** Separate admin authentication required
- **API Key Management:** Secure key generation and rotation

---

## Integration Guidelines

### Third-Party Integrations

#### Payment Gateways
**Flutterwave Integration:**
```bash
# Webhook endpoint for payment status updates
POST /payments/webhook/flutterwave
Headers:
  verif-hash: <flutterwave_hash>
```

**MTN MoMo Integration:**
```bash
# MoMo payment initialization
POST /payments/momo/initialize
{
  "phone_number": "+233501234567",
  "amount": 2275.00,
  "reference": "EB241215-0001"
}
```

#### Google Maps API
**Distance Calculation:**
```bash
# Used internally for delivery fee calculation
GET /delivery/calculate-distance
{
  "origin": { "lat": 5.6037, "lng": -0.1870 },
  "destination": { "lat": 5.6698, "lng": -0.0167 }
}
```

#### SMS/Email Notifications
**Twilio Integration:**
```bash
# SMS notification webhook
POST /notifications/webhook/twilio
{
  "MessageSid": "SM1234567890",
  "MessageStatus": "delivered",
  "To": "+233501234567"
}
```

#### Google Sheets Sync
**Inventory Synchronization:**
```bash
# Hourly inventory sync
POST /admin/inventory/sync-sheets
{
  "sheet_id": "1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgvE2upms",
  "range": "Products!A2:H100"
}
```

---

## Performance Optimization

### Caching Strategy
- **Redis Integration:** Session management, cart storage
- **Application-Level Caching:** Product catalogs, categories
- **CDN Usage:** Static assets, product images
- **Query Caching:** Frequently accessed data

### Database Optimization
- **Indexing:** Strategic indexes on search fields
- **Query Optimization:** Efficient joins and filters
- **Connection Pooling:** Managed database connections
- **Read Replicas:** Separate read/write operations

### Response Time Targets
| Endpoint Type | Target Response Time |
|---------------|---------------------|
| Authentication | < 500ms |
| Product Catalog | < 300ms |
| Cart Operations | < 200ms |
| Order Creation | < 1000ms |
| Payment Processing | < 2000ms |
| Analytics | < 1500ms |

---

## Monitoring & Logging

### API Monitoring
- **Health Checks:** `/health` endpoint for system status
- **Performance Metrics:** Response times, error rates
- **Availability Monitoring:** 99.9% uptime target
- **Alert System:** Real-time notifications for issues

### Logging Standards
```json
{
  "timestamp": "2024-12-15T10:30:00Z",
  "level": "INFO",
  "service": "order-service",
  "method": "POST",
  "endpoint": "/orders",
  "user_id": "uuid-123",
  "request_id": "req_abc123",
  "response_time": 245,
  "status_code": 201,
  "message": "Order created successfully"
}
```

### Audit Trail
- **User Actions:** Complete audit log of user activities
- **Data Changes:** Before/after values for all modifications
- **Admin Actions:** Enhanced logging for administrative operations
- **Security Events:** Failed authentication attempts, suspicious activities

---

## API Documentation Tools

### Interactive Documentation
- **Swagger/OpenAPI 3.0:** Complete API specification
- **Interactive Testing:** Built-in API testing interface
- **Code Generation:** Client SDKs in multiple languages
- **Mock Server:** Testing without backend implementation

### Developer Resources
- **Getting Started Guide:** Quick setup for developers
- **SDK Libraries:** JavaScript, Python, PHP client libraries
- **Code Examples:** Common use case implementations
- **Webhook Testing:** Tools for webhook development

### API Explorer
```bash
# Access interactive API documentation
https://api.ebuildify.com/docs

# Swagger JSON specification
https://api.ebuildify.com/swagger.json

# Postman Collection
https://api.ebuildify.com/postman-collection.json
```

---

## Deployment & Environment Configuration

### Environment Setup

#### Development Environment
```bash
Base URL: https://dev-api.ebuildify.com/v1
Database: PostgreSQL (Development)
Redis: Development instance
Payment: Flutterwave Test Mode
Notifications: Test SMS/Email providers
```

#### Staging Environment
```bash
Base URL: https://staging-api.ebuildify.com/v1
Database: PostgreSQL (Staging)
Redis: Staging instance
Payment: Flutterwave Test Mode
Notifications: Test SMS/Email providers
Features: Production-like data, testing workflows
```

#### Production Environment
```bash
Base URL: https://api.ebuildify.com/v1
Database: PostgreSQL (Production with replicas)
Redis: Production cluster
Payment: Flutterwave Live Mode
Notifications: Live SMS/Email providers
Features: Full security, monitoring, backups
```

### Configuration Management
```json
{
  "database": {
    "host": "${DB_HOST}",
    "port": "${DB_PORT}",
    "name": "${DB_NAME}",
    "ssl": true
  },
  "payment": {
    "flutterwave": {
      "public_key": "${FLW_PUBLIC_KEY}",
      "secret_key": "${FLW_SECRET_KEY}",
      "webhook_hash": "${FLW_WEBHOOK_HASH}"
    }
  },
  "notifications": {
    "twilio": {
      "account_sid": "${TWILIO_SID}",
      "auth_token": "${TWILIO_TOKEN}"
    }
  }
}
```

---

## Client Integration Examples

### JavaScript/React Integration
```javascript
// eBuildify API Client
class EBuildifyClient {
  constructor(baseUrl, apiKey) {
    this.baseUrl = baseUrl;
    this.apiKey = apiKey;
  }

  async authenticate(email, password) {
    const response = await fetch(`${this.baseUrl}/auth/login`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({ email, password })
    });
    
    const data = await response.json();
    if (data.success) {
      this.accessToken = data.data.tokens.access_token;
      localStorage.setItem('ebuildify_token', this.accessToken);
    }
    return data;
  }

  async getProducts(filters = {}) {
    const queryParams = new URLSearchParams(filters);
    const response = await fetch(
      `${this.baseUrl}/products?${queryParams}`,
      {
        headers: this._getAuthHeaders()
      }
    );
    return response.json();
  }

  async addToCart(productId, quantity) {
    const response = await fetch(`${this.baseUrl}/cart/items`, {
      method: 'POST',
      headers: {
        ...this._getAuthHeaders(),
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        product_id: productId,
        quantity: quantity
      })
    });
    return response.json();
  }

  _getAuthHeaders() {
    return {
      'Authorization': `Bearer ${this.accessToken}`,
      'X-API-Key': this.apiKey
    };
  }
}

// Usage Example
const client = new EBuildifyClient(
  'https://api.ebuildify.com/v1',
  'your-api-key'
);

// Login user
await client.authenticate('user@example.com', 'password');

// Get products
const products = await client.getProducts({
  category_id: 'cement-concrete',
  in_stock: true,
  page: 1
});
```

### Python Integration
```python
import requests
import json
from typing import Dict, Optional

class EBuildifyClient:
    def __init__(self, base_url: str, api_key: str):
        self.base_url = base_url
        self.api_key = api_key
        self.access_token = None
        
    def authenticate(self, email: str, password: str) -> Dict:
        """Authenticate user and store access token"""
        response = requests.post(
            f"{self.base_url}/auth/login",
            json={"email": email, "password": password}
        )
        data = response.json()
        
        if data["success"]:
            self.access_token = data["data"]["tokens"]["access_token"]
            
        return data
    
    def get_products(self, **filters) -> Dict:
        """Get products with optional filters"""
        headers = self._get_auth_headers()
        response = requests.get(
            f"{self.base_url}/products",
            headers=headers,
            params=filters
        )
        return response.json()
    
    def create_order(self, order_data: Dict) -> Dict:
        """Create a new order"""
        headers = self._get_auth_headers()
        headers["Content-Type"] = "application/json"
        
        response = requests.post(
            f"{self.base_url}/orders",
            headers=headers,
            json=order_data
        )
        return response.json()
    
    def _get_auth_headers(self) -> Dict[str, str]:
        """Get authentication headers"""
        return {
            "Authorization": f"Bearer {self.access_token}",
            "X-API-Key": self.api_key
        }

# Usage Example
client = EBuildifyClient(
    "https://api.ebuildify.com/v1",
    "your-api-key"
)

# Authenticate
result = client.authenticate("user@example.com", "password")

# Get cement products
cement_products = client.get_products(
    category_id="cement-concrete",
    in_stock=True
)
```

### Mobile App Integration (React Native)
```javascript
// services/EBuildifyAPI.js
import AsyncStorage from '@react-native-async-storage/async-storage';

class EBuildifyAPI {
  constructor() {
    this.baseUrl = 'https://api.ebuildify.com/v1';
    this.token = null;
  }

  async init() {
    this.token = await AsyncStorage.getItem('auth_token');
  }

  async login(email, password) {
    try {
      const response = await fetch(`${this.baseUrl}/auth/login`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ email, password }),
      });

      const data = await response.json();
      
      if (data.success) {
        this.token = data.data.tokens.access_token;
        await AsyncStorage.setItem('auth_token', this.token);
      }
      
      return data;
    } catch (error) {
      throw new Error('Network error: ' + error.message);
    }
  }

  async getCart() {
    const response = await this._authenticatedRequest('/cart');
    return response.json();
  }

  async _authenticatedRequest(endpoint, options = {}) {
    const headers = {
      'Authorization': `Bearer ${this.token}`,
      'Content-Type': 'application/json',
      ...options.headers,
    };

    return fetch(`${this.baseUrl}${endpoint}`, {
      ...options,
      headers,
    });
  }
}

export default new EBuildifyAPI();
```

---

## Conclusion

This comprehensive API specification provides the foundation for the eBuildify platform, ensuring:

### ✅ **Business Requirements Coverage**
- Complete user management with Ghana Card verification
- Advanced order processing with bulk discounts
- Comprehensive payment and credit management
- Professional service booking capabilities
- Sophisticated delivery and logistics management

### ✅ **Technical Excellence**
- RESTful design principles
- Comprehensive error handling
- Security best practices
- Performance optimization
- Scalable architecture

### ✅ **Developer Experience**
- Clear documentation with examples
- Interactive API testing
- Multiple client library examples
- Comprehensive test scenarios

### ✅ **Business Intelligence**
- Analytics and reporting endpoints
- Admin dashboard capabilities
- Audit trail and monitoring
- Performance metrics

The API is designed to support the complete eBuildify ecosystem from initial user registration through order fulfillment, while maintaining the flexibility to evolve with business needs and scale with growth.

### Next Steps
1. **Frontend Development:** Use this API specification to build the React-based PWA
2. **Backend Implementation:** Implement the microservices architecture as defined
3. **Integration Testing:** Execute comprehensive test scenarios
4. **Security Audit:** Conduct thorough security assessment
5. **Performance Testing:** Validate response time targets
6. **Documentation Review:** Client validation of API design

**Contact Information:**
- **Technical Lead:** BuildTech Solutions
- **API Version:** v2.0
- **Last Updated:** December 15, 2024
- **Review Date:** January 15, 2025