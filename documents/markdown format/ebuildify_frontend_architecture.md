# eBuildify Frontend Architecture & Component Design
**BuildTech Solutions - React PWA Architecture**  
**Client:** SOL LITTLE BY LITTLE ENTERPRISE  
**Project:** eBuildify Platform  
**Version:** 2.0  

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Technology Stack](#technology-stack)
3. [Application Structure](#application-structure)
4. [Component Hierarchy](#component-hierarchy)
5. [State Management](#state-management)
6. [Routing Strategy](#routing-strategy)
7. [PWA Features](#pwa-features)
8. [Component Design Patterns](#component-design-patterns)
9. [UI/UX Design System](#uiux-design-system)
10. [Performance Optimization](#performance-optimization)
11. [Security Considerations](#security-considerations)
12. [Testing Strategy](#testing-strategy)

---

## Architecture Overview

### **Design Philosophy**
- **Mobile-First Approach**: Optimized for Ghana's mobile-heavy user base
- **Progressive Web App**: Offline functionality for low-connectivity areas
- **Component-Driven Development**: Reusable, maintainable components
- **Performance-Focused**: Fast loading on 3G networks
- **Accessibility**: WCAG 2.1 compliance for inclusive design

### **Architecture Pattern**
**Micro-Frontend Architecture** with feature-based modules:

```
src/
├── features/           # Feature modules
│   ├── auth/          # Authentication & registration
│   ├── catalog/       # Product browsing & search
│   ├── cart/          # Shopping cart management
│   ├── orders/        # Order management
│   ├── payments/      # Payment processing
│   ├── delivery/      # Delivery tracking
│   ├── services/      # Service booking
│   ├── credit/        # Credit management
│   └── admin/         # Admin dashboard
├── shared/            # Shared components & utilities
├── hooks/             # Custom React hooks
├── services/          # API integration
├── store/             # State management
└── assets/            # Static assets
```

---

## Technology Stack

### **Core Technologies**
- **React 18**: Latest features with concurrent rendering
- **TypeScript**: Type safety and better developer experience
- **Vite**: Fast build tool and development server
- **PWA Workbox**: Service worker management

### **State Management**
- **Zustand**: Lightweight state management
- **React Query (TanStack Query)**: Server state management
- **React Hook Form**: Form state management

### **UI Framework & Styling**
- **Tailwind CSS**: Utility-first CSS framework
- **Headless UI**: Accessible components
- **Framer Motion**: Animation library
- **React Hook Form**: Form handling

### **Additional Libraries**
- **React Router v6**: Client-side routing
- **Axios**: HTTP client
- **date-fns**: Date manipulation
- **react-hot-toast**: Notifications
- **react-intersection-observer**: Lazy loading

---

## Application Structure

### **Feature-Based Architecture**

Each feature module follows this structure:
```
features/[feature-name]/
├── components/        # Feature-specific components
├── hooks/            # Feature-specific hooks
├── services/         # API calls
├── types/            # TypeScript types
├── utils/            # Utility functions
└── index.ts          # Public API
```

### **Shared Infrastructure**
```
shared/
├── components/       # Reusable UI components
│   ├── ui/          # Basic UI elements
│   ├── forms/       # Form components
│   ├── layout/      # Layout components
│   └── feedback/    # Loading, error states
├── hooks/           # Global custom hooks
├── utils/           # Utility functions
├── constants/       # App constants
└── types/           # Global types
```

---

## Component Hierarchy

### **1. Authentication Module**
```typescript
// Authentication Components
AuthLayout
├── LoginForm
├── RegisterForm
│   ├── GhanaCardUpload
│   ├── AddressForm
│   └── PasswordStrength
├── ForgotPasswordForm
└── VerificationSteps
    ├── EmailVerification
    └── PhoneVerification
```

### **2. Product Catalog Module**
```typescript
// Catalog Components
CatalogLayout
├── CategorySidebar
│   ├── CategoryTree
│   └── FilterPanel
├── ProductGrid
│   ├── ProductCard
│   │   ├── ProductImage
│   │   ├── ProductInfo
│   │   ├── BulkPricing
│   │   └── AddToCartButton
│   └── ProductSkeleton
├── SearchBar
│   ├── SearchInput
│   ├── SearchSuggestions
│   └── SearchFilters
└── ProductComparison
    ├── ComparisonTable
    └── ComparisonActions
```

### **3. Shopping Cart Module**
```typescript
// Cart Components
CartLayout
├── CartHeader
├── CartItems
│   ├── CartItem
│   │   ├── ProductInfo
│   │   ├── QuantitySelector
│   │   ├── PriceDisplay
│   │   └── RemoveButton
│   └── BulkDiscountBanner
├── CartSummary
│   ├── PricingBreakdown
│   ├── DeliveryEstimate
│   └── PromoCodeInput
└── CheckoutButton
```

### **4. Order Management Module**
```typescript
// Order Components
OrderLayout
├── OrderHistory
│   ├── OrderCard
│   │   ├── OrderHeader
│   │   ├── OrderItems
│   │   ├── OrderStatus
│   │   └── OrderActions
│   └── OrderFilters
├── OrderDetails
│   ├── OrderTimeline
│   ├── DeliveryTracking
│   ├── DamageReportForm
│   └── ReorderButton
└── ProjectTags
    ├── TagSelector
    └── TagManager
```

### **5. Payment Module**
```typescript
// Payment Components
PaymentLayout
├── PaymentMethods
│   ├── MobileMoneyForm
│   ├── BankTransferForm
│   ├── CashOnDeliveryForm
│   └── CreditPaymentForm
├── PaymentSummary
├── CreditApplication
│   ├── CreditForm
│   ├── AccountLinking
│   └── CreditTerms
└── PaymentHistory
    ├── TransactionList
    └── CreditStatement
```

### **6. Service Booking Module**
```typescript
// Services Components
ServicesLayout
├── ServiceCatalog
│   ├── ServiceCard
│   ├── ServiceCategories
│   └── ConsultantProfiles
├── BookingForm
│   ├── ServiceSelection
│   ├── ProjectDetails
│   ├── ScheduleSelector
│   └── RequirementsForm
└── BookingManagement
    ├── BookingList
    ├── BookingDetails
    └── BookingActions
```

### **7. Delivery & Logistics Module**
```typescript
// Delivery Components
DeliveryLayout
├── DeliveryTracking
│   ├── TrackingMap
│   ├── DeliveryTimeline
│   ├── DriverInfo
│   └── DeliveryActions
├── DeliveryCalculator
│   ├── AddressInput
│   ├── DistanceCalculator
│   └── PricingDisplay
├── PickupAssignment
│   ├── PickupPersonForm
│   ├── IDVerification
│   └── PickupInstructions
└── DamageReporting
    ├── DamageForm
    ├── PhotoUpload
    └── TimeLimit
```

### **8. Admin Dashboard Module**
```typescript
// Admin Components
AdminLayout
├── DashboardOverview
│   ├── KPICards
│   ├── SalesChart
│   ├── RecentOrders
│   └── AlertsPanel
├── OrderManagement
│   ├── OrderTable
│   ├── OrderFilters
│   ├── BulkActions
│   └── StatusUpdater
├── InventoryManagement
│   ├── ProductTable
│   ├── StockAdjustment
│   ├── LowStockAlerts
│   └── BatchUpload
├── CustomerManagement
│   ├── CustomerTable
│   ├── CreditApprovals
│   └── VerificationQueue
└── Analytics
    ├── SalesAnalytics
    ├── CustomerAnalytics
    └── ProductAnalytics
```

---

## State Management

### **State Architecture**
```typescript
// Global State Structure
interface AppState {
  auth: AuthState;
  cart: CartState;
  products: ProductState;
  orders: OrderState;
  ui: UIState;
  offline: OfflineState;
}

// Auth State
interface AuthState {
  user: User | null;
  isAuthenticated: boolean;
  permissions: Permission[];
  loading: boolean;
}

// Cart State
interface CartState {
  items: CartItem[];
  summary: CartSummary;
  savedOffline: boolean;
  lastSynced: Date;
}

// UI State
interface UIState {
  theme: 'light' | 'dark';
  language: 'en' | 'tw';
  notifications: Notification[];
  modals: ModalState;
  loading: Record<string, boolean>;
}
```

### **State Management Strategy**

#### **Zustand Stores**
```typescript
// Auth Store
export const useAuthStore = create<AuthState>((set, get) => ({
  user: null,
  isAuthenticated: false,
  login: async (credentials) => {
    // Login logic
  },
  logout: () => {
    // Logout logic
  },
  // ... other actions
}));

// Cart Store with Offline Support
export const useCartStore = create<CartState>()(
  persist(
    (set, get) => ({
      items: [],
      addItem: (product, quantity) => {
        // Add to cart logic
      },
      // ... other actions
    }),
    {
      name: 'cart-storage',
      storage: createJSONStorage(() => localStorage),
    }
  )
);
```

#### **React Query for Server State**
```typescript
// Product Queries
export const useProducts = (filters: ProductFilters) => {
  return useQuery({
    queryKey: ['products', filters],
    queryFn: () => productService.getProducts(filters),
    staleTime: 5 * 60 * 1000, // 5 minutes
    cacheTime: 10 * 60 * 1000, // 10 minutes
  });
};

// Order Mutations
export const useCreateOrder = () => {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: orderService.createOrder,
    onSuccess: () => {
      queryClient.invalidateQueries(['orders']);
      queryClient.invalidateQueries(['cart']);
    },
  });
};
```

---

## Routing Strategy

### **Route Structure**
```typescript
// Public Routes
/                          # Homepage
/products                  # Product catalog
/products/:productId       # Product details
/categories/:categoryId    # Category browse
/services                  # Services catalog
/services/:serviceId       # Service details
/login                     # User login
/register                  # User registration
/forgot-password          # Password recovery

// Protected Routes (Customer)
/dashboard                 # Customer dashboard
/cart                      # Shopping cart
/checkout                  # Checkout process
/orders                    # Order history
/orders/:orderId           # Order details
/profile                   # User profile
/addresses                 # Address management
/credit                    # Credit account
/bookings                  # Service bookings

// Admin Routes
/admin                     # Admin dashboard
/admin/orders              # Order management
/admin/products            # Product management
/admin/customers           # Customer management
/admin/analytics           # Analytics
/admin/settings            # System settings

// Driver Routes
/driver                    # Driver dashboard
/driver/deliveries         # Delivery assignments
/driver/deliveries/:id     # Delivery details
```

### **Route Protection**
```typescript
// Route Guard Component
const ProtectedRoute: React.FC<{
  children: React.ReactNode;
  requiredRole?: UserRole;
}> = ({ children, requiredRole }) => {
  const { user, isAuthenticated } = useAuthStore();
  
  if (!isAuthenticated) {
    return <Navigate to="/login" replace />;
  }
  
  if (requiredRole && !user?.roles.includes(requiredRole)) {
    return <Navigate to="/unauthorized" replace />;
  }
  
  return <>{children}</>;
};
```

---

## PWA Features

### **Service Worker Configuration**
```typescript
// PWA Features
export const pwaConfig = {
  // Offline Support
  runtimeCaching: [
    {
      urlPattern: /^https:\/\/api\.ebuildify\.com\/v1\/products/,
      handler: 'StaleWhileRevalidate',
      options: {
        cacheName: 'products-cache',
        expiration: {
          maxEntries: 100,
          maxAgeSeconds: 24 * 60 * 60, // 24 hours
        },
      },
    },
    {
      urlPattern: /^https:\/\/cdn\.ebuildify\.com/,
      handler: 'CacheFirst',
      options: {
        cacheName: 'images-cache',
        expiration: {
          maxEntries: 200,
          maxAgeSeconds: 7 * 24 * 60 * 60, // 7 days
        },
      },
    },
  ],
  
  // Background Sync
  backgroundSync: {
    name: 'cart-sync',
    options: {
      maxRetentionTime: 24 * 60, // 24 hours
    },
  },
};
```

### **Offline Cart Management**
```typescript
// Offline Cart Hook
export const useOfflineCart = () => {
  const [isOnline, setIsOnline] = useState(navigator.onLine);
  const { items, syncCart } = useCartStore();
  
  useEffect(() => {
    const handleOnline = () => {
      setIsOnline(true);
      syncCart(); // Sync cart when back online
    };
    
    const handleOffline = () => setIsOnline(false);
    
    window.addEventListener('online', handleOnline);
    window.addEventListener('offline', handleOffline);
    
    return () => {
      window.removeEventListener('online', handleOnline);
      window.removeEventListener('offline', handleOffline);
    };
  }, [syncCart]);
  
  return { isOnline, items };
};
```

---

## Component Design Patterns

### **1. Compound Components Pattern**
```typescript
// Product Card Compound Component
const ProductCard = ({ children, product }) => {
  return (
    <ProductCardProvider product={product}>
      <div className="product-card">
        {children}
      </div>
    </ProductCardProvider>
  );
};

ProductCard.Image = ProductImage;
ProductCard.Title = ProductTitle;
ProductCard.Price = ProductPrice;
ProductCard.Actions = ProductActions;

// Usage
<ProductCard product={product}>
  <ProductCard.Image />
  <ProductCard.Title />
  <ProductCard.Price />
  <ProductCard.Actions />
</ProductCard>
```

### **2. Render Props Pattern**
```typescript
// Data Fetcher Component
const DataFetcher = ({ children, queryKey, queryFn }) => {
  const { data, loading, error } = useQuery(queryKey, queryFn);
  
  return children({ data, loading, error });
};

// Usage
<DataFetcher queryKey="products" queryFn={getProducts}>
  {({ data, loading, error }) => (
    <>
      {loading && <ProductSkeleton />}
      {error && <ErrorMessage />}
      {data && <ProductGrid products={data} />}
    </>
  )}
</DataFetcher>
```

### **3. Custom Hooks Pattern**
```typescript
// Product Search Hook
export const useProductSearch = () => {
  const [filters, setFilters] = useState<ProductFilters>({});
  const [searchTerm, setSearchTerm] = useState('');
  const [debouncedTerm] = useDebounce(searchTerm, 500);
  
  const { data: products, loading } = useQuery({
    queryKey: ['products', filters, debouncedTerm],
    queryFn: () => productService.search({ ...filters, search: debouncedTerm }),
  });
  
  return {
    products,
    loading,
    filters,
    setFilters,
    searchTerm,
    setSearchTerm,
  };
};
```

---

## UI/UX Design System

### **Design Tokens**
```typescript
// Theme Configuration
export const theme = {
  colors: {
    primary: {
      50: '#EBF8FF',
      100: '#BEE3F8',
      500: '#3182CE', // Primary blue
      600: '#2C5282',
      900: '#1A365D',
    },
    accent: {
      50: '#FFFBEB',
      100: '#FEF3C7',
      500: '#F59E0B', // Yellow accent
      600: '#D97706',
      900: '#78350F',
    },
    gray: {
      50: '#F7FAFC',
      100: '#EDF2F7',
      200: '#E2E8F0',
      500: '#718096',
      900: '#1A202C',
    },
    semantic: {
      success: '#10B981',
      warning: '#F59E0B',
      error: '#EF4444',
      info: '#3B82F6',
    },
  },
  
  typography: {
    fontFamily: {
      sans: ['Inter', 'system-ui', 'sans-serif'],
      mono: ['JetBrains Mono', 'monospace'],
    },
    fontSize: {
      xs: '0.75rem',
      sm: '0.875rem',
      base: '1rem',
      lg: '1.125rem',
      xl: '1.25rem',
      '2xl': '1.5rem',
      '3xl': '1.875rem',
    },
  },
  
  spacing: {
    xs: '0.25rem',
    sm: '0.5rem',
    md: '1rem',
    lg: '1.5rem',
    xl: '2rem',
    '2xl': '3rem',
  },
  
  breakpoints: {
    sm: '640px',
    md: '768px',
    lg: '1024px',
    xl: '1280px',
  },
};
```

### **Component Variants**
```typescript
// Button Component with Variants
interface ButtonProps {
  variant?: 'primary' | 'secondary' | 'ghost' | 'danger';
  size?: 'sm' | 'md' | 'lg';
  loading?: boolean;
  children: React.ReactNode;
}

const Button: React.FC<ButtonProps> = ({
  variant = 'primary',
  size = 'md',
  loading = false,
  children,
  ...props
}) => {
  const variants = {
    primary: 'bg-primary-500 text-white hover:bg-primary-600',
    secondary: 'bg-gray-100 text-gray-900 hover:bg-gray-200',
    ghost: 'bg-transparent text-primary-500 hover:bg-primary-50',
    danger: 'bg-red-500 text-white hover:bg-red-600',
  };
  
  const sizes = {
    sm: 'px-3 py-1.5 text-sm',
    md: 'px-4 py-2 text-base',
    lg: 'px-6 py-3 text-lg',
  };
  
  return (
    <button
      className={cn(
        'inline-flex items-center justify-center rounded-md font-medium transition-colors',
        'focus:outline-none focus:ring-2 focus:ring-primary-500 focus:ring-offset-2',
        'disabled:opacity-50 disabled:cursor-not-allowed',
        variants[variant],
        sizes[size]
      )}
      disabled={loading}
      {...props}
    >
      {loading && <Spinner className="mr-2" />}
      {children}
    </button>
  );
};
```

### **Responsive Design System**
```typescript
// Responsive Grid Component
const ResponsiveGrid: React.FC<{
  children: React.ReactNode;
  columns?: { sm?: number; md?: number; lg?: number; xl?: number };
}> = ({ children, columns = { sm: 1, md: 2, lg: 3, xl: 4 } }) => {
  const gridClasses = cn(
    'grid gap-4',
    columns.sm && `grid-cols-${columns.sm}`,
    columns.md && `md:grid-cols-${columns.md}`,
    columns.lg && `lg:grid-cols-${columns.lg}`,
    columns.xl && `xl:grid-cols-${columns.xl}`
  );
  
  return <div className={gridClasses}>{children}</div>;
};
```

---

## Performance Optimization

### **Code Splitting Strategy**
```typescript
// Lazy Loading Components
const LazyProductCatalog = lazy(() => import('./features/catalog/ProductCatalog'));
const LazyAdminDashboard = lazy(() => import('./features/admin/AdminDashboard'));
const LazyServiceBooking = lazy(() => import('./features/services/ServiceBooking'));

// Route-based Code Splitting
const routes = [
  {
    path: '/products',
    component: (
      <Suspense fallback={<PageSkeleton />}>
        <LazyProductCatalog />
      </Suspense>
    ),
  },
  {
    path: '/admin',
    component: (
      <Suspense fallback={<PageSkeleton />}>
        <LazyAdminDashboard />
      </Suspense>
    ),
  },
];
```

### **Image Optimization**
```typescript
// Optimized Image Component
const OptimizedImage: React.FC<{
  src: string;
  alt: string;
  width?: number;
  height?: number;
  loading?: 'lazy' | 'eager';
}> = ({ src, alt, width, height, loading = 'lazy' }) => {
  const [imageSrc, setImageSrc] = useState(src);
  const [imageLoading, setImageLoading] = useState(true);
  const [imageError, setImageError] = useState(false);
  
  // Generate responsive image URLs
  const responsiveImages = {
    small: `${src}?w=400&q=80`,
    medium: `${src}?w=800&q=80`,
    large: `${src}?w=1200&q=80`,
  };
  
  return (
    <div className="relative overflow-hidden">
      {imageLoading && (
        <div className="absolute inset-0 bg-gray-200 animate-pulse" />
      )}
      
      <img
        src={responsiveImages.medium}
        srcSet={`
          ${responsiveImages.small} 400w,
          ${responsiveImages.medium} 800w,
          ${responsiveImages.large} 1200w
        `}
        sizes="(max-width: 640px) 400px, (max-width: 1024px) 800px, 1200px"
        alt={alt}
        width={width}
        height={height}
        loading={loading}
        onLoad={() => setImageLoading(false)}
        onError={() => {
          setImageError(true);
          setImageLoading(false);
        }}
        className={cn(
          'transition-opacity duration-300',
          imageLoading ? 'opacity-0' : 'opacity-100'
        )}
      />
      
      {imageError && (
        <div className="absolute inset-0 flex items-center justify-center bg-gray-100">
          <span className="text-gray-400">Image not available</span>
        </div>
      )}
    </div>
  );
};
```

### **Virtual Scrolling for Large Lists**
```typescript
// Virtual Product List
const VirtualProductList: React.FC<{
  products: Product[];
  onLoadMore: () => void;
}> = ({ products, onLoadMore }) => {
  const { ref, inView } = useInView({
    threshold: 0,
    rootMargin: '100px',
  });
  
  useEffect(() => {
    if (inView) {
      onLoadMore();
    }
  }, [inView, onLoadMore]);
  
  return (
    <div className="space-y-4">
      {products.map((product, index) => (
        <ProductCard key={product.id} product={product} />
      ))}
      
      <div ref={ref} className="h-4" />
    </div>
  );
};
```

---

## Security Considerations

### **Input Sanitization**
```typescript
// Secure Input Component
const SecureInput: React.FC<{
  type: 'text' | 'email' | 'tel' | 'password';
  value: string;
  onChange: (value: string) => void;
  sanitize?: boolean;
}> = ({ type, value, onChange, sanitize = true, ...props }) => {
  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    let newValue = e.target.value;
    
    if (sanitize) {
      // Basic XSS prevention
      newValue = newValue.replace(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, '');
      newValue = newValue.replace(/javascript:/gi, '');
    }
    
    onChange(newValue);
  };
  
  return (
    <input
      type={type}
      value={value}
      onChange={handleChange}
      {...props}
    />
  );
};
```

### **Token Management**
```typescript
// Secure Token Storage
class TokenManager {
  private static readonly TOKEN_KEY = 'ebuildify_token';
  private static readonly REFRESH_KEY = 'ebuildify_refresh';
  
  static setTokens(accessToken: string, refreshToken: string) {
    // Store in httpOnly cookie for production
    if (process.env.NODE_ENV === 'production') {
      document.cookie = `${this.TOKEN_KEY}=${accessToken}; Secure; HttpOnly; SameSite=Strict`;
    } else {
      localStorage.setItem(this.TOKEN_KEY, accessToken);
    }
    localStorage.setItem(this.REFRESH_KEY, refreshToken);
  }
  
  static getAccessToken(): string | null {
    return localStorage.getItem(this.TOKEN_KEY);
  }
  
  static clearTokens() {
    localStorage.removeItem(this.TOKEN_KEY);
    localStorage.removeItem(this.REFRESH_KEY);
    
    // Clear cookie
    document.cookie = `${this.TOKEN_KEY}=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;`;
  }
}
```

---

## Testing Strategy

### **Component Testing**
```typescript
// Product Card Component Test
describe('ProductCard', () => {
  const mockProduct: Product = {
    id: '1',
    name: 'Diamond Cement',
    price: 45.00,
    unit: 'bag',
    image: '/images/cement.jpg',
    inStock: true,
  };
  
  it('renders product information correctly', () => {
    render(<ProductCard product={mockProduct} />);
    
    expect(screen.getByText('Diamond Cement')).toBeInTheDocument();
    expect(screen.getByText('₵45.00')).toBeInTheDocument();
    expect(screen.getByText('per bag')).toBeInTheDocument();
  });
  
  it('shows bulk discount for eligible products', () => {
    const bulkProduct = { ...mockProduct, isBulkItem: true };
    render(<ProductCard product={bulkProduct} />);
    
    expect(screen.getByText(/bulk discount/i)).toBeInTheDocument();
  });
  
  it('handles add to cart action', async () => {
    const mockAddToCart = jest.fn();
    render(<ProductCard product={mockProduct} onAddToCart={mockAddToCart} />);
    
    const addButton = screen.getByText(/add to cart/i);
    fireEvent.click(addButton);
    
    expect(mockAddToCart).toHaveBeenCalledWith(mockProduct.id, 1);
  });
});
```

### **Integration Testing**
```typescript
// Cart Integration Test
describe('Cart Integration', () => {
  it('adds product to cart and updates summary', async () => {
    const { user } = setupTest();
    
    // Navigate to product page
    await user.click(screen.getByText('Diamond Cement'));
    
    // Add to cart
    await user.click(screen.getByText('Add to Cart'));
    
    // Check cart badge updates
    expect(screen.getByTestId('cart-count')).toHaveTextContent('1');
    
    // Navigate to cart
    await user.click(screen.getByTestId('cart-link'));
    
    // Verify product in cart
    expect(screen.getByText('Diamond Cement')).toBeInTheDocument();
    expect(screen.getByText('₵45.00')).toBeInTheDocument();
  });
});
```

### **E2E Testing with Playwright**
```typescript
// E2E Test for Order Flow
test('complete order flow', async ({ page }) => {
  // Login
  await page.goto('/login');
  await page.fill('[data-testid="email"]', 'customer@test.com');
  await page.fill('[data-testid="password"]', 'password123');
  await page.click('[data-testid="login-button"]');
  
  // Browse products
  await page.goto('/products');
  await page.click('[data-testid="product-card"]:first-child');
  
  // Add to cart
  await page.click('[data-testid="add-to-cart"]');
  
  // Go to cart
  await page.click('[data-testid="cart-link"]');
  
  // Proceed to checkout
  await page.click('[data-testid="checkout-button"]');
  
  // Fill delivery information
  await page.fill('[data-testid="delivery-address"]', '123 Test Street');
  await page.selectOption('[data-testid="payment-method"]', 'mtn_momo');
  
  // Place order
  await page.click('[data-testid="place-order"]');
  
  // Verify success
  await expect(page.locator('[data-testid="order-success"]')).toBeVisible();
});
```

---

## Deployment & Build Configuration

### **Vite Configuration**
```typescript
// vite.config.ts
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import { VitePWA } from 'vite-plugin-pwa';
import path from 'path';

export default defineConfig({
  plugins: [
    react(),
    VitePWA({
      registerType: 'autoUpdate',
      workbox: {
        globPatterns: ['**/*.{js,css,html,ico,png,svg,webp}'],
        runtimeCaching: [
          {
            urlPattern: /^https:\/\/api\.ebuildify\.com/,
            handler: 'NetworkFirst',
            options: {
              cacheName: 'api-cache',
              networkTimeoutSeconds: 10,
              expiration: {
                maxEntries: 100,
                maxAgeSeconds: 24 * 60 * 60, // 24 hours
              },
            },
          },
          {
            urlPattern: /^https:\/\/cdn\.ebuildify\.com/,
            handler: 'CacheFirst',
            options: {
              cacheName: 'images-cache',
              expiration: {
                maxEntries: 200,
                maxAgeSeconds: 7 * 24 * 60 * 60, // 7 days
              },
            },
          },
        ],
      },
      manifest: {
        name: 'eBuildify - Building Materials Delivery',
        short_name: 'eBuildify',
        description: 'Ghana\'s premier building materials delivery platform',
        theme_color: '#3182CE',
        background_color: '#ffffff',
        display: 'standalone',
        orientation: 'portrait',
        scope: '/',
        start_url: '/',
        icons: [
          {
            src: '/icons/icon-72x72.png',
            sizes: '72x72',
            type: 'image/png',
          },
          {
            src: '/icons/icon-96x96.png',
            sizes: '96x96',
            type: 'image/png',
          },
          {
            src: '/icons/icon-128x128.png',
            sizes: '128x128',
            type: 'image/png',
          },
          {
            src: '/icons/icon-144x144.png',
            sizes: '144x144',
            type: 'image/png',
          },
          {
            src: '/icons/icon-152x152.png',
            sizes: '152x152',
            type: 'image/png',
          },
          {
            src: '/icons/icon-192x192.png',
            sizes: '192x192',
            type: 'image/png',
          },
          {
            src: '/icons/icon-384x384.png',
            sizes: '384x384',
            type: 'image/png',
          },
          {
            src: '/icons/icon-512x512.png',
            sizes: '512x512',
            type: 'image/png',
          },
        ],
      },
    }),
  ],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
      '@/components': path.resolve(__dirname, './src/components'),
      '@/features': path.resolve(__dirname, './src/features'),
      '@/hooks': path.resolve(__dirname, './src/hooks'),
      '@/services': path.resolve(__dirname, './src/services'),
      '@/store': path.resolve(__dirname, './src/store'),
      '@/utils': path.resolve(__dirname, './src/utils'),
      '@/types': path.resolve(__dirname, './src/types'),
    },
  },
  build: {
    target: 'es2015',
    outDir: 'dist',
    sourcemap: true,
    rollupOptions: {
      output: {
        manualChunks: {
          vendor: ['react', 'react-dom'],
          router: ['react-router-dom'],
          ui: ['@headlessui/react', 'framer-motion'],
          forms: ['react-hook-form', '@hookform/resolvers'],
          utils: ['date-fns', 'axios', 'zustand'],
        },
      },
    },
    chunkSizeWarningLimit: 1000,
  },
  server: {
    port: 3000,
    host: true,
    proxy: {
      '/api': {
        target: 'http://localhost:8000',
        changeOrigin: true,
        secure: false,
      },
    },
  },
  optimizeDeps: {
    include: ['react', 'react-dom', 'react-router-dom'],
  },
});
```

### **Environment Configuration**
```typescript
// .env.example
VITE_API_BASE_URL=https://api.ebuildify.com/v1
VITE_CDN_URL=https://cdn.ebuildify.com
VITE_GOOGLE_MAPS_API_KEY=your_google_maps_key
VITE_SENTRY_DSN=your_sentry_dsn
VITE_ENVIRONMENT=development
VITE_ENABLE_ANALYTICS=false
VITE_FLUTTERWAVE_PUBLIC_KEY=your_flutterwave_key

// Environment Types
interface ImportMetaEnv {
  readonly VITE_API_BASE_URL: string;
  readonly VITE_CDN_URL: string;
  readonly VITE_GOOGLE_MAPS_API_KEY: string;
  readonly VITE_SENTRY_DSN: string;
  readonly VITE_ENVIRONMENT: 'development' | 'staging' | 'production';
  readonly VITE_ENABLE_ANALYTICS: string;
  readonly VITE_FLUTTERWAVE_PUBLIC_KEY: string;
}
```

---

## Mobile-Specific Optimizations

### **Touch Interactions**
```typescript
// Touch-Optimized Button Component
const TouchButton: React.FC<{
  children: React.ReactNode;
  onTap?: () => void;
  className?: string;
}> = ({ children, onTap, className }) => {
  const [isPressed, setIsPressed] = useState(false);
  
  return (
    <button
      className={cn(
        'min-h-[44px] min-w-[44px]', // iOS touch target size
        'active:scale-95 transition-transform',
        'touch-manipulation', // Optimize for touch
        isPressed && 'bg-gray-100',
        className
      )}
      onTouchStart={() => setIsPressed(true)}
      onTouchEnd={() => setIsPressed(false)}
      onTouchCancel={() => setIsPressed(false)}
      onClick={onTap}
    >
      {children}
    </button>
  );
};
```

### **Gesture Handling**
```typescript
// Swipe-to-Delete Component
const SwipeableListItem: React.FC<{
  children: React.ReactNode;
  onDelete: () => void;
}> = ({ children, onDelete }) => {
  const [swipeDistance, setSwipeDistance] = useState(0);
  const [startX, setStartX] = useState(0);
  const itemRef = useRef<HTMLDivElement>(null);
  
  const handleTouchStart = (e: React.TouchEvent) => {
    setStartX(e.touches[0].clientX);
  };
  
  const handleTouchMove = (e: React.TouchEvent) => {
    const currentX = e.touches[0].clientX;
    const distance = startX - currentX;
    
    if (distance > 0 && distance < 100) {
      setSwipeDistance(distance);
    }
  };
  
  const handleTouchEnd = () => {
    if (swipeDistance > 50) {
      onDelete();
    } else {
      setSwipeDistance(0);
    }
  };
  
  return (
    <div
      ref={itemRef}
      className="relative overflow-hidden"
      onTouchStart={handleTouchStart}
      onTouchMove={handleTouchMove}
      onTouchEnd={handleTouchEnd}
    >
      <div
        className="transition-transform duration-200"
        style={{ transform: `translateX(-${swipeDistance}px)` }}
      >
        {children}
      </div>
      
      {swipeDistance > 0 && (
        <div
          className="absolute right-0 top-0 h-full bg-red-500 flex items-center px-4"
          style={{ width: `${swipeDistance}px` }}
        >
          <span className="text-white text-sm">Delete</span>
        </div>
      )}
    </div>
  );
};
```

### **Viewport Optimization**
```typescript
// Viewport Manager Hook
export const useViewport = () => {
  const [viewport, setViewport] = useState({
    width: window.innerWidth,
    height: window.innerHeight,
    isMobile: window.innerWidth < 768,
    isTablet: window.innerWidth >= 768 && window.innerWidth < 1024,
    isDesktop: window.innerWidth >= 1024,
  });
  
  useEffect(() => {
    const handleResize = () => {
      const width = window.innerWidth;
      const height = window.innerHeight;
      
      setViewport({
        width,
        height,
        isMobile: width < 768,
        isTablet: width >= 768 && width < 1024,
        isDesktop: width >= 1024,
      });
    };
    
    window.addEventListener('resize', handleResize);
    return () => window.removeEventListener('resize', handleResize);
  }, []);
  
  return viewport;
};
```

---

## Accessibility Features

### **ARIA Labels and Semantic HTML**
```typescript
// Accessible Product Card
const AccessibleProductCard: React.FC<{
  product: Product;
  onAddToCart: (id: string) => void;
}> = ({ product, onAddToCart }) => {
  return (
    <article
      className="product-card"
      role="article"
      aria-labelledby={`product-title-${product.id}`}
      aria-describedby={`product-description-${product.id}`}
    >
      <div className="product-image">
        <img
          src={product.image}
          alt={`${product.name} - ${product.description}`}
          loading="lazy"
        />
      </div>
      
      <div className="product-info">
        <h3 id={`product-title-${product.id}`} className="product-title">
          {product.name}
        </h3>
        
        <p id={`product-description-${product.id}`} className="product-description">
          {product.description}
        </p>
        
        <div className="product-price" aria-label={`Price: ${product.price} cedis per ${product.unit}`}>
          <span className="price">₵{product.price}</span>
          <span className="unit">per {product.unit}</span>
        </div>
        
        <button
          onClick={() => onAddToCart(product.id)}
          aria-label={`Add ${product.name} to cart`}
          className="add-to-cart-button"
        >
          Add to Cart
        </button>
      </div>
    </article>
  );
};
```

### **Keyboard Navigation**
```typescript
// Keyboard Navigation Hook
export const useKeyboardNavigation = (items: any[], onSelect: (item: any) => void) => {
  const [selectedIndex, setSelectedIndex] = useState(-1);
  
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      switch (e.key) {
        case 'ArrowDown':
          e.preventDefault();
          setSelectedIndex(prev => 
            prev < items.length - 1 ? prev + 1 : 0
          );
          break;
          
        case 'ArrowUp':
          e.preventDefault();
          setSelectedIndex(prev => 
            prev > 0 ? prev - 1 : items.length - 1
          );
          break;
          
        case 'Enter':
          if (selectedIndex >= 0) {
            onSelect(items[selectedIndex]);
          }
          break;
          
        case 'Escape':
          setSelectedIndex(-1);
          break;
      }
    };
    
    document.addEventListener('keydown', handleKeyDown);
    return () => document.removeEventListener('keydown', handleKeyDown);
  }, [items, selectedIndex, onSelect]);
  
  return { selectedIndex, setSelectedIndex };
};
```

### **Screen Reader Support**
```typescript
// Screen Reader Announcements
export const useScreenReader = () => {
  const announce = (message: string, priority: 'polite' | 'assertive' = 'polite') => {
    const announcement = document.createElement('div');
    announcement.setAttribute('aria-live', priority);
    announcement.setAttribute('aria-atomic', 'true');
    announcement.setAttribute('class', 'sr-only');
    announcement.textContent = message;
    
    document.body.appendChild(announcement);
    
    setTimeout(() => {
      document.body.removeChild(announcement);
    }, 1000);
  };
  
  return { announce };
};

// Usage in components
const ProductActions = ({ product, onAddToCart }) => {
  const { announce } = useScreenReader();
  
  const handleAddToCart = () => {
    onAddToCart(product.id);
    announce(`${product.name} added to cart`);
  };
  
  return (
    <button onClick={handleAddToCart}>
      Add to Cart
    </button>
  );
};
```

---

## Internationalization (i18n)

### **Multi-language Support**
```typescript
// i18n Configuration
import i18n from 'i18next';
import { initReactI18next } from 'react-i18next';
import Backend from 'i18next-http-backend';

i18n
  .use(Backend)
  .use(initReactI18next)
  .init({
    lng: 'en',
    fallbackLng: 'en',
    debug: process.env.NODE_ENV === 'development',
    
    interpolation: {
      escapeValue: false,
    },
    
    backend: {
      loadPath: '/locales/{{lng}}/{{ns}}.json',
    },
    
    resources: {
      en: {
        common: {
          'add_to_cart': 'Add to Cart',
          'product_name': 'Product Name',
          'price': 'Price',
          'quantity': 'Quantity',
          'total': 'Total',
        },
        products: {
          'cement': 'Cement',
          'iron_rods': 'Iron Rods',
          'bulk_discount': 'Bulk Discount Available',
        },
      },
      tw: {
        common: {
          'add_to_cart': 'Fa kɔ Cart mu',
          'product_name': 'Adeɛ Din',
          'price': 'Boɔ',
          'quantity': 'Dodoɔ',
          'total': 'Nyinaa',
        },
        products: {
          'cement': 'Simento',
          'iron_rods': 'Dadeɛ Dua',
          'bulk_discount': 'Pii a wɔtɔn no, ɛboɔ te',
        },
      },
    },
  });

export default i18n;
```

### **Currency and Number Formatting**
```typescript
// Localization Utilities
export const formatCurrency = (amount: number, locale: string = 'en-GH') => {
  return new Intl.NumberFormat(locale, {
    style: 'currency',
    currency: 'GHS',
    minimumFractionDigits: 2,
  }).format(amount);
};

export const formatNumber = (number: number, locale: string = 'en-GH') => {
  return new Intl.NumberFormat(locale).format(number);
};

// Date Formatting for Ghana
export const formatDate = (date: Date, locale: string = 'en-GH') => {
  return new Intl.DateTimeFormat(locale, {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
  }).format(date);
};
```

---

## Error Handling & Monitoring

### **Error Boundary Component**
```typescript
// Global Error Boundary
class ErrorBoundary extends React.Component<
  { children: React.ReactNode },
  { hasError: boolean; error?: Error }
> {
  constructor(props: { children: React.ReactNode }) {
    super(props);
    this.state = { hasError: false };
  }
  
  static getDerivedStateFromError(error: Error) {
    return { hasError: true, error };
  }
  
  componentDidCatch(error: Error, errorInfo: React.ErrorInfo) {
    console.error('Error caught by boundary:', error, errorInfo);
    
    // Send to monitoring service
    if (import.meta.env.VITE_SENTRY_DSN) {
      // Sentry.captureException(error, { extra: errorInfo });
    }
  }
  
  render() {
    if (this.state.hasError) {
      return (
        <div className="min-h-screen flex items-center justify-center bg-gray-50">
          <div className="max-w-md mx-auto text-center">
            <h1 className="text-2xl font-bold text-gray-900 mb-4">
              Something went wrong
            </h1>
            <p className="text-gray-600 mb-8">
              We're sorry, but something unexpected happened. Please try refreshing the page.
            </p>
            <button
              onClick={() => window.location.reload()}
              className="bg-primary-500 text-white px-6 py-2 rounded-md hover:bg-primary-600"
            >
              Refresh Page
            </button>
          </div>
        </div>
      );
    }
    
    return this.props.children;
  }
}
```

### **API Error Handling**
```typescript
// API Error Handler
export class APIError extends Error {
  constructor(
    message: string,
    public status: number,
    public code: string,
    public details?: any
  ) {
    super(message);
    this.name = 'APIError';
  }
}

// Error Handler Hook
export const useErrorHandler = () => {
  const { announce } = useScreenReader();
  const toast = useToast();
  
  const handleError = (error: unknown) => {
    if (error instanceof APIError) {
      switch (error.status) {
        case 401:
          // Redirect to login
          window.location.href = '/login';
          break;
          
        case 403:
          toast.error('You don\'t have permission to perform this action');
          break;
          
        case 404:
          toast.error('The requested resource was not found');
          break;
          
        case 422:
          toast.error('Please check your input and try again');
          break;
          
        case 500:
          toast.error('Server error. Please try again later');
          break;
          
        default:
          toast.error(error.message || 'An unexpected error occurred');
      }
      
      announce(`Error: ${error.message}`, 'assertive');
    } else {
      toast.error('An unexpected error occurred');
      console.error('Unhandled error:', error);
    }
  };
  
  return { handleError };
};
```

---

## Performance Monitoring

### **Performance Metrics**
```typescript
// Performance Monitor Hook
export const usePerformanceMonitor = () => {
  useEffect(() => {
    // Core Web Vitals
    const observer = new PerformanceObserver((list) => {
      for (const entry of list.getEntries()) {
        if (entry.entryType === 'measure') {
          console.log(`${entry.name}: ${entry.duration}ms`);
          
          // Send to analytics
          if (import.meta.env.VITE_ENABLE_ANALYTICS === 'true') {
            // gtag('event', 'timing_complete', {
            //   name: entry.name,
            //   value: Math.round(entry.duration),
            // });
          }
        }
      }
    });
    
    observer.observe({ entryTypes: ['measure', 'navigation'] });
    
    return () => observer.disconnect();
  }, []);
  
  const measurePerformance = (name: string, fn: () => Promise<any>) => {
    performance.mark(`${name}-start`);
    
    return fn().finally(() => {
      performance.mark(`${name}-end`);
      performance.measure(name, `${name}-start`, `${name}-end`);
    });
  };
  
  return { measurePerformance };
};
```

### **Bundle Analysis**
```typescript
// Bundle Analyzer Configuration
import { defineConfig } from 'vite';
import { visualizer } from 'rollup-plugin-visualizer';

export default defineConfig({
  plugins: [
    // ... other plugins
    visualizer({
      filename: 'dist/stats.html',
      open: true,
      gzipSize: true,
    }),
  ],
});
```

---

## Development Workflow

### **Component Development Template**
```typescript
// Component Template Generator
// scripts/create-component.js

const fs = require('fs');
const path = require('path');

const createComponent = (name, type = 'component') => {
  const componentDir = path.join(__dirname, '../src/components', name);
  
  if (!fs.existsSync(componentDir)) {
    fs.mkdirSync(componentDir, { recursive: true });
  }
  
  // Component file
  const componentContent = `
import React from 'react';
import { cn } from '@/utils/cn';

interface ${name}Props {
  className?: string;
  children?: React.ReactNode;
}

export const ${name}: React.FC<${name}Props> = ({
  className,
  children,
  ...props
}) => {
  return (
    <div className={cn('${name.toLowerCase()}', className)} {...props}>
      {children}
    </div>
  );
};

${name}.displayName = '${name}';
`;

  // Test file
  const testContent = `
import { render, screen } from '@testing-library/react';
import { ${name} } from './${name}';

describe('${name}', () => {
  it('renders correctly', () => {
    render(<${name}>Test content</${name}>);
    expect(screen.getByText('Test content')).toBeInTheDocument();
  });
});
`;

  // Story file
  const storyContent = `
import type { Meta, StoryObj } from '@storybook/react';
import { ${name} } from './${name}';

const meta: Meta<typeof ${name}> = {
  title: 'Components/${name}',
  component: ${name},
  parameters: {
    layout: 'centered',
  },
  tags: ['autodocs'],
};

export default meta;
type Story = StoryObj<typeof meta>;

export const Default: Story = {
  args: {
    children: 'Default ${name}',
  },
};
`;

  fs.writeFileSync(path.join(componentDir, `${name}.tsx`), componentContent);
  fs.writeFileSync(path.join(componentDir, `${name}.test.tsx`), testContent);
  fs.writeFileSync(path.join(componentDir, `${name}.stories.tsx`), storyContent);
  fs.writeFileSync(path.join(componentDir, 'index.ts'), `export { ${name} } from './${name}';`);
  
  console.log(`Component ${name} created successfully!`);
};

// Usage: npm run create-component ComponentName
const componentName = process.argv[2];
if (componentName) {
  createComponent(componentName);
} else {
  console.log('Please provide a component name');
}
```

### **Git Hooks Configuration**
```json
// package.json
{
  "husky": {
    "hooks": {
      "pre-commit": "lint-staged",
      "commit-msg": "commitlint -E HUSKY_GIT_PARAMS"
    }
  },
  "lint-staged": {
    "*.{ts,tsx}": [
      "eslint --fix",
      "prettier --write"
    ],
    "*.{css,scss}": [
      "stylelint --fix",
      "prettier --write"
    ]
  },
  "commitlint": {
    "extends": ["@commitlint/config-conventional"]
  }
}
```

---

## Conclusion

This comprehensive frontend architecture provides a solid foundation for the eBuildify platform with:

### ✅ **Technical Excellence**
- **Modern React Architecture**: Feature-based, scalable structure
- **PWA Capabilities**: Offline functionality for Ghana's connectivity challenges  
- **Performance Optimization**: Mobile-first, 3G-optimized experience
- **Type Safety**: Full TypeScript implementation
- **Testing Strategy**: Unit, integration, and E2E testing coverage

### ✅ **Business Requirements Alignment**
- **User Experience**: Intuitive design inspired by Jumia Ghana
- **Mobile Optimization**: Touch-friendly interfaces for mobile users
- **Accessibility**: WCAG 2.1 compliance for inclusive design
- **Internationalization**: English/Twi language support
- **Ghana-Specific Features**: Ghana Card integration, local payment methods

### ✅ **Development Best Practices**
- **Component-Driven Development**: Reusable, maintainable components
- **State Management**: Efficient client and server state handling
- **Security**: Input sanitization, secure token management
- **Performance Monitoring**: Core Web Vitals tracking
- **Error Handling**: Comprehensive error boundaries and monitoring

### ✅ **Production Readiness**
- **Build Optimization**: Code splitting, lazy loading, bundle analysis
- **Deployment Configuration**: Environment-specific builds
- **Monitoring Integration**: Error tracking, performance metrics
- **SEO Optimization**: Meta tags, structured data, sitemap generation

### **Next Steps**
1. **Design System Implementation**: Create component library with Storybook
2. **API Integration**: Connect frontend components to backend services
3. **Testing Implementation**: Set up Jest, Testing Library, and Playwright
4. **Performance Optimization**: Implement lazy loading and caching strategies
5. **Accessibility Audit**: Ensure WCAG 2.1 AA compliance
6. **User Testing**: Conduct usability testing with target users in Ghana

This architecture ensures the eBuildify platform will deliver a superior user experience while maintaining technical excellence and scalability for future growth.