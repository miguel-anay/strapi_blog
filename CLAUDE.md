# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Strapi v5.24.1 TypeScript application for content management with a blog-focused content model.

## Development Commands

### Core Commands
```bash
npm run develop      # Start development server with auto-reload on port 1337
npm run build        # Build admin panel (outputs to dist/)
npm run start        # Start production server (no auto-reload)
npm run seed:example # Seed database with example data (runs scripts/seed.js)
npm run console      # Access Strapi console for direct API interaction
npm run deploy       # Deploy to Strapi Cloud
```

### Upgrade Commands
```bash
npm run upgrade      # Upgrade Strapi to latest version
npm run upgrade:dry  # Dry run of Strapi upgrade
```

## Architecture

### Content Types Structure

APIs are organized in `src/api/` following Strapi's MVC pattern:
- `content-types/[name]/schema.json` - Schema definitions with attributes, relations, and validations
- `controllers/` - Request handlers (optional, defaults provided)
- `services/` - Business logic layer (optional, defaults provided)
- `routes/` - URL routing configuration (optional, defaults provided)

Current content types:
- **article** - Blog posts with title, description, slug, cover media, author relation, categories relation, and dynamic blocks
- **author** - Authors with avatar and articles relation
- **category** - Article categories
- **about** - About page content
- **global** - Site-wide settings (singleton)
- **cv** - CV/resume content
- **inicio** - Homepage content

### Shared Components

Located in `src/components/shared/`:
- **media** - Single media component
- **slider** - Image slider/gallery
- **rich-text** - Rich text blocks (uses Strapi's blocks field type)
- **quote** - Quote blocks
- **code** - Code snippet blocks
- **seo** - SEO metadata component

These components are used in dynamic zones (e.g., `article.blocks`).

### Configuration

Configuration files in `config/`:
- `database.ts` - Multi-database support (SQLite default, PostgreSQL, MySQL) with environment-based client selection
- `server.ts` - Host, port, and app keys configuration
- `admin.ts` - Admin panel configuration
- `middlewares.ts` - Middleware stack configuration
- `api.ts` - REST/GraphQL API configuration
- `plugins.ts` - Plugin configuration

### Database Configuration

The `config/database.ts` file supports three database clients:
- **sqlite** (default) - File at `.tmp/data.db`, good for development
- **postgres** - Configured via `DATABASE_URL` or individual connection params
- **mysql** - Configured via environment variables

Switch databases by setting `DATABASE_CLIENT` in `.env`.

### TypeScript Configuration

- Target: ES2019, Module: CommonJS
- Strict mode disabled (`strict: false`)
- Output directory: `dist/`
- Excludes: node_modules, dist, .cache, .tmp, src/admin, test files, and src/plugins

### Application Lifecycle

`src/index.ts` provides two hooks:
- `register()` - Runs before app initialization for extending code
- `bootstrap()` - Runs before app starts for data model setup, jobs, or special logic

### Data Seeding

`scripts/seed.js` provides a comprehensive seeding system:
- Imports categories, authors, articles, global settings, and about page
- Handles file uploads (checks for existing files before uploading)
- Processes dynamic blocks (media, slider components)
- Sets public permissions for content types
- Prevents re-importing if data already exists (checks `initHasRun` flag)

Run with `npm run seed:example` after starting Strapi at least once.

## Environment Variables

Key variables in `.env`:
- `HOST` / `PORT` - Server configuration (default: 0.0.0.0:1337)
- `APP_KEYS` - Comma-separated security keys
- `API_TOKEN_SALT`, `ADMIN_JWT_SECRET`, `JWT_SECRET`, `TRANSFER_TOKEN_SALT` - Security tokens
- `ENCRYPTION_KEY` - Encryption key for sensitive data
- `DATABASE_CLIENT` - Database client (sqlite/postgres/mysql)
- `DATABASE_*` - Database connection parameters

## Admin Panel

Access at `http://localhost:1337/admin` when running. First run requires creating an admin user.

## Key Dependencies

- `@strapi/strapi` v5.24.1 - Core framework
- `better-sqlite3` - SQLite adapter
- `strapi-code-editor-custom-field` - Code editor custom field
- TypeScript, React 18 - Development and admin panel
