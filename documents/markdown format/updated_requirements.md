# Delivery Platform for Building Materials – Requirements Document (Client Response)

**Platform Name: eBuildify**  
**Team: BuildTech Solution**
**Client: Sol Little By Little Enterprises**

## I. Business Goals & Vision

### Core Purpose:

The platform aims to increase sales, improve brand visibility, and introduce process automation for smoother customer experience and operations.

### Primary Customers:

Both B2B and B2C, including:
• Hardware shops
• Construction companies
• Contractors
• Individual builders and homeowners

### Current Pain Points:

• Manual order processing (calls/WhatsApp) causing errors and delays
• Inventory discrepancies due to lack of real-time updates
• Inefficient delivery scheduling
• No analytics or centralized customer history

### Order Process (Current):

• Customers call or message to place orders
• Orders are manually recorded and processed
• Payment is typically upon delivery
• Delivery dispatch done via phone coordination

### Top Competitors:

1. BuildMart GH – Admire their product filtering and clean UX
2. Tonaton Pro – Good visibility but lacks order flow transparency
3. BuildersHub – Strong catalogue but poor customer support

### Post-Launch Success Metrics:

• 30% increase in monthly sales within 6 months
• 80% of orders made directly via the website
• Improved order fulfillment time by 40%
• Customers able to reorder in under 2 minutes

## II. Product & Ordering Workflow

### Complete Product Catalog:

**Construction Materials:**

- Plumbing materials
- Oil paint (all colors)
- Cement
- Emulsion paint (all colors)
- Plywood
- Mason tools
- C.button
- Carpentry tools
- Nails (all kinds)
- Roofing sheet (Aluzinc, 5star, westle, colored etc)
- Square mesh
- Plastic chairs
- Wire Mesh 3" & 4"
- Protective clothes
- Carpet (Foam & Rubber)
- Welder tools
- Window net (blue & black)
- Wheelbarrow (for rent & sale)
- Doors
- Door keys

**Services:**

- Consultancy services on building materials selection
- Land productivity assessment
- Quantity surveying
- Architectural drawings
- Material evaluation for projects
- Construction supervision
- Full building contracts for organizations, individuals, and international bodies
- Construction equipment rental services
- Professional builders services

### Order Lifecycle (Ideal):

Browse → Add to Cart → Checkout → Payment → Assign Delivery → Confirmation → Customer notified

### Delivery Rules:

• Delivery within Accra: same-day (if order is before noon)
• Outside Accra: 24–48 hours
• Delivery radius: 100km max
• **NEW**: Delivery costs calculated based on distance/location
• **NEW**: Option for customer pickup by designated person when buyer unavailable

### Payment Methods:

• Mobile Money (MTN, Vodafone)
• Telecel Cash
• Bank Transfer
• Cash on Delivery
• Credit for verified B2B clients
• Virtual cards

### **NEW**: Credit Payment System:

• Credit clients must provide account details for automatic deduction
• Clients set payment timeframe for debt settlement
• Reminder notifications sent before due date
• Automatic deduction from specified account (bank, MoMo, Telecel, virtual cards)
• **50% additional fee** applied to credit purchases if payment defaults occur
• **2% penalty fee** for late payments after multiple notifications
• Ghana Card details required for registration and client verification

### Product Mixing:

Yes – common to mix cement, iron rods, binding wire, etc.

### Real-Time Stock Visibility:

Yes – very important to avoid overselling

### Volume-Based Pricing:

**UPDATED**:
• Buy ≥100 units of cement, iron rods, or quarter rods → get **1.5% discount**
• Verified contractors get loyalty pricing

### **NEW**: Customer Incentive Programs:

• Special incentive packages for first 20 website customers
• Bonus/tip feature allowing customers to reward exceptional delivery service
• Birthday and holiday greetings with promotional offers

### Product Conditions:

Yes. Example:
• Cement: minimum order 10 bags
• Iron rods: sold in bundles of 10+

### **NEW**: Damage Reporting Policy:

• Customers must report damaged goods within **1-2 hours** of delivery
• Complaints outside this timeframe will not be accepted
• Clear time-stamped delivery confirmation required

## III. Inventory, Delivery & Logistics

### Current Inventory System:

Excel + manual stock checks in warehouse

### Stock Management in Website:

Prefer website to sync with our internal Google Sheet / future ERP, but be able to manage basic inventory on its own if integration fails

### Delivery Handling:

• Combination of in-house drivers and 3rd-party delivery vans
• Dispatch managed manually via calls
• **NEW**: Distance-based delivery pricing structure

### Delivery Route Optimization:

Yes – system should assign deliveries by location and suggest optimal routes

### Order Fulfillment Tracking:

Yes – platform should show status: Pending → Out for Delivery → Delivered
Also notify if delayed (e.g., rain or road issues)

### Returns/Damages Handling:

Customers should be able to log return requests online within the 1-2 hour window.
• Delivery agent marks item as "damaged" in app
• Admin approves replacement or refund

## IV. Users & Roles

### User Types:

• Retail Customers
• Business Clients (Contractors)
• Warehouse Staff
• Delivery Drivers
• Admins (Sales, Finance, Dispatch Manager)
• **NEW**: Service Consultants (for architectural and consultancy services)

### Special Dashboards:

• Contractors: project-based ordering, ability to request credit
• Admins: role-based actions (e.g., only Finance can issue refunds)
• **NEW**: Consultancy booking interface for service requests

### Customer Convenience:

• View order history
• Save favorite products
• One-click reorder option
• **NEW**: Customer pickup assignment feature
• **NEW**: Ghana Card registration for identity verification

## V. Integrations & Ecosystem

### Tools to Integrate:

• Inventory: Currently Google Sheets (for now)
• Accounting: Planning to use Zoho Books or QuickBooks in the future

### Payment Gateways:

• Flutterwave preferred
• MTN MoMo API
• Vodafone Cash API
• **NEW**: Telecel Cash integration
• Visa/Mastercard for future
• **NEW**: Virtual card payment support

### Customer Notifications:

Yes – both SMS and Email for:
• Order confirmation
• Delivery updates
• Promotions
• **NEW**: Credit payment reminders
• **NEW**: Birthday and holiday greetings
• **NEW**: Late payment penalties notification

### GPS & Check-Ins:

Yes – delivery agents should check in via mobile app
Optional: GPS tracking of delivery vans in future version

### Data Migration:

Yes – historical customer and order data from spreadsheets (~2000 records)

## VI. Legal, Compliance & Constraints

### Regulatory Documents:

• Safety data sheets for certain materials (e.g., adhesives, chemicals)
• Cement batch number visibility
• **NEW**: Ghana Card verification for registration

### Delivery Zone Constraints:

• Some roads in inner cities restrict vehicles over 3 tons
• Platform should allow input of weight for route checks

### Tax Rules:

• VAT varies by product
• Contractors may be VAT-exempt with valid certificate

### Internet Limitations:

Yes – some users may have poor signal.
Mobile app/website should allow offline cart caching

## VII. UI/UX & Design Expectations

### Brand Assets:

Yes – logo, color palette (blue/yellow theme), and brand font to be supplied

### Design Inspiration:

• Jumia Ghana (for flow and mobile responsiveness)
• Glovo App (for simple delivery tracking)

### Platform Type:

• Mobile-first design essential
• PWA preferred for offline functionality

### Accessibility:

Yes – large font toggle, basic screen reader support

### Languages:

• English (primary)
• Add Twi in Phase 2

## VIII. Non-Functional Requirements

### Peak Load:

• Expect 500+ concurrent users during monthly promotions or in rainy season

### Performance Expectation:

• Product & checkout pages should load in under 3 seconds on 3G

### Security Concerns:

• PCI-DSS compliant payment system
• User roles with strict permissions
• Order logs and admin audit trails
• **NEW**: Ghana Card data protection compliance

### Scalability:

Yes – plan to expand to other regions in 6–12 months
• More warehouses
• Larger product catalogue
• More delivery agents

### Offline Fallback:

Yes – important for areas with poor connection

## IX. Project Scope, Timeline & Budget

### Go-Live Date:

Target: October 1st
Reason: Beginning of high construction season & investor review in mid-October

### Budget Range:

₵35,000–₵50,000 (GHS) for MVP
Further upgrades post-launch

### Must-Have Features:

• Product catalog (including services)
• Online ordering + payment
• Stock sync
• Delivery dispatch system
• Admin dashboards
• Notifications
• **NEW**: Credit management system
• **NEW**: Consultancy booking system
• **NEW**: Ghana Card verification

### Nice-to-Have:

• Route optimization
• Loyalty pricing
• GPS vehicle tracking
• Twi language support
• **NEW**: Customer pickup coordination
• **NEW**: Delivery tip/bonus feature

### **NEW**: Additional Features:

• Distance-based delivery pricing
• Automated credit payment system
• Customer incentive programs
• Damage reporting time limits
• Service consultation booking

### Main Point of Contact:

Mr. Enoch Amarteifio – Product Lead / Client Rep
Email: [placeholder]
Phone: [placeholder]

### Review Meetings:

Bi-weekly sprint reviews via Zoom

### Project Success Metrics (KPIs):

• Number of completed orders via platform
• Decrease in order processing time
• Customer repeat rate
• Error rate in deliveries
• User satisfaction (via feedback form)
• **NEW**: Credit payment recovery rate
• **NEW**: Service consultation bookings
• **NEW**: Customer pickup success rate
