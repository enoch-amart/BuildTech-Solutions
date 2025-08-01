<div align='center'>

# DCIT 208 - SOFTWARE ENGINEERING

## PRODUCT BACKLOG SPECIFICATION

### DCIT 208 | SEMESTER II | 2024/25 ACADEMIC YEAR | COURSE PROJECT

</div>

<div><br><br></div>
<div><br><br></div>
<div><br><br></div>

#### **Team Name:** BuildTech Solutions

#### **Project:** eBuildify - Construction Materials E-commerce Platform

#### **Client:** Sol Little By Little Enterprises

#### **Due Date:** Friday, August 1, 2025, 23:59 GMT

---

<div style="page-break-after: always;"></div>

## 1. USER STORY REFINEMENT (2 pts)

### Epic to User Story Mapping

| Epic ID | Original Epic                                          | Derived User Story IDs                                                              | Story Count |
| ------- | ------------------------------------------------------ | ----------------------------------------------------------------------------------- | ----------- |
| BE-60   | Epic 0: Platform Infrastructure & Technical Foundation | BE-65, BE-66, BE-68, BE-69, BE-92, BE-93, BE-94, BE-96, BE-97, BE-98, BE-99, BE-100 | 12          |
| BE-1    | Epic 1: Order Management System                        | BE-22                                                                               | 1           |
| BE-2    | Epic 2: Payment & Checkout                             | BE-26, BE-27, BE-28, BE-29, BE-30, BE-74, BE-75                                     | 7           |
| BE-21   | Epic 3: Inventory Sync & Management                    | BE-31, BE-32, BE-76, BE-77                                                          | 4           |
| BE-37   | Epic 4: Delivery Logistics & Pricing                   | BE-35, BE-36, BE-79, BE-80, BE-81, BE-82, BE-83                                     | 7           |
| BE-43   | Epic 5: Contractor Portal & Services                   | BE-38, BE-39, BE-40, BE-41, BE-42, BE-84, BE-85, BE-95                              | 8           |
| BE-57   | Epic 6: Customer Registration & Verification           | (To be derived)                                                                     | 3           |
| BE-44   | Epic 7: Admin, Analytics & Control                     | BE-51, BE-52, BE-76, BE-87, BE-88, BE-89                                            | 6           |
| BE-53   | Epic 8: Technical & Compliance                         | BE-54, BE-55, BE-90, BE-91                                                          | 4           |

### INVEST Compliance Check

All user stories have been refined to ensure they meet INVEST criteria:

- **Independent:** Each story can be developed separately without dependencies on other stories within the same sprint
- **Negotiable:** Stories focus on user value rather than specific implementation details
- **Valuable:** Each story delivers clear business or user value
- **Estimable:** Stories are small enough to be estimated accurately (≤2 days effort)
- **Small:** No story exceeds 13 story points or 2 days of development effort
- **Testable:** Clear acceptance criteria defined for each story

---

## 2. SIZING & PRIORITISATION (2 pts)

### Estimation Method

**Method Used:** Planning Poker with Fibonacci Scale (1, 2, 3, 5, 8, 13)

### Story Point Distribution

| Priority Level       | Story Points Range | Story Count | Total Points |
| -------------------- | ------------------ | ----------- | ------------ |
| Must Have            | 8-13 points        | 15 stories  | 165 points   |
| Should Have          | 5-8 points         | 20 stories  | 140 points   |
| Could Have           | 2-5 points         | 12 stories  | 48 points    |
| Won't Have (Phase 2) | 1-3 points         | 8 stories   | 16 points    |

**Total Backlog Points:** 369 story points  
**Assumed Team Velocity:** 45 points per 2-week sprint  
**Estimated Sprint Count:** 8.2 sprints (≈ 16 weeks)

### Prioritization Framework

Stories prioritized using MoSCoW method combined with business value scoring:

1. **Must Have (Highest):** Core MVP functionality - product catalog, payments, inventory, basic delivery
2. **Should Have (High):** Enhanced user experience - advanced delivery features, contractor portal
3. **Could Have (Medium):** Nice-to-have features - rental services, advanced analytics
4. **Won't Have (Low):** Future phase features - multi-language, advanced AI features

---

## 3. UP-TO-DATE STORY LIST (1 pt)

### Infrastructure & Foundation Stories (Epic 0)

**US-1:** Configure local and staging environments  
**ID:** BE-65 | **Points:** 5 | **Priority:** Must Have  
**Description:** Set up development, staging, and testing environments with proper configuration  
**Preconditions:** Docker and development tools installed  
**Postconditions:** All team members can run the application locally; staging environment accessible

**US-2:** Set up authentication microservice  
**ID:** BE-66 | **Points:** 8 | **Priority:** Must Have  
**Description:** Bootstrap auth service with user management, JWT tokens, and role-based access  
**Preconditions:** Database schema defined  
**Postconditions:** Users can register, login, and access role-appropriate features

**US-3:** Establish development conventions and README  
**ID:** BE-68 | **Points:** 3 | **Priority:** Must Have  
**Description:** Define coding standards, Git workflow, and comprehensive documentation  
**Preconditions:** Team agreement on conventions  
**Postconditions:** Clear development guidelines and onboarding documentation available

### Order Management Stories (Epic 1)

**US-4:** Browse products with advanced filters  
**ID:** BE-22 | **Points:** 8 | **Priority:** Must Have  
**Description:** Implement product catalog with filtering by category, brand, type, and price range  
**Preconditions:** Product data available, UI components ready  
**Postconditions:** Users can efficiently find products using multiple filter combinations

### Payment & Checkout Stories (Epic 2)

**US-5:** Multi-payment gateway integration  
**ID:** BE-26 | **Points:** 13 | **Priority:** Must Have  
**Description:** Integrate MTN MoMo, Vodafone Cash, and Telecel Cash payment options  
**Preconditions:** Payment gateway APIs available, PCI compliance requirements understood  
**Postconditions:** Users can complete payments using preferred mobile money services

**US-6:** Credit terms request system  
**ID:** BE-27 | **Points:** 8 | **Priority:** Must Have  
**Description:** Allow B2B clients to request credit terms with admin approval workflow  
**Preconditions:** User authentication system complete, admin dashboard framework ready  
**Postconditions:** Contractors can request credit, admins can approve/deny requests

**US-7:** Automatic credit payment setup  
**ID:** BE-28 | **Points:** 13 | **Priority:** Must Have  
**Description:** Enable automatic payment deduction from linked accounts for credit customers  
**Preconditions:** Payment gateway integration complete, account linking system ready  
**Postconditions:** Credit customers can set up auto-debit, system performs scheduled deductions

**US-8:** Credit default penalty system  
**ID:** BE-29 | **Points:** 5 | **Priority:** Must Have  
**Description:** Apply 50% additional fee for defaulted credit purchases  
**Preconditions:** Credit payment tracking system active  
**Postconditions:** System automatically applies penalties for defaulted payments

**US-9:** Late payment penalty system  
**ID:** BE-30 | **Points:** 5 | **Priority:** Must Have  
**Description:** Apply 2% weekly penalty for late credit payments after reminders  
**Preconditions:** Notification system operational, payment tracking active  
**Postconditions:** System applies progressive penalties for late payments

### Inventory Management Stories (Epic 3)

**US-10:** Stock reservation during checkout  
**ID:** BE-31 | **Points:** 8 | **Priority:** Must Have  
**Description:** Reserve inventory for 15 minutes during checkout to prevent overselling  
**Preconditions:** Inventory management system active, concurrent access handling implemented  
**Postconditions:** Stock is temporarily held during checkout, released on timeout or completion

**US-11:** Low stock alerts for warehouse staff  
**ID:** BE-32 | **Points:** 5 | **Priority:** Must Have  
**Description:** Send SMS/email alerts when key materials fall below threshold levels  
**Preconditions:** Notification system ready, inventory thresholds configured  
**Postconditions:** Warehouse staff receive timely alerts for low stock items

### Delivery & Logistics Stories (Epic 4)

**US-12:** Distance-based delivery pricing  
**ID:** BE-35 | **Points:** 8 | **Priority:** Must Have  
**Description:** Calculate and display delivery costs based on customer location  
**Preconditions:** Maps API integration, delivery zones defined  
**Postconditions:** Customers see accurate delivery costs before order confirmation

**US-13:** Damage reporting time window  
**ID:** BE-36 | **Points:** 5 | **Priority:** Must Have  
**Description:** Allow customers to report damaged goods within 1-2 hours of delivery  
**Preconditions:** Delivery confirmation system active, notification system ready  
**Postconditions:** Customers can report damage within time limit, system rejects late reports

### Contractor Portal Stories (Epic 5)

**US-14:** Contractor account registration  
**ID:** BE-38 | **Points:** 8 | **Priority:** Must Have  
**Description:** Specialized registration flow for contractors with business verification  
**Preconditions:** User authentication system complete, admin approval workflow ready  
**Postconditions:** Contractors can register and access business-specific features

**US-15:** Contractor dashboard  
**ID:** BE-39 | **Points:** 8 | **Priority:** Must Have  
**Description:** Personalized dashboard for contractors with order tracking and credit management  
**Preconditions:** Authentication system, order management system complete  
**Postconditions:** Contractors have centralized view of orders, deliveries, and credit status

**US-16:** Consultancy service booking  
**ID:** BE-95 | **Points:** 13 | **Priority:** Must Have  
**Description:** Enable booking of architectural drawings, quantity surveying, and supervision services  
**Preconditions:** Service provider management system, calendar integration  
**Postconditions:** Customers can book and manage consultancy services

### Admin & Analytics Stories (Epic 7)

**US-17:** Role-based refund permissions  
**ID:** BE-51 | **Points:** 5 | **Priority:** Must Have  
**Description:** Restrict refund functionality to finance role only  
**Preconditions:** Role-based access control system active  
**Postconditions:** Only finance users can process refunds

**US-18:** Automated credit payment tracking  
**ID:** BE-52 | **Points:** 8 | **Priority:** Must Have  
**Description:** Dashboard for monitoring outstanding debts and payment status  
**Preconditions:** Credit system operational, payment tracking active  
**Postconditions:** Finance team can monitor all credit transactions and overdue accounts

### Technical & Compliance Stories (Epic 8)

**US-19:** PCI-DSS compliance for card payments  
**ID:** BE-54 | **Points:** 13 | **Priority:** Must Have  
**Description:** Ensure all card payment processing meets PCI-DSS standards  
**Preconditions:** Payment gateway integration complete, security audit framework ready  
**Postconditions:** System passes PCI-DSS compliance verification

**US-20:** Ghana Card data security  
**ID:** BE-55 | **Points:** 8 | **Priority:** Must Have  
**Description:** Implement secure storage and handling of Ghana Card verification data  
**Preconditions:** Encryption systems ready, data protection policies defined  
**Postconditions:** Ghana Card data stored securely with proper access controls

---

## 4. SPRINT-1 PLANNING (3 pts)

### Sprint-1 Window

**Duration:** August 2-6, 2025 (5 days)  
**Team Capacity:** 15 story points (⅓ of standard 2-week sprint)

### Selected Stories for Sprint-1

| Story ID | Title                                    | Points | Justification                                         |
| -------- | ---------------------------------------- | ------ | ----------------------------------------------------- |
| BE-65    | Configure local and staging environments | 5      | Foundation requirement - blocks all other development |
| BE-68    | Establish development conventions        | 3      | Critical for team coordination and code quality       |
| BE-66    | Set up authentication microservice       | 8      | Core system dependency for all user-facing features   |

**Total Sprint-1 Points:** 16 points (slightly over capacity due to foundational importance)

### Sprint-1 Rationale

**Dependency Management:** All selected stories are foundational and have minimal dependencies on each other, making them ideal for parallel development in the first sprint.

**MVP Foundation:** These stories establish the technical foundation required for all subsequent feature development:

- Environment setup enables team productivity
- Development conventions ensure code quality and consistency
- Authentication system is a dependency for nearly all user stories

**Risk Mitigation:** By tackling infrastructure early, we identify and resolve environment-related issues before they can impact feature development.

### Sprint-1 Demo Scope

At the end of Sprint-1, stakeholders will see:

1. **Live Demo Environment:** Functioning staging environment accessible via web browser
2. **User Registration & Login:** Working authentication system with role-based access
3. **Development Readiness:** Team can demonstrate local development setup and deployment pipeline
4. **Code Quality Foundation:** Established linting, testing, and code review processes

**User Journey Demo:**

- New user can register an account
- User can log in and see role-appropriate dashboard
- Admin user can access admin-specific features
- System maintains session state and handles logout

**Technical Demo:**

- Continuous integration pipeline running tests
- Staging deployment process
- Code review workflow demonstration
- Local development environment setup guide

---

## 5. DESIGN SKETCHES & UI (2 pts)

### Product Catalog Wireframe

```
┌─────────────────────────────────────────────────────────┐
│ eBuildify Logo    [Search Bar]         Login | Cart (3) │
├─────────────────────────────────────────────────────────┤
│ [Filters Panel]              [Product Grid]             │
│ ┌─────────────┐              ┌─────┐ ┌─────┐ ┌─────┐   │
│ │Categories   │              │Prod │ │Prod │ │Prod │   │
│ │☑ Cement     │              │Img  │ │Img  │ │Img  │   │
│ │☐ Iron Rods  │              │Name │ │Name │ │Name │   │
│ │☐ Paint      │              │₵150 │ │₵300 │ │₵85  │   │
│ │             │              │[Add]│ │[Add]│ │[Add]│   │
│ │Price Range  │              └─────┘ └─────┘ └─────┘   │
│ │₵50 - ₵500   │                                        │
│ │             │              [Load More Products]      │
│ │Brand        │                                        │
│ │☐ Dangote    │                                        │
│ │☐ GHACEM     │                                        │
│ └─────────────┘                                        │
└─────────────────────────────────────────────────────────┘
```

**Key Components:**

- Responsive filter panel (collapsible on mobile)
- Product grid with lazy loading
- Shopping cart counter
- Search functionality with auto-suggestions

**Accessibility Considerations:**

- High contrast colors (WCAG AA compliant)
- Keyboard navigation support for all interactive elements
- Screen reader labels for filter checkboxes
- Alternative text for product images

### Authentication Flow Wireframe

```
┌─────────────────────────────────────────┐
│            Login Screen                 │
│ ┌─────────────────────────────────────┐ │
│ │ Email: [________________]           │ │
│ │ Password: [________________]        │ │
│ │ ☐ Remember me                       │ │
│ │ [Login Button]                      │ │
│ │ ─────────── OR ───────────          │ │
│ │ [Register New Account]              │ │
│ │ [Forgot Password?]                  │ │
│ └─────────────────────────────────────┘ │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│         Registration Screen             │
│ ┌─────────────────────────────────────┐ │
│ │ Account Type:                       │ │
│ │ ○ Individual Customer               │ │
│ │ ○ Contractor/Business               │ │
│ │                                     │ │
│ │ Full Name: [________________]       │ │
│ │ Email: [________________]           │ │
│ │ Phone: [________________]           │ │
│ │ Ghana Card: [________________]      │ │
│ │ Password: [________________]        │ │
│ │ Confirm: [________________]         │ │
│ │                                     │ │
│ │ [Register Account]                  │ │
│ └─────────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

**Key Features:**

- Progressive disclosure based on account type
- Real-time validation feedback
- Ghana Card verification integration
- Secure password requirements

### Checkout & Payment Wireframe

```
┌─────────────────────────────────────────────────────────┐
│                  Checkout Process                       │
├─────────────────────────────────────────────────────────┤
│ Step 1: Order Review    Step 2: Delivery    Step 3: Pay │
│ ──────────────────────────────────────────────────────  │
│ [Cart Items Summary]                                    │
│ ┌─────────────────────────────────────────────────────┐ │
│ │ Dangote Cement (50kg) x 10    ₵1,500              │ │
│ │ Iron Rods (12mm) x 20         ₵2,400              │ │
│ │ ──────────────────────────────────────             │ │
│ │ Subtotal:                     ₵3,900              │ │
│ │ Delivery (Madina):            ₵150                │ │
│ │ Volume Discount (1.5%):       -₵59                │ │
│ │ ──────────────────────────────────────             │ │
│ │ Total:                        ₵3,991              │ │
│ └─────────────────────────────────────────────────────┘ │
│                                                         │
│ Payment Method:                                         │
│ ○ MTN Mobile Money    ○ Vodafone Cash                  │
│ ○ Telecel Cash       ○ Credit Terms (B2B)             │
│                                                         │
│ [Complete Order]                                        │
└─────────────────────────────────────────────────────────┘
```

**Interaction Notes:**

- Real-time delivery cost calculation based on address
- Automatic volume discount application
- Payment method selection with appropriate forms
- Order confirmation with tracking information

### Mobile-First Responsive Considerations

All wireframes designed with mobile-first approach:

- **Touch-friendly buttons** (minimum 44px tap targets)
- **Simplified navigation** with hamburger menu
- **Stacked layouts** for narrow screens
- **Gesture support** for product browsing
- **Offline cart persistence** for poor connectivity areas

### Accessibility Features Integrated

- **Color blind friendly** color palette
- **High contrast mode** toggle
- **Font size adjustment** controls
- **Keyboard navigation** flow indicators
- **Screen reader** semantic markup
- **Voice control** compatibility for form inputs

---

## BACKLOG MANAGEMENT & TRACEABILITY

### GitHub Integration

- **Repository:** https://github.com/enoch-amart/BuildTech-Solutions
- **Project Board:** GitHub Projects with Scrum template
- **Story IDs:** All commit messages include story ID (e.g., "BE-22: Implement product filtering")

### Definition of Done

Each user story is considered complete when:

1. Code implemented and unit tested (≥80% coverage)
2. Feature tested on staging environment
3. Code reviewed and approved by 2+ team members
4. Documentation updated (API docs, user guides)
5. Acceptance criteria verified by Product Owner
6. No critical or high-severity bugs open

### Workflow States

- **Backlog:** Story identified and prioritized
- **In Progress:** Development actively underway
- **Review:** Code complete, awaiting peer review
- **Testing:** QA validation in progress
- **Done:** All acceptance criteria met, deployed to staging

This Product Backlog Specification provides the foundation for successful delivery of the eBuildify platform, ensuring all team members understand priorities, scope, and technical requirements for the 16-week development timeline.
