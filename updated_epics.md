# Merged Epics & Prioritized User Stories (with MoSCoW + INVEST principles)

**Platform: eBuildify | Team: BuildTech Solution | Client: VillageTech**

## EPIC 1: Order Management System (Must Have)| Client: VillageTech

**Goal:** Seamless product discovery → checkout with enhanced features

| Priority         | User Story                                                                                                     | Acceptance Criteria                                                                             |
| ---------------- | -------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------- |
| Must             | As a customer, I want to browse products by category with filters so I can find materials fast.                | Filter by ≥3 attributes, intuitive UI (Jumia-style).                                            |
| Must             | As a contractor, I want tiered bulk pricing applied automatically so I get volume discounts.                   | **UPDATED**: 1.5% discount triggers for ≥100 units of cement/iron rods/quarter rods.            |
| Must             | As any user, I want my cart saved offline so I can continue ordering in low-connectivity areas.                | Cart persists after refresh, stores locally when offline.                                       |
| Should           | As a customer, I want to search materials by brand or type so I don't scroll endlessly.                        | Search bar + auto-suggestions with keywords.                                                    |
| Should           | As a user, I want product comparison (e.g., cement A vs B) so I can choose wisely.                             | Compare at least 3 items with side-by-side specs.                                               |
| Must             | As a user, I want one-click reordering from order history so I save time.                                      | Reorder replicates previous cart in ≤3 clicks.                                                  |
| **NEW - Should** | **As a customer, I want to assign someone else to pick up my order so I don't have to be physically present.** | **Pickup person details captured, ID verification required, SMS notification to both parties.** |

## EPIC 2: Payment & Checkout (Must Have)

**Goal:** Secure, flexible transactions with advanced credit management

| Priority       | User Story                                                                                              | Acceptance Criteria                                                                                                     |
| -------------- | ------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------- |
| Must           | As a user, I want to pay via MTN MoMo/Vodafone/Telecel Cash so I can use my preferred method.           | **UPDATED**: Flutterwave integration for MTN, Vodafone, Telecel; success/failure callback.                              |
| Must           | As a B2B client, I want to request credit terms at checkout so I can delay payment.                     | "Request Credit" opens flow requiring admin approval + account details.                                                 |
| **NEW - Must** | **As a credit customer, I want to set up automatic payment from my account so I don't miss due dates.** | **Account linking (bank/MoMo/Telecel/virtual card), payment schedule setup, reminder notifications 3 days before due.** |
| Should         | As a COD customer, I want to input cash amount before delivery so I prepare exact change.               | Amount field editable on checkout → visible to assigned driver.                                                         |
| Could          | As a returning user, I want saved payment options so I check out faster.                                | Show saved card/MoMo on next order.                                                                                     |
| **NEW - Must** | **As the system, I must apply 50% additional fee to defaulted credit purchases to recover costs.**      | **Automatic fee calculation, client notification, updated invoice generation.**                                         |
| **NEW - Must** | **As the system, I must apply 2% penalty for late credit payments after multiple notifications.**       | **Penalty calculation after 3 SMS/email reminders, automatic account deduction.**                                       |

## EPIC 3: Inventory Sync & Management (Must Have)

**Goal:** Avoid overselling, ensure accurate stock with service inventory

| Priority         | User Story                                                                                                         | Acceptance Criteria                                                      |
| ---------------- | ------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------ |
| Must             | As the system, I must reserve stock during checkout for 15 minutes to prevent overselling.                         | Temporary stock hold + rollback on failure.                              |
| Must             | As warehouse staff, I want stock alerts (SMS/email) when cement < 100 bags so we can replenish.                    | Configurable stock thresholds trigger alerts.                            |
| Should           | As an admin, I want to override stock manually if sync fails so we keep selling in emergencies.                    | "Edit Stock" UI with audit log + reason entry.                           |
| Could            | As the system, I want stock synced with Google Sheets hourly so inventory stays up-to-date.                        | Scheduled sync process with retry on failure.                            |
| **NEW - Should** | **As an admin, I want to manage service availability (consultancy, rentals) so customers can book appropriately.** | **Service calendar, consultant availability, booking slots management.** |

## EPIC 4: Delivery Logistics & Pricing (Should Have)

**Goal:** Optimize fulfillment with distance-based pricing and flexible pickup

| Priority         | User Story                                                                                                  | Acceptance Criteria                                                                                           |
| ---------------- | ----------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------- |
| Should           | As a dispatch manager, I want to assign orders to drivers by zone to reduce travel times.                   | Drag-and-drop order assignment on map or dropdown.                                                            |
| Should           | As a customer, I want real-time delivery status with SMS updates so I can plan accordingly.                 | Status updates (Pending, Out, Delivered) trigger SMS + dashboard update.                                      |
| **NEW - Must**   | **As a customer, I want to know delivery costs upfront based on my location so I can budget accurately.**   | **Distance calculator integration, transparent pricing display at checkout, cost breakdown.**                 |
| **NEW - Should** | **As a customer, I want to tip delivery drivers for exceptional service so I can show appreciation.**       | **Tip option at delivery confirmation, direct payment to driver account, rating system.**                     |
| Could            | As a driver, I want to report damage offline so I can sync when back online.                                | Damage logs stored locally until signal is restored.                                                          |
| Could            | As a user, I want to choose delivery window (AM/PM) so I'm available to receive materials.                  | Two-slot preference selector at checkout.                                                                     |
| **NEW - Must**   | **As a customer, I must report damaged goods within 1-2 hours of delivery to be eligible for replacement.** | **Time-stamped delivery confirmation, countdown timer for damage reports, automatic rejection after window.** |

## EPIC 5: B2B Contractor Portal & Services (Must Have)

**Goal:** Business-focused workflows with professional services

| Priority         | User Story                                                                                                                                      | Acceptance Criteria                                                                              |
| ---------------- | ----------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------ |
| Must             | As a contractor, I want to tag orders by project (e.g., Site A, Site B) so I track budgets.                                                     | Add project label to order form → searchable in history.                                         |
| Must             | As an admin, I need to process VAT-exemption approvals so compliant contractors get tax relief.                                                 | Document upload + verification → approval dashboard for finance.                                 |
| Should           | As a contractor, I want multi-site delivery options so I can split orders efficiently.                                                          | Option to assign quantities to different addresses.                                              |
| **NEW - Must**   | **As a customer, I want to book consultancy services (architectural drawings, quantity surveying, supervision) so I get professional support.** | **Service booking interface, consultant calendar, project requirements form, quote generation.** |
| **NEW - Should** | **As a contractor, I want full building contract services so I can outsource entire projects.**                                                 | **Contract service request form, project scope definition, timeline and cost estimation.**       |

## EPIC 6: Customer Registration & Verification (Must Have) - **NEW EPIC**

**Goal:** Secure customer onboarding with identity verification

| Priority         | User Story                                                                                                          | Acceptance Criteria                                                                           |
| ---------------- | ------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------- |
| **NEW - Must**   | **As a new customer, I must provide Ghana Card details during registration so the company can verify my identity.** | **Ghana Card number validation, photo upload, address verification, secure data storage.**    |
| **NEW - Should** | **As a verified customer, I want to receive birthday and holiday greetings with special offers so I feel valued.**  | **Automated birthday/holiday detection, personalized messages, promotional code generation.** |
| **NEW - Must**   | **As one of the first 20 customers, I want special incentive packages so I'm rewarded for early adoption.**         | **Customer counter, special discount codes, exclusive offers, priority support access.**      |

## EPIC 7: Admin, Analytics & Control (Must Have)

**Goal:** Admin oversight + operational insight with enhanced financial controls

| Priority         | User Story                                                                                      | Acceptance Criteria                                                                            |
| ---------------- | ----------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------- |
| Must             | As finance, I want only my role to refund payments so I control financial risks.                | Role-based access → "Issue Refund" visible only to finance team.                               |
| Should           | As CEO, I want a dashboard showing orders by product & category so I can monitor cement sales.  | Daily/weekly chart views with filters.                                                         |
| Could            | As admin, I want to track order activity logs by user so I can audit system use.                | Logs by user ID, action type, timestamp.                                                       |
| **NEW - Must**   | **As finance, I want automated credit payment tracking so I can monitor outstanding debts.**    | **Credit dashboard, payment due alerts, automatic deduction logs, overdue reports.**           |
| **NEW - Should** | **As admin, I want to manage service consultant schedules so I can optimize service delivery.** | **Consultant calendar management, booking conflicts prevention, service performance metrics.** |

## EPIC 8: Technical & Compliance (Must Have)

**Goal:** Backend quality, legal & security compliance with Ghana Card integration

| Priority         | User Story                                                                                                                                          | Acceptance Criteria                                                                                   |
| ---------------- | --------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------- |
| Must             | As the system, I must comply with PCI-DSS for card payments to prevent data breaches.                                                               | External audit passed, stored tokenization, no card storage.                                          |
| Must             | As a user, I want cement batch numbers on invoices so I meet safety compliance.                                                                     | Batch ID shown in invoice PDF.                                                                        |
| Should           | As a developer, I want test coverage ≥80% so we reduce bugs.                                                                                        | Unit tests auto-run on push; coverage report included.                                                |
| **NEW - Must**   | **As the system, I must securely store Ghana Card data in compliance with data protection laws.**                                                   | **Encrypted storage, access logging, GDPR-compliant data handling, retention policies.**              |
| **NEW - Should** | **As the system, I must integrate with multiple payment providers (MTN, Vodafone, Telecel, banks, virtual cards) for automatic credit deductions.** | **Multi-provider API integration, fallback mechanisms, transaction logging, reconciliation reports.** |

## **NEW EPIC 9: Rental & Additional Services (Could Have)**

**Goal:** Expand service offerings beyond product sales

| Priority         | User Story                                                                                                                  | Acceptance Criteria                                                                                         |
| ---------------- | --------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------- |
| **NEW - Could**  | **As a customer, I want to rent wheelbarrows and construction equipment so I can save on purchase costs.**                  | **Rental inventory management, booking calendar, deposit handling, return tracking.**                       |
| **NEW - Could**  | **As a customer, I want to hire professional builders through the platform so I can get complete construction services.**   | **Builder profiles, skill verification, project matching, contract management.**                            |
| **NEW - Should** | **As a customer, I want to evaluate land productivity and material requirements for my project so I can plan effectively.** | **Project assessment form, site visit scheduling, evaluation report generation, material recommendations.** |

---

## **Priority Summary for MVP (Must Have Features):**

1. **Enhanced Product Catalog** (with services)
2. **Advanced Payment System** (credit management, multiple providers)
3. **Customer Verification** (Ghana Card integration)
4. **Delivery Cost Calculator** (distance-based pricing)
5. **Damage Reporting** (time-limited window)
6. **Credit Payment Automation** (with penalties and fees)
7. **Service Booking System** (consultancy services)
8. **Customer Incentives** (first 20 customers program)
9. **Pickup Assignment** (third-party pickup option)

## **Phase 2 Features (Should/Could Have):**

1. **Delivery Tips & Rating System**
2. **Advanced Service Management**
3. **Rental Equipment System**
4. **Builder Marketplace**
5. **Advanced Analytics Dashboard**
6. **Multi-language Support** (Twi)
7. **GPS Vehicle Tracking**
