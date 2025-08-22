# eBuildify User Manual

## Ghana's Premier Building Materials Delivery Platform

<div><br></br></div>
<div><br></br></div>
<div><br></br></div>
<div><br></br></div>

**DCIT 208 Final Project Deliverable**  
**Project Name:** eBuildify - Building Materials E-commerce Platform  
**Team:** BuildTech Solutions
**Submission Date:** August 22, 2025  
**Website URL:** https://v0-ui-ux-design-project-iota.vercel.app/  
**GitHub Repository:** https://github.com/enoch-amart/ebuildify_frontend.git

---

<div style="page-break-after: always;"></div>

## Table of Contents

1. [Deployment & Installation](#1-deployment--installation)
2. [System Features](#2-system-features)
3. [Main Scenario Walkthrough](#3-main-scenario-walkthrough)
4. [Additional Scenarios](#4-additional-scenarios)

---

<div style="page-break-after: always;"></div>

## 1. Deployment & Installation

### 1.1 System Requirements

**Hardware Requirements:**

- **Server/Hosting:** Minimum 1GB RAM, 10GB storage space
- **Client Devices:** Any internet-connected device (desktop, tablet, mobile)
- **Internet Connection:** Minimum 1 Mbps recommended for optimal performance

**Software Requirements:**

- **Frontend Framework:** Next.js 14+ / React 18+
- **Runtime Environment:** Node.js 18.0 or higher
- **Package Manager:** pnpm 8.0+ (specifically required)
- **Web Browsers:** Chrome 90+, Firefox 88+, Safari 14+, Edge 90+
- **Development Tools:** Git, VS Code recommended

### 1.2 Installation Instructions

#### Option A: Live Website Access (Recommended for End Users)

1. Open your preferred web browser
2. Navigate to: `https://v0-ui-ux-design-project-iota.vercel.app/`
3. The application loads immediately without installation requirements
4. Consider bookmarking for convenient future access

#### Option B: Local Development Setup (For Developers)

**Step 1: Repository Cloning**

```bash
git clone https://github.com/enoch-amart/ebuildify_frontend.git
cd ebuildify_frontend
```

**Step 2: Dependency Installation**

```bash
pnpm install
```

**Step 3: Environment Configuration**

1. Create `.env.local` file in the root directory
2. Configure required environment variables:

```
NEXT_PUBLIC_API_URL=your_api_url_here
NEXT_PUBLIC_STRIPE_KEY=your_stripe_key_here
```

**Step 4: Development Server Launch**

```bash
pnpm dev
```

**Step 5: Production Build Process**

```bash
pnpm build
pnpm start
```

### 1.3 Deployment Configuration

**Current Vercel Deployment:**

- Hosted on Vercel platform with automatic GitHub integration
- Continuous deployment from main branch
- SSL certificate management and CDN optimization included
- Global performance optimization enabled

**Alternative Deployment Methods:**

- Netlify: Direct GitHub repository connection
- AWS Amplify: Next.js build configuration support
- Traditional hosting: Static build deployment option

---

<div style="page-break-after: always;"> </div>

## 2. System Features

### 2.1 Core E-commerce Functionality

**Product Catalog Management**

- Comprehensive building materials categorization (cement, iron rods, tiles, aggregates, timber, paints)
- Advanced search and filtering system
- Detailed product specifications with pricing and availability status
- High-resolution product imagery with zoom capabilities

**Shopping Cart & Checkout Process**

- Intuitive add/remove cart functionality
- Real-time quantity adjustments and price calculations
- Secure multi-payment option checkout system
- Comprehensive order summary and confirmation process

**User Account System**

- Streamlined registration and authentication
- Ghana Card verification integration for enhanced security
- Personal profile management with order history tracking
- Multiple delivery address management

### 2.2 Professional Construction Services

**Architectural Services Integration**

- **Professional Drawings:** Complete architectural plans, floor plans, elevations, and 3D rendering services
- **Quantity Estimation:** Automated material calculations based on project specifications
- **Cost Analysis:** Detailed project budgeting with comprehensive bill of quantities
- **Site Supervision:** Professional construction oversight and quality assurance services

**Industry-Specific Tools**

- Integrated material calculators for accurate project planning
- Automatic bulk ordering discounts (1.5% for orders exceeding 100 units)
- Specialized contractor dashboard with project management capabilities
- Extensive local supplier network integration across Ghana

### 2.3 Delivery & Logistics Management

**Advanced Delivery System**

- Same-day delivery service throughout Greater Accra region
- Real-time order tracking with status notifications
- Flexible delivery scheduling with preferred time slot selection
- Automated SMS and email delivery updates

**Geographic Coverage**

- Primary service area: Greater Accra region
- Progressive expansion to additional major cities
- Location-based pricing structure and delivery options
- Regional supplier network partnerships

### 2.4 Customer Support Infrastructure

**Multi-language Capabilities**

- Full interface support in English and Twi languages
- Bilingual customer service team
- Culturally adapted user experience for local market requirements

**Comprehensive Support Channels**

- 24/7 live chat functionality
- Dedicated phone support hotline
- Email ticketing system
- Extensive FAQ and documentation resources

### 2.5 Security & Trust Framework

**Ghana Card Verification System**

- Mandatory identity verification for all platform users
- Advanced fraud prevention and security measures
- Enhanced platform credibility and user trust

**Quality Assurance Program**

- Verified supplier network with certification requirements
- Product quality guarantees and warranties
- Comprehensive return and refund policy framework
- User review and rating system for transparency

---

<div style="page-break-after: always;"> </div>

## 3. Main Scenario Walkthrough: Complete Material Ordering Process

This comprehensive walkthrough demonstrates the platform's primary functionality through a typical customer journey involving building materials procurement for construction projects.

### 3.1 Scenario Overview

**User Profile:** John, an experienced contractor managing a residential construction project in Accra  
**Objective:** Procure cement, iron rods, and tiles for foundation construction phase  
**Estimated Duration:** 15-20 minutes for complete transaction

### 3.2 Detailed Process Execution

**Step 1: Platform Access**

1. Launch web browser and navigate to `https://v0-ui-ux-design-project-iota.vercel.app/`
2. **System Response:** Homepage displays with eBuildify branding, navigation structure, and featured product sections
3. **Visual Context:** Main landing page showcasing "Ghana's Premier Building Materials Delivery Platform" messaging

**Step 2: Account Registration Process**

1. Select "Sign Up" from primary navigation menu
2. Complete registration form including:
   - Full legal name
   - Valid email address
   - Contact phone number
   - Ghana Card identification number for verification
3. Submit registration request
4. **System Response:** Verification email dispatch and successful account creation confirmation
5. **Visual Context:** Registration interface displaying Ghana Card verification requirement

**Step 3: Product Category Navigation**

1. Access "Categories" from main navigation menu
2. Select "Cement" from available category options
3. **System Response:** Product listing interface displaying available cement varieties with current pricing
4. **Visual Context:** Categorized product display with sidebar filtering options

**Step 4: Product Selection and Cart Management**

1. Select "Dangote Cement 50kg" from product listing
2. Review detailed product specifications and current price (GHS 45.00)
3. Specify quantity requirement: 20 bags
4. Execute "Add to Cart" action
5. Return to categories and repeat process for:
   - Iron Rods 12mm specification (10 pieces)
   - Floor Tiles 60x60cm dimensions (50 pieces)
6. **System Response:** Cart counter updates reflect added items with confirmation messages
7. **Visual Context:** Product detail pages showing comprehensive specifications and purchase options

**Step 5: Cart Review and Pricing Calculation**

1. Access shopping cart via header cart icon (displaying current item count)
2. Review all selected products with quantities and individual pricing
3. System applies automatic contractor discount (1.5% for qualifying bulk orders)
4. **System Response:**
   - Subtotal calculation: GHS 2,840.00
   - Applied discount: GHS 42.60
   - Final total: GHS 2,797.40
5. **Visual Context:** Comprehensive cart interface with itemized pricing breakdown

**Step 6: Checkout Process Initiation**

1. Select "Proceed to Checkout" option
2. Verify delivery address within Accra service area
3. Choose delivery method: "Same-day delivery (GHS 50)"
4. Select payment option: "Mobile Money (MTN)"
5. **System Response:** Order summary displaying final pricing including delivery charges
6. **Visual Context:** Checkout interface presenting delivery and payment method selections

**Step 7: Payment Processing**

1. Input MTN Mobile Money contact number
2. Select "Complete Order" to initiate payment
3. Respond to mobile device payment authorization prompt
4. Complete transaction using MTN MoMo PIN verification
5. **System Response:**
   - Payment confirmation display
   - Order reference generation (e.g., #EB2025082200123)
   - Automatic confirmation email dispatch
6. **Visual Context:** Payment confirmation screen with complete order details

**Step 8: Order Tracking Access**

1. Navigate to "My Orders" within user dashboard
2. Select recent order #EB2025082200123 for detailed tracking
3. Monitor real-time order status updates
4. **System Response:**
   - Current status: "Confirmed - Preparing for delivery"
   - Delivery estimate: Same day, 2-4 PM window
   - SMS notification confirmation
5. **Visual Context:** Order tracking interface with delivery timeline visualization

### 3.3 Scenario Outcome Analysis

This walkthrough effectively demonstrates eBuildify's solution to traditional building materials procurement challenges in Ghana by providing:

- Streamlined online access to verified supplier networks
- Transparent pricing with automatic bulk discount applications
- Reliable same-day delivery within Greater Accra coverage area
- Enhanced security through mandatory Ghana Card verification processes

---

<div style="page-break-after: always;"></div>

## 4. Additional Scenarios

### 4.1 Professional Services Request Scenario

**Context:** Sarah, a licensed architect, requires technical architectural drawings for a client's residential development project.

**Process Execution:**

1. **Professional Services Access**

   - Navigate to "Services" menu section
   - Select "Professional Services" option
   - **System Response:** Services overview displaying architectural, estimation, and supervision service categories

2. **Service Request Submission**

   - Select "Architectural Services" from available options
   - Upload project requirement documentation
   - Complete detailed service request form:
     - Project classification: Residential construction
     - Building specifications: 4-bedroom residential structure
     - Required deliverables: Floor plans, architectural elevations, 3D rendering visualizations
   - **System Response:** Service request successfully submitted for professional review

3. **Quote Generation and Project Acceptance**
   - Professional review completed within 24-hour timeframe
   - Service quotation provided: GHS 2,500 for complete architectural service package
   - Client quote acceptance and payment processing
   - **System Response:** Project initiation with established timeline (7-10 business days completion)

**Application Context:** This scenario addresses situations where customers require comprehensive professional construction services beyond standard materials procurement.

### 4.2 Large-Scale Contractor Bulk Ordering Scenario

**Context:** Mike, a major construction contractor, manages multiple simultaneous projects requiring coordinated material deliveries with specific scheduling requirements.

**Process Execution:**

1. **Contractor Dashboard Access**

   - Login through verified contractor account credentials
   - Access specialized "Bulk Orders" section
   - **System Response:** Contractor-specific interface optimized for large-scale ordering operations

2. **Multi-Project Delivery Coordination**

   - Configure Project A: 500 cement bags (Monday 9 AM delivery)
   - Configure Project B: 200 iron rods (Wednesday 2 PM delivery)
   - Configure Project C: 1000 concrete blocks (Friday 10 AM delivery)
   - **System Response:** Multi-delivery order system with individual project tracking capabilities

3. **Contractor Benefit Application**
   - Automatic bulk discount calculation (1.5% applied)
   - Extended payment terms qualification (30-day net payment)
   - Priority customer service access assignment
   - **System Response:**
     - Total discount savings: GHS 450
     - Payment terms: Net 30 business days
     - Dedicated account manager assignment

**Application Context:** Large-scale contractors managing multiple concurrent projects with complex material delivery coordination requirements.

---

<div style="page-break-after: always;"> </div>

## Conclusion

This user manual provides comprehensive operational guidance for eBuildify, Ghana's leading building materials delivery platform. The system addresses critical challenges within Ghana's construction industry through:

- **Industry Digitization:** Transformation from traditional procurement methods to efficient online ordering systems
- **Trust Infrastructure:** Ghana Card verification ensuring platform security for all users
- **Local Market Expertise:** Deep understanding of Ghanaian construction industry requirements
- **Service Integration:** Comprehensive material procurement combined with professional construction services

**Post-User Acceptance Testing Improvements:**

- Enhanced mobile device responsiveness based on user feedback analysis
- Streamlined checkout process reducing cart abandonment rates
- Implementation of Twi language support addressing local user requirements
- Improved search functionality incorporating local product terminology

The platform effectively serves both individual customers and large-scale contractors, providing scalable solutions for Ghana's expanding construction sector requirements.

---

<div style="page-break-after: always;"> </div>

**Technical Support Contact Information:**

- Email: amarteifioenoch4@gmail.com
- Phone: +233 54 297 2982
- Live Chat: 24/7 website availability

**System Maintenance Protocol:**

- Automated update deployment via Vercel platform
- Daily database backup procedures
- Continuous security monitoring with automatic SSL certificate renewal
