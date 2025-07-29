# Module 2: Database & Models
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
├