# DCIT 208 - SOFTWARE ENGINEERING

## COURSE PROJECT PROPOSAL SPECIFICATION

**Team Name:** BuildTech Solutions
**Project Title:** eBuildify - Integrated Building Materials E-Commerce Platform  
**Client:** Sol Little By Little Enterprise  
**Submission Date:** July 27, 2025

---

## 1. Introduction & System Intent (4 pts)

### Client Overview

**Client Name:** Sol Little By Little Enterprise  
**Contact Person:** Mr. Enoch Amarteifio (Product Lead/Client Representative)  
**Business Address:** Accra, Greater Accra Region, Ghana  
**Industry:** Building Materials Supply & Construction Services  
**Business Model:** B2B and B2C building materials distribution with value-added services

Sol Little By Little Enterprise is an established building materials supplier operating primarily in the Greater Accra region, serving both individual customers and commercial contractors. The company currently manages operations through manual processes including phone orders, WhatsApp communications, and spreadsheet-based inventory management. They supply a comprehensive range of construction materials including cement, iron rods, roofing materials, paints, plumbing supplies, and professional consultancy services.

### Problem Statement

The client faces significant operational inefficiencies due to manual order processing, resulting in order errors, delivery delays, and customer dissatisfaction. Current pain points include: manual order recording causing 15-20% error rates, inventory discrepancies leading to overselling, inefficient delivery scheduling resulting in 40% longer fulfillment times, lack of customer purchase history preventing effective relationship management, and absence of real-time analytics limiting business decision-making capabilities. The company loses approximately 25-30% of potential sales due to these operational bottlenecks and seeks digital transformation to capture Ghana's growing construction market.

### System Vision

**Elevator Pitch:** eBuildify will transform building materials procurement in Ghana by providing a comprehensive digital platform that enables seamless product discovery, automated inventory management, flexible payment options including credit facilities, and optimized delivery logistics, ultimately increasing sales by 30% while improving customer satisfaction and operational efficiency.

### User Personas

**Primary Users:**

- **Individual Builders (40% of user base):** Homeowners and small-scale builders needing materials for personal construction projects, requiring easy browsing, competitive pricing, and reliable delivery
- **Contractors & Construction Companies (35% of user base):** Professional builders requiring bulk orders, project-based ordering, credit facilities, volume discounts, and professional services like consultancy and supervision
- **Hardware Shop Owners (15% of user base):** Retailers needing wholesale purchasing, inventory management, and reliable supply chains

**Secondary Users:**

- **Company Staff (10% of user base):** Warehouse personnel, delivery drivers, finance team, and administrators requiring role-based dashboards and operational tools
- **Service Consultants:** Architectural professionals, quantity surveyors, and construction supervisors offering services through the platform

**Context of Use:** Users primarily access the platform via mobile devices (70%) due to Ghana's mobile-first internet usage, requiring offline functionality for areas with poor connectivity. The platform must support both English and future Twi language options, accommodate varying literacy levels through intuitive UI design, and function effectively on 3G networks common in Ghana.

---

## 2. Requirements & Functionality (3 pts)

### Functional Requirements

**FR-1:** User registration and authentication with Ghana Card verification for identity confirmation and fraud prevention  
**FR-2:** Comprehensive product catalog browsing with category filters, search functionality, and product comparison features  
**FR-3:** Shopping cart management with offline support, product reservations, and automatic pricing calculations  
**FR-4:** Multi-payment gateway integration supporting MTN MoMo, Vodafone Cash, Telecel Cash, bank transfers, and cash on delivery  
**FR-5:** Credit account management with automatic payment deduction, reminder systems, and penalty calculation  
**FR-6:** Real-time inventory management with stock reservation, low-stock alerts, and automated movement tracking  
**FR-7:** Order management system with status tracking, project tagging, and reorder functionality  
**FR-8:** Distance-based delivery pricing calculation with route optimization and driver assignment  
**FR-9:** Service booking system for consultancy, architectural drawings, quantity surveying, and construction supervision  
**FR-10:** Damage reporting system with time-limited windows (1-2 hours) and photo evidence support  
**FR-11:** Customer incentive programs for first 20 customers with special packages and loyalty rewards  
**FR-12:** Third-party pickup assignment allowing customers to designate alternate pickup persons  
**FR-13:** Administrative dashboards for inventory management, order processing, and financial oversight  
**FR-14:** Notification system supporting SMS, email, and in-app messages for order updates and reminders  
**FR-15:** Analytics and reporting for sales performance, customer behavior, and operational metrics

### Non-Functional Requirements

**Performance Requirements:**

- System must support 500+ concurrent users during peak periods (monthly promotions, rainy season)
- Page load times under 3 seconds on 3G networks for product and checkout pages
- Database queries optimized for sub-second response times using proper indexing strategies
- 99.5% uptime availability during business hours (6 AM - 10 PM GMT)

**Security Requirements:**

- PCI-DSS compliance for payment processing with tokenization and encrypted data transmission
- Ghana Card data encryption and secure storage complying with data protection regulations
- Role-based access control with granular permissions for different user types
- Audit logging for all financial transactions and administrative actions
- API rate limiting and DDoS protection

**Scalability Requirements:**

- Horizontal scaling capability to support expansion to other Ghanaian regions
- Database architecture supporting 10,000+ products and 50,000+ customers
- Microservices-ready design for future service decomposition
- CDN integration for static asset delivery optimization

**Usability Requirements:**

- Mobile-first responsive design optimized for smartphones and tablets
- Progressive Web App (PWA) functionality for offline cart management
- Accessibility compliance with large font options and screen reader support
- Intuitive navigation requiring minimal training for new users

### Prioritisation Table - MoSCoW

| Priority        | Feature Category      | Specific Requirements                                                |
| --------------- | --------------------- | -------------------------------------------------------------------- |
| **Must Have**   | Core E-commerce       | Product catalog, shopping cart, payment processing, order management |
| **Must Have**   | Identity Verification | Ghana Card registration and verification system                      |
| **Must Have**   | Credit Management     | Credit account setup, automatic payment deduction, penalty system    |
| **Must Have**   | Delivery System       | Distance-based pricing, delivery assignment, damage reporting        |
| **Must Have**   | Service Booking       | Consultancy services, architectural drawings, quantity surveying     |
| **Should Have** | Enhanced Features     | Product comparison, customer pickup assignment, delivery tips        |
| **Should Have** | Analytics             | Basic reporting dashboards, customer analytics                       |
| **Could Have**  | Advanced Features     | Route optimization, loyalty programs, multi-language support         |
| **Won't Have**  | Future Features       | Mobile app, advanced AI recommendations, international shipping      |

### Preliminary Use-Case Table

| Use Case ID | Use Case Name             | Brief Description                                                 | Primary Actors            |
| ----------- | ------------------------- | ----------------------------------------------------------------- | ------------------------- |
| UC-01       | Register Customer Account | Customer creates account with Ghana Card verification             | Customer, System          |
| UC-02       | Browse Product Catalog    | User searches and filters products by category and specifications | Customer, Contractor      |
| UC-03       | Manage Shopping Cart      | Add/remove products, calculate pricing with bulk discounts        | Customer, Contractor      |
| UC-04       | Process Payment           | Complete order using various payment methods                      | Customer, Payment Gateway |
| UC-05       | Apply for Credit          | B2B customer requests credit facility with account linking        | Contractor, Finance Team  |
| UC-06       | Book Consultancy Service  | Customer schedules professional services                          | Customer, Consultant      |
| UC-07       | Assign Delivery           | System assigns orders to drivers based on location                | Admin, Driver             |
| UC-08       | Report Damage             | Customer reports damaged goods within time window                 | Customer, Admin           |
| UC-09       | Manage Inventory          | Admin updates stock levels and monitors availability              | Warehouse Staff, Admin    |
| UC-10       | Process Credit Payment    | Automated deduction from linked customer accounts                 | System, Payment Gateway   |

---

## 3. Architecture & Components (4 pts)

### System Decomposition

The eBuildify platform employs a **layered architecture** with clear separation of concerns, chosen for its maintainability, testability, and alignment with the 16-week development timeline. The architecture consists of four primary layers:

**Presentation Layer (Frontend):**

- React.js-based Progressive Web Application (PWA) for cross-platform compatibility
- Responsive design optimized for mobile-first usage patterns in Ghana
- Offline-capable shopping cart using service workers and local storage
- Component-based architecture enabling rapid UI development and maintenance

**Business Logic Layer (Backend API):**

- Node.js with Express.js framework providing RESTful API services
- Microservices-oriented design preparing for future horizontal scaling
- JWT-based authentication with role-based access control (RBAC)
- Integration middleware for payment gateways, SMS services, and Ghana Card verification

**Data Access Layer:**

- PostgreSQL database with optimized schema design for ACID compliance
- Redis caching layer for session management and frequently accessed data
- Database migration scripts for version control and deployment consistency
- Connection pooling and query optimization for performance

**Infrastructure Layer:**

- Docker containerization for consistent deployment environments
- CI/CD pipeline using GitHub Actions for automated testing and deployment
- Cloud hosting on DigitalOcean with automated backups and monitoring
- CDN integration for static asset delivery optimization

**Justification for Layered Architecture:**
This approach aligns with Sommerville's recommendations for maintainable software systems (Sommerville, 2016) and supports the compressed Sprint 0 schedule by enabling parallel development across frontend and backend teams. The clear separation allows for independent testing of business logic and facilitates the academic requirement for demonstrable software engineering principles.

### Primary Model: Data-Flow Diagram (Level 0 & Level 1)

**Context Diagram (Level 0):**

```
[Customer] → Product Browsing → [eBuildify System] → Order Fulfillment → [Customer]
[Admin] → Inventory Management → [eBuildify System] → Analytics Reports → [Admin]
[Payment Gateway] → Transaction Processing → [eBuildify System]
[SMS Service] → Notifications → [eBuildify System]
```

**Level 1 DFD - Core Processes:**

**Process 1: User Management**

- Inputs: Registration data, Ghana Card information, authentication requests
- Outputs: User profiles, verification status, access tokens
- Data Stores: Users, User_Profiles, User_Addresses

**Process 2: Product Management**

- Inputs: Product search queries, category filters, inventory updates
- Outputs: Product listings, availability status, pricing information
- Data Stores: Products, Product_Categories, Inventory

**Process 3: Order Processing**

- Inputs: Cart contents, payment information, delivery addresses
- Outputs: Order confirmations, payment receipts, delivery assignments
- Data Stores: Orders, Order_Items, Payments

**Process 4: Credit Management**

- Inputs: Credit applications, payment schedules, account linking data
- Outputs: Credit approvals, automated deductions, payment reminders
- Data Stores: Credit_Accounts, Credit_Transactions, Payment_Reminders

**Process 5: Delivery Management**

- Inputs: Order locations, driver availability, distance calculations
- Outputs: Delivery assignments, route optimizations, status updates
- Data Stores: Delivery_Assignments, Delivery_Zones

### Data Model - Entity Relationship Diagram

The database schema implements a comprehensive relational model supporting all business requirements with strong referential integrity. Key entity relationships include:

**Core Entities:**

- **Users** (1:M) → **Orders**: Customer order history tracking
- **Products** (1:1) → **Inventory**: Real-time stock management
- **Orders** (1:M) → **Order_Items**: Multi-product order support
- **Users** (1:1) → **Credit_Accounts**: B2B credit facility management
- **Orders** (1:1) → **Delivery_Assignments**: Logistics coordination

**Advanced Relationships:**

- **Credit_Accounts** (1:M) → **Credit_Transactions**: Payment tracking with automated deduction support
- **Service_Bookings** (M:1) → **Consultants**: Professional service scheduling
- **Orders** (1:M) → **Damage_Reports**: Time-limited damage reporting system
- **Products** (1:M) → **Inventory_Movements**: Automated stock tracking with audit trail

**Key Design Decisions:**

- UUID primary keys for security and distributed system compatibility
- Computed columns for real-time calculations (available_stock, available_credit)
- JSONB fields for flexible configuration storage (consultant schedules, gateway responses)
- Comprehensive indexing strategy for performance optimization
- Automated triggers for timestamp management and inventory tracking

### Interface Mock-up

The user interface follows Material Design principles with mobile-first responsive design. Key interface components include:

**Customer Interface:**

- **Product Catalog**: Grid view with filter sidebar, search bar, and comparison functionality
- **Shopping Cart**: Persistent cart with offline support, bulk discount indicators, and delivery cost calculator
- **Checkout Flow**: Multi-step process with address selection, payment method choice, and order confirmation
- **Credit Application**: Streamlined form with Ghana Card verification and account linking options

**Admin Dashboard:**

- **Inventory Management**: Real-time stock levels with low-stock alerts and bulk update capabilities
- **Order Processing**: Kanban-style order pipeline with status updates and delivery assignment
- **Credit Dashboard**: Overview of outstanding balances, payment schedules, and automated deduction status
- **Analytics Panel**: Key performance indicators, sales trends, and customer behavior insights

**Mobile Optimization:**

- Touch-friendly interface elements sized appropriately for thumb navigation
- Simplified checkout flow optimized for mobile completion rates
- Offline cart functionality with sync capabilities when connectivity returns
- Progressive Web App features including home screen installation and push notifications

---

## 4. Scope, Deliverables & Plan (2 pts)

### Deliverable List

**Sprint 1 Deliverables (Weeks 1-2):**

- Complete development environment setup with CI/CD pipeline
- Database schema implementation with initial data seeding
- Basic authentication system with Ghana Card verification (Phase 1)
- Project architecture documentation and coding standards
- Brand asset integration and basic UI component library

**Sprint 2 Deliverables (Weeks 3-4):**

- Complete product catalog with search and filtering capabilities
- Customer registration system with Ghana Card verification
- Shopping cart functionality with offline support
- First 20 customers incentive system implementation
- Basic user profile management interface

**Sprint 3 Deliverables (Weeks 5-6):**

- Advanced shopping cart with volume-based pricing calculations
- Product comparison feature with side-by-side specifications
- Order history and one-click reordering functionality
- Third-party pickup assignment system
- Order management workflow implementation

**Sprint 4 Deliverables (Weeks 7-8):**

- Multi-payment gateway integration (MTN, Vodafone, Telecel, Bank Transfer)
- Credit payment system with account linking functionality
- Automated payment deduction and reminder system
- Penalty calculation and fee application system
- Payment reconciliation and reporting tools

**Sprint 5 Deliverables (Weeks 9-10):**

- Service booking interface for consultancy services
- Consultant management system with availability scheduling
- Architectural drawings and quantity surveying request forms
- Service quote generation and approval workflow
- Integration between product and service offerings

**Sprint 6 Deliverables (Weeks 11-12):**

- Distance-based delivery pricing calculator with real-time calculation
- Delivery assignment and tracking system
- Damage reporting system with time-limited window enforcement
- Driver interface for delivery management
- Route optimization and delivery tip functionality

**Sprint 7 Deliverables (Weeks 13-14):**

- Comprehensive admin dashboard with role-based access
- Credit management dashboard with automated monitoring
- Sales analytics and customer behavior reporting
- Inventory management interface with automated alerts
- Service consultant management and performance tracking

**Sprint 8 Deliverables (Weeks 15-16):**

- Complete system integration testing and bug resolution
- Performance optimization and security audit completion
- Production deployment with monitoring and alerting setup
- User acceptance testing and final client approval
- Launch preparation including staff training and support documentation

**Final Demo Deliverable (Week 16):**

- Fully functional eBuildify platform deployed to production environment
- Complete user documentation and admin training materials
- Performance benchmarks and security compliance verification
- Post-launch support plan and maintenance documentation

### Timeline - Mini-Gantt Chart

| Sprint   | Duration | Start Date   | End Date     | Key Milestones              |
| -------- | -------- | ------------ | ------------ | --------------------------- |
| Sprint 1 | 2 weeks  | Aug 28, 2025 | Sep 10, 2025 | Foundation & Authentication |
| Sprint 2 | 2 weeks  | Sep 11, 2025 | Sep 24, 2025 | Core Product Catalog        |
| Sprint 3 | 2 weeks  | Sep 25, 2025 | Oct 8, 2025  | Shopping & Ordering         |
| Sprint 4 | 2 weeks  | Oct 9, 2025  | Oct 22, 2025 | Payment Integration         |
| Sprint 5 | 2 weeks  | Oct 23, 2025 | Nov 5, 2025  | Service Booking             |
| Sprint 6 | 2 weeks  | Nov 6, 2025  | Nov 19, 2025 | Delivery Management         |
| Sprint 7 | 2 weeks  | Nov 20, 2025 | Dec 3, 2025  | Admin & Analytics           |
| Sprint 8 | 2 weeks  | Dec 4, 2025  | Dec 17, 2025 | Integration & Launch        |

**Critical Path Dependencies:**

- Database schema completion (Sprint 1) blocks all subsequent development
- Payment gateway integration (Sprint 4) required before credit system testing
- Service booking system (Sprint 5) depends on user management completion
- Admin dashboards (Sprint 7) require all core functionalities to be complete

### Definition of Done

A deliverable is considered complete when it meets the following criteria:

**Technical Completion:**

- All functional requirements implemented and tested with unit test coverage ≥80%
- Code reviewed by at least one team member using established coding standards
- Integration testing completed with no critical bugs remaining
- Performance benchmarks met (page load times <3 seconds on 3G networks)
- Security testing completed including input validation and access control verification

**Business Validation:**

- Client acceptance criteria validated through demo and feedback sessions
- User acceptance testing completed with real user scenarios
- Documentation updated including API documentation and user guides
- Database migrations tested and rollback procedures verified
- Deployment to staging environment successful with smoke tests passing

**Quality Assurance:**

- Cross-browser compatibility verified on Chrome, Firefox, Safari, and mobile browsers
- Mobile responsiveness tested on various device sizes and operating systems
- Accessibility compliance verified with screen reader testing and keyboard navigation
- Error handling implemented with user-friendly error messages
- Performance monitoring setup with alerting for production issues

**Client Approval:**

- Feature demonstration completed with client stakeholder approval
- Business value delivered and measurable against defined success metrics
- Training materials provided for relevant staff members
- Support documentation updated for ongoing maintenance
- Production deployment checklist completed and approved

---

## 5. Communication, Visibility & Risk (1 pt)

### Client Touch-points

**Weekly Demo Sessions:**

- **Frequency:** Every Friday at 3:00 PM GMT via Zoom
- **Duration:** 1 hour including demo presentation and Q&A session
- **Participants:** Client stakeholders, Scrum Master, Product Owner, and relevant development team members
- **Agenda:** Sprint deliverable demonstration, upcoming sprint preview, client feedback collection, and issue resolution discussion

**Client Communication Channels:**

- **Primary:** WhatsApp Business group for daily updates and quick clarifications
- **Secondary:** Email for formal communications, documentation sharing, and change requests
- **Escalation:** Direct phone contact for urgent issues requiring immediate attention
- **Documentation Portal:** Shared Google Drive folder for project artifacts, meeting minutes, and progress reports

**Monthly Summary Reports:**

- Comprehensive progress report including completed features, upcoming milestones, budget utilization, and risk assessment
- Performance metrics dashboard showing user adoption, system performance, and business impact
- Client satisfaction survey and feedback compilation for continuous improvement

### Team Communications

**Daily Stand-up Meetings:**

- **Schedule:** Monday, Wednesday, Friday at 9:00 AM GMT (15-minute duration)
- **Format:** Each team member reports on previous work completed, current day priorities, and any blockers requiring assistance
- **Tool:** Microsoft Teams with screen sharing for quick demonstrations
- **Follow-up:** Blocker resolution sessions scheduled immediately after stand-ups when needed

**Sprint Planning & Reviews:**

- **Sprint Planning:** 2-hour session at the beginning of each sprint for backlog refinement and task assignment
- **Sprint Review:** 1-hour session at sprint end for deliverable demonstration and retrospective discussion
- **Sprint Retrospective:** 30-minute team-only session for process improvement identification

**Project Board Management:**

- **Tool:** GitHub Projects with automated workflow integration
- **Structure:** Backlog, Sprint Planning, In Progress, Code Review, Testing, Done columns
- **Updates:** Real-time task status updates with automated notifications for assigned team members
- **Reporting:** Weekly velocity tracking and burndown chart generation for progress monitoring

### Risk Log (Excerpt)

| Risk ID | Risk Description                                    | Probability  | Impact | Risk Score | Mitigation Strategy                                                                                                                              |
| ------- | --------------------------------------------------- | ------------ | ------ | ---------- | ------------------------------------------------------------------------------------------------------------------------------------------------ |
| R-01    | **Ghana Card API Integration Delays**               | High (70%)   | High   | 21         | Implement basic verification system initially; plan government partnership for advanced integration; create fallback manual verification process |
| R-02    | **Multi-Payment Gateway Integration Complexity**    | Medium (50%) | High   | 15         | Prioritize Flutterwave as primary gateway; implement secondary gateways incrementally; establish sandbox testing environment early               |
| R-03    | **Credit System Automation Challenges**             | Medium (60%) | Medium | 12         | Start with manual oversight and approval; gradually automate based on business rules; implement comprehensive audit logging                      |
| R-04    | **Team Member Availability During Academic Period** | High (80%)   | Medium | 16         | Cross-train team members on critical components; implement comprehensive documentation; establish backup resource allocation                     |
| R-05    | **Client Requirements Changes**                     | Medium (40%) | High   | 12         | Implement formal change request process; maintain flexible architecture; allocate 15% buffer time per sprint                                     |
| R-06    | **Third-Party Service Dependencies**                | Medium (50%) | Medium | 10         | Identify alternative service providers; implement circuit breaker patterns; create offline fallback mechanisms                                   |
| R-07    | **Database Performance Under Load**                 | Low (30%)    | High   | 9          | Implement comprehensive indexing strategy; plan database optimization sprints; establish performance monitoring from day one                     |
| R-08    | **Mobile Network Connectivity Issues**              | High (90%)   | Low    | 9          | Implement robust offline functionality; optimize for low-bandwidth scenarios; provide clear connectivity status indicators                       |

**Risk Monitoring Process:**

- Weekly risk assessment during sprint reviews with probability and impact updates
- Monthly risk register review with client stakeholders for transparency and collaborative mitigation
- Automated monitoring setup for technical risks including performance thresholds and availability metrics
- Escalation procedures defined for high-impact risks requiring immediate client notification and decision-making

---

## 6. Development Process & Compliance (1 pt)

### Chosen Process: Scrum with 2-Week Sprints

**Process Selection Justification:**
We have selected Scrum methodology with 2-week sprint cycles, aligned with Pressman's recommendations for iterative development in complex projects (Pressman & Maxim, 2020). This approach provides optimal balance between delivery frequency and development depth, allowing for meaningful progress demonstration while maintaining client engagement throughout the 16-week timeline.

**Scrum Implementation Details:**

- **Sprint Duration:** 2 weeks providing sufficient time for feature completion while enabling rapid feedback cycles
- **Team Composition:** 7-person cross-functional team with defined roles including Scrum Master, Product Owner, developers, and QA specialist
- **Ceremonies:** Daily stand-ups (3x per week), sprint planning (2 hours), sprint review (1 hour), and retrospective (30 minutes)
- **Artifacts:** Product backlog maintained in GitHub Projects, sprint backlog with detailed user stories, and potentially shippable increment each sprint

**Adaptation for Academic Context:**
Given the compressed timeline and academic requirements, we implement modified Scrum practices including enhanced documentation requirements, mandatory code reviews for learning purposes, and structured knowledge transfer sessions between team members to ensure collective understanding of all system components.

### DevSecOps Guard-rails

**Source Code Management:**

- **Branch Protection Rules:** Master branch requires pull request reviews from at least two team members before merging
- **Code Review Process:** Mandatory peer review using GitHub pull request workflow with automated conflict detection
- **Merge Strategy:** Squash and merge policy maintaining clean commit history and facilitating easy rollbacks

**Continuous Integration Pipeline:**

- **Automated Testing:** Unit tests must achieve minimum 80% code coverage with automated test execution on every commit
- **Build Automation:** Docker-based build process ensuring consistent environment across development, staging, and production
- **Quality Gates:** SonarQube integration for code quality metrics including maintainability, reliability, and security vulnerability detection

**Security Integration:**

- **Secret Scanning:** GitHub Advanced Security enabled for automatic detection of exposed API keys, passwords, and certificates
- **Dependency Vulnerability Scanning:** Automated dependency checking using npm audit and GitHub Dependabot for known security vulnerabilities
- **Static Application Security Testing (SAST):** CodeQL analysis integrated into CI pipeline for early security issue detection
- **Infrastructure Security:** Docker image scanning using Trivy for container vulnerability assessment

**Deployment Automation:**

- **Environment Consistency:** Infrastructure as Code using Docker Compose for development and Kubernetes for production deployment
- **Database Migrations:** Automated migration scripts with rollback capabilities ensuring database schema consistency
- **Zero-Downtime Deployment:** Blue-green deployment strategy minimizing service interruption during releases

### Gen-AI Usage Statement

**Permissible AI Usage:**

- **Code Boilerplate Generation:** AI tools (GitHub Copilot, ChatGPT) permitted for generating standard code patterns, utility functions, and basic API endpoint structures
- **Documentation Assistance:** AI-powered tools allowed for generating initial documentation templates, API documentation, and code comments
- **Testing Support:** AI assistance acceptable for generating unit test cases and test data scenarios
- **Research and Learning:** AI tools encouraged for exploring best practices, troubleshooting technical issues, and understanding new technologies

**Restricted AI Usage:**

- **Architecture Decisions:** Core architectural choices must be human-made with proper justification and understanding
- **Business Logic Implementation:** Critical business rules and algorithms must be manually developed to ensure full comprehension
- **Security-Related Code:** Authentication, authorization, and payment processing code requires manual implementation with security review
- **Database Design:** Schema design and query optimization must demonstrate human understanding of relational database principles

**Auditing and Accountability Rules:**

- **Code Attribution:** All AI-generated code must be clearly marked with comments indicating AI assistance and the specific tool used
- **Peer Review Requirement:** AI-generated code requires additional scrutiny during code review with explicit verification of correctness and security
- **Knowledge Verification:** Every team member must be able to explain any AI-generated code in their assigned modules during sprint reviews
- **Documentation Requirement:** Decision log maintained documenting when AI tools were used, why they were chosen, and how the output was validated

**Learning Objectives Compliance:**
This policy ensures that AI tools enhance rather than replace learning objectives by requiring human oversight, understanding, and validation of all generated content. Team members must demonstrate comprehension of software engineering principles regardless of AI assistance, maintaining the educational value of the project while leveraging modern development tools effectively.

---

## References

Kendall, K. E., Kendall, J. E., & Avison, D. (2019). _Systems Analysis and Design_ (9th ed.). Pearson Education Limited.

Pressman, R. S., & Maxim, B. R. (2020). _Software Engineering: A Practitioner's Approach_ (9th ed.). McGraw-Hill Education.

Sommerville, I. (2016). _Software Engineering_ (10th ed.). Pearson Education Limited.

---

**Document Information:**

- **Total Word Count:** 4,487 words
- **Page Count:** 10 pages
- **Team Contact:** buildtech.solutions@university.edu.gh
- **Version:** 1.0 - Final Submission
