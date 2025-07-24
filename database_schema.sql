-- eBuildify Database Schema (PostgreSQL)
-- Generated for BuildTech Solutions
-- Database: ebuildify_db

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =============================================
-- USER MANAGEMENT & AUTHENTICATION
-- =============================================

CREATE TABLE users (
    user_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    phone_number VARCHAR(20) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    ghana_card_number VARCHAR(20) UNIQUE,
    ghana_card_image_url TEXT,
    ghana_card_verified BOOLEAN DEFAULT FALSE,
    user_type VARCHAR(20) NOT NULL CHECK (user_type IN ('customer', 'contractor', 'admin', 'driver', 'consultant', 'warehouse_staff', 'finance')),
    is_active BOOLEAN DEFAULT TRUE,
    email_verified_at TIMESTAMP,
    phone_verified_at TIMESTAMP,
    date_of_birth DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login_at TIMESTAMP
);

CREATE TABLE user_addresses (
    address_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    address_line_1 VARCHAR(255) NOT NULL,
    address_line_2 VARCHAR(255),
    city VARCHAR(100) NOT NULL,
    region VARCHAR(100) NOT NULL,
    postal_code VARCHAR(20),
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    is_primary BOOLEAN DEFAULT FALSE,
    address_type VARCHAR(20) NOT NULL CHECK (address_type IN ('home', 'office', 'site', 'warehouse')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE user_profiles (
    profile_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID UNIQUE NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    company_name VARCHAR(255),
    business_registration_number VARCHAR(50),
    vat_number VARCHAR(50),
    vat_exempt BOOLEAN DEFAULT FALSE,
    vat_exemption_certificate_url TEXT,
    business_description TEXT,
    customer_tier VARCHAR(20) DEFAULT 'bronze' CHECK (customer_tier IN ('bronze', 'silver', 'gold', 'platinum')),
    is_first_20_customer BOOLEAN DEFAULT FALSE,
    first_20_registered_at TIMESTAMP,
    credit_limit DECIMAL(12, 2) DEFAULT 0.00,
    loyalty_points INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =============================================
-- PRODUCT MANAGEMENT
-- =============================================

CREATE TABLE product_categories (
    category_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    category_name VARCHAR(100) UNIQUE NOT NULL,
    category_slug VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    icon_url TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE products (
    product_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    category_id UUID NOT NULL REFERENCES product_categories(category_id),
    product_name VARCHAR(255) NOT NULL,
    product_slug VARCHAR(255) UNIQUE NOT NULL,
    sku VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    specifications TEXT,
    unit_price DECIMAL(10, 2) NOT NULL,
    unit_of_measure VARCHAR(20) NOT NULL DEFAULT 'piece',
    minimum_order_quantity INTEGER DEFAULT 1,
    is_bulk_item BOOLEAN DEFAULT FALSE,
    bulk_threshold INTEGER DEFAULT 100,
    bulk_discount_percentage DECIMAL(5, 2) DEFAULT 1.50,
    brand VARCHAR(100),
    batch_number VARCHAR(100),
    safety_data_sheet_url TEXT,
    requires_special_handling BOOLEAN DEFAULT FALSE,
    weight_kg DECIMAL(8, 2),
    dimensions VARCHAR(100),
    is_active BOOLEAN DEFAULT TRUE,
    is_featured BOOLEAN DEFAULT FALSE,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE product_images (
    image_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    product_id UUID NOT NULL REFERENCES products(product_id) ON DELETE CASCADE,
    image_url TEXT NOT NULL,
    alt_text VARCHAR(255),
    is_primary BOOLEAN DEFAULT FALSE,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE inventory (
    inventory_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    product_id UUID UNIQUE NOT NULL REFERENCES products(product_id) ON DELETE CASCADE,
    current_stock INTEGER NOT NULL DEFAULT 0,
    reserved_stock INTEGER NOT NULL DEFAULT 0,
    available_stock INTEGER GENERATED ALWAYS AS (current_stock - reserved_stock) STORED,
    reorder_level INTEGER DEFAULT 10,
    maximum_stock INTEGER DEFAULT 1000,
    cost_price DECIMAL(10, 2),
    supplier_info TEXT,
    last_restocked_date DATE,
    warehouse_location VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE inventory_movements (
    movement_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    product_id UUID NOT NULL REFERENCES products(product_id),
    user_id UUID REFERENCES users(user_id),
    movement_type VARCHAR(20) NOT NULL CHECK (movement_type IN ('in', 'out', 'adjustment', 'reservation', 'release')),
    quantity INTEGER NOT NULL,
    previous_stock INTEGER NOT NULL,
    new_stock INTEGER NOT NULL,
    reference_number VARCHAR(100),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =============================================
-- SERVICES MANAGEMENT
-- =============================================

CREATE TABLE services (
    service_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    service_name VARCHAR(255) NOT NULL,
    service_slug VARCHAR(255) UNIQUE NOT NULL,
    description TEXT,
    service_type VARCHAR(30) NOT NULL CHECK (service_type IN ('consultancy', 'architectural', 'evaluation', 'supervision', 'construction', 'rental')),
    base_price DECIMAL(10, 2) NOT NULL,
    pricing_unit VARCHAR(20) NOT NULL CHECK (pricing_unit IN ('hourly', 'daily', 'project', 'item')),
    estimated_duration_hours INTEGER,
    requires_site_visit BOOLEAN DEFAULT FALSE,
    requirements TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE consultants (
    consultant_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID UNIQUE NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    specialization VARCHAR(255) NOT NULL,
    qualifications TEXT,
    hourly_rate DECIMAL(8, 2) NOT NULL,
    is_available BOOLEAN DEFAULT TRUE,
    availability_schedule JSONB, -- Store weekly schedule as JSON
    max_concurrent_projects INTEGER DEFAULT 3,
    rating DECIMAL(3, 2) DEFAULT 0.00,
    total_projects_completed INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE service_bookings (
    booking_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    service_id UUID NOT NULL REFERENCES services(service_id),
    customer_id UUID NOT NULL REFERENCES users(user_id),
    consultant_id UUID REFERENCES consultants(consultant_id),
    project_name VARCHAR(255) NOT NULL,
    project_description TEXT,
    requirements TEXT,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'in_progress', 'completed', 'cancelled')),
    scheduled_start TIMESTAMP,
    scheduled_end TIMESTAMP,
    actual_start TIMESTAMP,
    actual_end TIMESTAMP,
    quoted_price DECIMAL(10, 2),
    final_price DECIMAL(10, 2),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =============================================
-- ORDER MANAGEMENT
-- =============================================

CREATE TABLE orders (
    order_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_number VARCHAR(20) UNIQUE NOT NULL,
    customer_id UUID NOT NULL REFERENCES users(user_id),
    assigned_driver_id UUID REFERENCES users(user_id),
    subtotal DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    delivery_fee DECIMAL(8, 2) NOT NULL DEFAULT 0.00,
    discount_amount DECIMAL(10, 2) DEFAULT 0.00,
    tax_amount DECIMAL(10, 2) DEFAULT 0.00,
    tip_amount DECIMAL(8, 2) DEFAULT 0.00,
    total_amount DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    order_status VARCHAR(20) DEFAULT 'pending' CHECK (order_status IN ('pending', 'confirmed', 'processing', 'dispatched', 'delivered', 'cancelled', 'returned')),
    payment_status VARCHAR(20) DEFAULT 'pending' CHECK (payment_status IN ('pending', 'paid', 'failed', 'refunded', 'partial')),
    project_tag VARCHAR(255),
    delivery_instructions TEXT,
    delivery_date DATE,
    delivery_time_slot VARCHAR(20) CHECK (delivery_time_slot IN ('morning', 'afternoon', 'evening', 'anytime')),
    pickup_person_name VARCHAR(255),
    pickup_person_phone VARCHAR(20),
    pickup_person_id VARCHAR(50),
    is_pickup_order BOOLEAN DEFAULT FALSE,
    order_placed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    confirmed_at TIMESTAMP,
    dispatched_at TIMESTAMP,
    delivered_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE order_items (
    order_item_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(product_id),
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10, 2) NOT NULL,
    discount_percentage DECIMAL(5, 2) DEFAULT 0.00,
    line_total DECIMAL(10, 2) NOT NULL,
    item_notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE order_addresses (
    order_address_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    address_type VARCHAR(20) NOT NULL CHECK (address_type IN ('billing', 'delivery')),
    address_line_1 VARCHAR(255) NOT NULL,
    address_line_2 VARCHAR(255),
    city VARCHAR(100) NOT NULL,
    region VARCHAR(100) NOT NULL,
    postal_code VARCHAR(20),
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    distance_km DECIMAL(6, 2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =============================================
-- SHOPPING CART
-- =============================================

CREATE TABLE cart_items (
    cart_item_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(product_id) ON DELETE CASCADE,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10, 2) NOT NULL,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, product_id)
);

-- =============================================
-- PAYMENT MANAGEMENT
-- =============================================

CREATE TABLE payments (
    payment_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID REFERENCES orders(order_id),
    user_id UUID NOT NULL REFERENCES users(user_id),
    payment_reference VARCHAR(100) UNIQUE NOT NULL,
    amount DECIMAL(12, 2) NOT NULL,
    payment_method VARCHAR(30) NOT NULL CHECK (payment_method IN ('mtn_momo', 'vodafone_cash', 'telecel_cash', 'bank_transfer', 'card', 'cash_on_delivery')),
    payment_status VARCHAR(20) DEFAULT 'pending' CHECK (payment_status IN ('pending', 'successful', 'failed', 'cancelled', 'refunded')),
    gateway_reference VARCHAR(255),
    gateway_response JSONB,
    failure_reason TEXT,
    processed_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE credit_accounts (
    credit_account_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID UNIQUE NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    credit_limit DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    current_balance DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    available_credit DECIMAL(12, 2) GENERATED ALWAYS AS (credit_limit - current_balance) STORED,
    account_status VARCHAR(20) DEFAULT 'active' CHECK (account_status IN ('active', 'suspended', 'closed')),
    linked_account_type VARCHAR(20) CHECK (linked_account_type IN ('bank', 'momo', 'telecel', 'virtual_card')),
    linked_account_number VARCHAR(50),
    linked_account_name VARCHAR(255),
    payment_terms_days INTEGER DEFAULT 30,
    interest_rate DECIMAL(5, 2) DEFAULT 0.00,
    penalty_rate DECIMAL(5, 2) DEFAULT 2.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE credit_transactions (
    transaction_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    credit_account_id UUID NOT NULL REFERENCES credit_accounts(credit_account_id) ON DELETE CASCADE,
    order_id UUID REFERENCES orders(order_id),
    transaction_type VARCHAR(20) NOT NULL CHECK (transaction_type IN ('purchase', 'payment', 'penalty', 'adjustment')),
    amount DECIMAL(12, 2) NOT NULL,
    balance_before DECIMAL(12, 2) NOT NULL,
    balance_after DECIMAL(12, 2) NOT NULL,
    due_date DATE,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'paid', 'overdue', 'written_off')),
    reference_number VARCHAR(100),
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE payment_reminders (
    reminder_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    credit_transaction_id UUID NOT NULL REFERENCES credit_transactions(transaction_id) ON DELETE CASCADE,
    reminder_type VARCHAR(10) NOT NULL CHECK (reminder_type IN ('sms', 'email', 'call')),
    recipient VARCHAR(255) NOT NULL,
    message_content TEXT NOT NULL,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'sent', 'delivered', 'failed')),
    scheduled_at TIMESTAMP NOT NULL,
    sent_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =============================================
-- DELIVERY MANAGEMENT
-- =============================================

CREATE TABLE delivery_zones (
    zone_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    zone_name VARCHAR(100) UNIQUE NOT NULL,
    zone_description TEXT,
    base_delivery_fee DECIMAL(8, 2) NOT NULL DEFAULT 0.00,
    per_km_rate DECIMAL(6, 2) NOT NULL DEFAULT 0.00,
    max_distance_km INTEGER NOT NULL DEFAULT 100,
    same_day_available BOOLEAN DEFAULT FALSE,
    delivery_conditions TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE delivery_assignments (
    assignment_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID UNIQUE NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    driver_id UUID NOT NULL REFERENCES users(user_id),
    status VARCHAR(20) DEFAULT 'assigned' CHECK (status IN ('assigned', 'accepted', 'picked_up', 'in_transit', 'delivered', 'failed')),
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    accepted_at TIMESTAMP,
    picked_up_at TIMESTAMP,
    delivered_at TIMESTAMP,
    tip_amount DECIMAL(8, 2) DEFAULT 0.00,
    customer_rating INTEGER CHECK (customer_rating BETWEEN 1 AND 5),
    delivery_notes TEXT,
    customer_feedback TEXT,
    delivery_photo_url TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE delivery_issues (
    issue_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    assignment_id UUID NOT NULL REFERENCES delivery_assignments(assignment_id) ON DELETE CASCADE,
    issue_type VARCHAR(30) NOT NULL CHECK (issue_type IN ('damage', 'delay', 'wrong_address', 'customer_unavailable', 'other')),
    description TEXT NOT NULL,
    photo_evidence_url TEXT,
    status VARCHAR(20) DEFAULT 'reported' CHECK (status IN ('reported', 'investigating', 'resolved', 'closed')),
    reported_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP,
    resolution_notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =============================================
-- DAMAGE REPORTS
-- =============================================

CREATE TABLE damage_reports (
    report_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL REFERENCES orders(order_id),
    product_id UUID NOT NULL REFERENCES products(product_id),
    reported_by_user_id UUID NOT NULL REFERENCES users(user_id),
    damage_type VARCHAR(30) NOT NULL CHECK (damage_type IN ('broken', 'defective', 'wrong_item', 'missing', 'other')),
    description TEXT NOT NULL,
    photo_evidence_url TEXT,
    damage_discovered_at TIMESTAMP NOT NULL,
    report_deadline TIMESTAMP NOT NULL,
    is_within_deadline BOOLEAN GENERATED ALWAYS AS (damage_discovered_at <= report_deadline) STORED,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected', 'resolved')),
    resolution_type VARCHAR(20) CHECK (resolution_type IN ('replacement', 'refund', 'credit')),
    admin_notes TEXT,
    resolved_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =============================================
-- NOTIFICATIONS
-- =============================================

CREATE TABLE notifications (
    notification_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(20) NOT NULL CHECK (type IN ('order', 'payment', 'delivery', 'promotion', 'birthday', 'system')),
    channel VARCHAR(20) NOT NULL CHECK (channel IN ('email', 'sms', 'push', 'in_app')),
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'sent', 'delivered', 'failed', 'read')),
    metadata JSONB,
    scheduled_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    sent_at TIMESTAMP,
    read_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =============================================
-- ANALYTICS & REPORTING
-- =============================================

CREATE TABLE customer_analytics (
    analytics_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    analytics_date DATE NOT NULL,
    orders_count INTEGER DEFAULT 0,
    total_spent DECIMAL(12, 2) DEFAULT 0.00,
    average_order_value DECIMAL(10, 2) DEFAULT 0.00,
    products_purchased INTEGER DEFAULT 0,
    days_since_last_order INTEGER,
    favorite_category VARCHAR(100),
    preferred_payment_method VARCHAR(30),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, analytics_date)
);

CREATE TABLE product_analytics (
    analytics_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    product_id UUID NOT NULL REFERENCES products(product_id) ON DELETE CASCADE,
    analytics_date DATE NOT NULL,
    views_count INTEGER DEFAULT 0,
    orders_count INTEGER DEFAULT 0,
    quantity_sold INTEGER DEFAULT 0,
    revenue_generated DECIMAL(12, 2) DEFAULT 0.00,
    conversion_rate DECIMAL(5, 4) DEFAULT 0.0000,
    cart_additions INTEGER DEFAULT 0,
    comparisons_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(product_id, analytics_date)
);

-- =============================================
-- SYSTEM CONFIGURATION
-- =============================================

CREATE TABLE system_settings (
    setting_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    setting_key VARCHAR(100) UNIQUE NOT NULL,
    setting_value TEXT NOT NULL,
    description TEXT,
    data_type VARCHAR(20) NOT NULL CHECK (data_type IN ('string', 'number', 'boolean', 'json')),
    is_editable BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE audit_logs (
    log_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(user_id),
    action_type VARCHAR(50) NOT NULL,
    table_name VARCHAR(100) NOT NULL,
    record_id VARCHAR(255) NOT NULL,
    old_values JSONB,
    new_values JSONB,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =============================================
-- INDEXES FOR PERFORMANCE
-- =============================================

-- User indexes
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_phone ON users(phone_number);
CREATE INDEX idx_users_ghana_card ON users(ghana_card_number);
CREATE INDEX idx_users_type ON users(user_type);
CREATE INDEX idx_users_active ON users(is_active);

-- Address indexes
CREATE INDEX idx_user_addresses_user_id ON user_addresses(user_id);
CREATE INDEX idx_user_addresses_primary ON user_addresses(is_primary);

-- Product indexes
CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_products_active ON products(is_active);
CREATE INDEX idx_products_featured ON products(is_featured);
CREATE INDEX idx_products_sku ON products(sku);
CREATE INDEX idx_products_name_search ON products USING gin(to_tsvector('english', product_name));

-- Inventory indexes
CREATE INDEX idx_inventory_product ON inventory(product_id);
CREATE INDEX idx_inventory_available_stock ON inventory(available_stock);
CREATE INDEX idx_inventory_reorder_level ON inventory(reorder_level);

-- Order indexes
CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_orders_status ON orders(order_status);
CREATE INDEX idx_orders_payment_status ON orders(payment_status);
CREATE INDEX idx_orders_date ON orders(order_placed_at);
CREATE INDEX idx_orders_number ON orders(order_number);

-- Order items indexes
CREATE INDEX idx_order_items_order ON order_items(order_id);
CREATE INDEX idx_order_items_product ON order_items(product_id);

-- Payment indexes
CREATE INDEX idx_payments_order ON payments(order_id);
CREATE INDEX idx_payments_user ON payments(user_id);
CREATE INDEX idx_payments_status ON payments(payment_status);
CREATE INDEX idx_payments_reference ON payments(payment_reference);

-- Credit indexes
CREATE INDEX idx_credit_accounts_user ON credit_accounts(user_id);
CREATE INDEX idx_credit_transactions_account ON credit_transactions(credit_account_id);
CREATE INDEX idx_credit_transactions_status ON credit_transactions(status);
CREATE INDEX idx_credit_transactions_due_date ON credit_transactions(due_date);

-- Delivery indexes
CREATE INDEX idx_delivery_assignments_order ON delivery_assignments(order_id);
CREATE INDEX idx_delivery_assignments_driver ON delivery_assignments(driver_id);
CREATE INDEX idx_delivery_assignments_status ON delivery_assignments(status);

-- Notification indexes
CREATE INDEX idx_notifications_user ON notifications(user_id);
CREATE INDEX idx_notifications_status ON notifications(status);
CREATE INDEX idx_notifications_type ON notifications(type);
CREATE INDEX idx_notifications_scheduled ON notifications(scheduled_at);

-- Analytics indexes
CREATE INDEX idx_customer_analytics_user_date ON customer_analytics(user_id, analytics_date);
CREATE INDEX idx_product_analytics_product_date ON product_analytics(product_id, analytics_date);

-- Audit log indexes
CREATE INDEX idx_audit_logs_user ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_table ON audit_logs(table_name);
CREATE INDEX idx_audit_logs_created ON audit_logs(created_at);

-- =============================================
-- TRIGGERS FOR AUTOMATED UPDATES
-- =============================================

-- Update timestamp trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$ language 'plpgsql';

-- Apply update timestamp triggers to relevant tables
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_user_addresses_updated_at BEFORE UPDATE ON user_addresses FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_user_profiles_updated_at BEFORE UPDATE ON user_profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_products_updated_at BEFORE UPDATE ON products FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_inventory_updated_at BEFORE UPDATE ON inventory FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_orders_updated_at BEFORE UPDATE ON orders FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_credit_accounts_updated_at BEFORE UPDATE ON credit_accounts FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_credit_transactions_updated_at BEFORE UPDATE ON credit_transactions FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Order number generation function
CREATE OR REPLACE FUNCTION generate_order_number()
RETURNS TRIGGER AS $
BEGIN
    NEW.order_number = 'EB' || TO_CHAR(CURRENT_DATE, 'YYMMDD') || '-' || LPAD(nextval('order_sequence')::text, 4, '0');
    RETURN NEW;
END;
$ language 'plpgsql';

-- Create sequence for order numbers
CREATE SEQUENCE order_sequence START 1;

-- Apply order number trigger
CREATE TRIGGER generate_order_number_trigger BEFORE INSERT ON orders FOR EACH ROW EXECUTE FUNCTION generate_order_number();

-- Inventory movement tracking function
CREATE OR REPLACE FUNCTION track_inventory_movement()
RETURNS TRIGGER AS $
BEGIN
    IF TG_OP = 'UPDATE' AND OLD.current_stock != NEW.current_stock THEN
        INSERT INTO inventory_movements (
            product_id, 
            movement_type, 
            quantity, 
            previous_stock, 
            new_stock,
            reference_number,
            notes
        ) VALUES (
            NEW.product_id,
            CASE 
                WHEN NEW.current_stock > OLD.current_stock THEN 'in'
                ELSE 'out'
            END,
            ABS(NEW.current_stock - OLD.current_stock),
            OLD.current_stock,
            NEW.current_stock,
            'AUTO-' || gen_random_uuid()::text,
            'Automatic inventory tracking'
        );
    END IF;
    RETURN NEW;
END;
$ language 'plpgsql';

-- Apply inventory tracking trigger
CREATE TRIGGER track_inventory_movement_trigger AFTER UPDATE ON inventory FOR EACH ROW EXECUTE FUNCTION track_inventory_movement();

-- =============================================
-- INITIAL SYSTEM SETTINGS
-- =============================================

INSERT INTO system_settings (setting_key, setting_value, description, data_type) VALUES
('bulk_discount_threshold', '100', 'Minimum quantity for bulk discount', 'number'),
('bulk_discount_percentage', '1.5', 'Percentage discount for bulk orders', 'number'),
('delivery_time_window_hours', '2', 'Time window for damage reporting in hours', 'number'),
('max_delivery_distance_km', '100', 'Maximum delivery distance in kilometers', 'number'),
('credit_penalty_rate', '2.0', 'Penalty rate for late credit payments', 'number'),
('credit_additional_fee_rate', '50.0', 'Additional fee for defaulted credit purchases', 'number'),
('same_day_cutoff_hour', '12', 'Cutoff hour for same-day delivery (24hr format)', 'number'),
('first_customer_incentive_count', '20', 'Number of customers eligible for first customer incentive', 'number'),
('low_stock_alert_threshold', '10', 'Threshold for low stock alerts', 'number'),
('payment_reminder_days', '3', 'Days before due date to send payment reminders', 'number');

-- =============================================
-- INITIAL PRODUCT CATEGORIES
-- =============================================

INSERT INTO product_categories (category_name, category_slug, description, sort_order) VALUES
('Cement & Concrete', 'cement-concrete', 'Cement, concrete blocks, and related materials', 1),
('Iron & Steel', 'iron-steel', 'Iron rods, steel bars, and metal construction materials', 2),
('Roofing Materials', 'roofing', 'Roofing sheets, tiles, and accessories', 3),
('Paints & Finishes', 'paints-finishes', 'Oil paints, emulsion paints, and finishing materials', 4),
('Plumbing Supplies', 'plumbing', 'Pipes, fittings, and plumbing accessories', 5),
('Electrical Materials', 'electrical', 'Wires, switches, and electrical components', 6),
('Tools & Equipment', 'tools-equipment', 'Construction tools and equipment', 7),
('Wood & Timber', 'wood-timber', 'Plywood, timber, and wood products', 8),
('Hardware & Fasteners', 'hardware-fasteners', 'Nails, screws, bolts, and hardware', 9),
('Safety Equipment', 'safety', 'Protective gear and safety equipment', 10),
('Consultancy Services', 'consultancy', 'Professional consultation and advisory services', 11),
('Rental Services', 'rentals', 'Equipment and tool rental services', 12);

-- =============================================
-- INITIAL DELIVERY ZONES (GHANA REGIONS)
-- =============================================

INSERT INTO delivery_zones (zone_name, zone_description, base_delivery_fee, per_km_rate, max_distance_km, same_day_available) VALUES
('Greater Accra - Central', 'Central Accra and immediate surroundings', 15.00, 2.50, 25, true),
('Greater Accra - Extended', 'Extended Accra metropolitan area', 25.00, 3.00, 50, true),
('Eastern Region', 'Eastern Region delivery zone', 50.00, 4.00, 100, false),
('Central Region', 'Central Region delivery zone', 60.00, 4.50, 120, false),
('Western Region', 'Western Region delivery zone', 70.00, 5.00, 150, false),
('Ashanti Region', 'Ashanti Region delivery zone', 80.00, 5.50, 200, false),
('Northern Regions', 'Northern, Upper East, Upper West regions', 120.00, 6.00, 300, false);

-- Create views for common queries
CREATE VIEW active_products_with_stock AS
SELECT 
    p.*,
    pc.category_name,
    i.current_stock,
    i.available_stock,
    i.reorder_level
FROM products p
JOIN product_categories pc ON p.category_id = pc.category_id
JOIN inventory i ON p.product_id = i.product_id
WHERE p.is_active = true;

CREATE VIEW customer_order_summary AS
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    COUNT(o.order_id) as total_orders,
    SUM(o.total_amount) as total_spent,
    AVG(o.total_amount) as average_order_value,
    MAX(o.order_placed_at) as last_order_date
FROM users u
LEFT JOIN orders o ON u.user_id = o.customer_id
WHERE u.user_type IN ('customer', 'contractor')
GROUP BY u.user_id, u.first_name, u.last_name, u.email;

-- =============================================
-- SAMPLE DATA FOR TESTING (Optional)
-- =============================================

-- Sample admin user (password should be hashed in production)
INSERT INTO users (email, phone_number, password_hash, first_name, last_name, user_type, ghana_card_verified) VALUES
('admin@ebuildify.com', '+233241234567', crypt('admin123', gen_salt('bf')), 'System', 'Admin', 'admin', true);

-- Sample customer
INSERT INTO users (email, phone_number, password_hash, first_name, last_name, user_type, ghana_card_number) VALUES
('customer@test.com', '+233501234567', crypt('password123', gen_salt('bf')), 'John', 'Doe', 'customer', 'GHA-123456789-0');

-- Sample product
INSERT INTO products (category_id, product_name, product_slug, sku, description, unit_price, unit_of_measure, minimum_order_quantity, is_bulk_item, bulk_threshold) 
SELECT 
    category_id, 
    'Diamond Cement (50kg bag)', 
    'diamond-cement-50kg', 
    'CEM-DIA-50KG', 
    'High quality Portland cement, 50kg bag', 
    45.00, 
    'bag', 
    10, 
    true, 
    100
FROM product_categories WHERE category_slug = 'cement-concrete' LIMIT 1;

-- Sample inventory for the product
INSERT INTO inventory (product_id, current_stock, reorder_level, maximum_stock, cost_price, warehouse_location)
SELECT product_id, 500, 50, 1000, 40.00, 'Main Warehouse - Section A'
FROM products WHERE sku = 'CEM-DIA-50KG' LIMIT 1;

COMMIT;