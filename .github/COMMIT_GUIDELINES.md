# Commit Message Guidelines

This project follows the [Conventional Commits](https://www.conventionalcommits.org/) specification for clear, semantic commit messages.

## Commit Message Format

```
<type>(<scope>): <subject>

[optional body]

[optional footer]
```

## Types

| Type | Description | When to Use |
|------|-------------|-------------|
| `feat` | New feature | Adding new functionality |
| `fix` | Bug fix | Fixing a bug or error |
| `docs` | Documentation | Changes to documentation only |
| `style` | Code style | Formatting, whitespace, semicolons (no code change) |
| `refactor` | Code refactoring | Restructuring code without changing behavior |
| `perf` | Performance | Improving performance |
| `test` | Tests | Adding or updating tests |
| `chore` | Maintenance | Build process, dependencies, tooling |
| `ci` | CI/CD | Changes to CI/CD configuration |
| `build` | Build system | Changes affecting build system |
| `revert` | Revert | Reverting a previous commit |

## Scopes

Common scopes for this Strapi project:

| Scope | Description |
|-------|-------------|
| `api` | API routes, controllers, services |
| `content-types` | Content type schemas |
| `components` | Shared components |
| `config` | Configuration files |
| `database` | Database configuration or migrations |
| `admin` | Admin panel customizations |
| `plugins` | Plugin-related changes |
| `docker` | Docker configuration |
| `ci` | CI/CD pipeline |
| `deps` | Dependencies updates |

## Examples

### Feature Addition
```bash
git commit -m "feat(api): add endpoint for article search

Implements full-text search across article titles and descriptions
using PostgreSQL's tsvector capabilities.

Closes #123"
```

### Bug Fix
```bash
git commit -m "fix(content-types): correct author relation in article schema

The hasMany relation was incorrectly configured as oneToOne,
causing issues when associating multiple articles to an author."
```

### Documentation
```bash
git commit -m "docs: add CI/CD setup instructions

Created comprehensive guide for configuring GitHub Actions
pipeline with Docker Hub and AWS EC2 deployment options."
```

### Configuration Change
```bash
git commit -m "chore(config): update database pool configuration

Increased max connections from 10 to 25 to handle higher traffic."
```

### CI/CD Updates
```bash
git commit -m "ci: add health checks to EC2 deployment

Implements 60-second health check after deployment to verify
application is running correctly before completing workflow."
```

### Dependency Updates
```bash
git commit -m "chore(deps): upgrade strapi to 5.24.1

Updates Strapi core and related plugins to latest stable version.
Includes security patches and performance improvements."
```

### Breaking Changes
```bash
git commit -m "feat(api)!: change article API response structure

BREAKING CHANGE: Article API now returns nested author object
instead of author ID. Update client code to handle new structure.

Before:
{
  "title": "Post Title",
  "author": 1
}

After:
{
  "title": "Post Title",
  "author": {
    "id": 1,
    "name": "Author Name"
  }
}"
```

## Commit Message Rules

### Subject Line
- Use imperative mood ("add" not "added" or "adds")
- Don't capitalize first letter
- No period at the end
- Maximum 72 characters
- Be concise but descriptive

✅ **Good:**
- `feat(api): add article search endpoint`
- `fix(admin): resolve pagination issue in media library`
- `refactor(services): extract common validation logic`

❌ **Bad:**
- `Added new feature` (past tense, no type/scope)
- `Fix bug.` (too vague, unnecessary period)
- `Updated the article API endpoint to support new search functionality with filters` (too long)

### Body (Optional)
- Separate from subject with blank line
- Explain what and why, not how
- Wrap at 72 characters
- Can include multiple paragraphs

### Footer (Optional)
- Reference issues: `Closes #123`, `Fixes #456`
- Note breaking changes: `BREAKING CHANGE: description`
- Credit co-authors: `Co-authored-by: Name <email>`

## Quick Commands

### Standard Commit
```bash
git add .
git commit -m "type(scope): description"
```

### Commit with Body
```bash
git commit -m "type(scope): description

More detailed explanation of the changes.
Can span multiple lines."
```

### Multi-line Commit (Interactive)
```bash
git commit
# Opens editor for detailed message
```

## Pre-commit Checklist

Before committing, ensure:
- [ ] Code builds successfully (`npm run build`)
- [ ] No linting errors (if ESLint configured)
- [ ] Tests pass (if tests exist)
- [ ] Commit message follows conventions
- [ ] Changes are focused and atomic
- [ ] Sensitive data is not committed

## Atomic Commits

Make small, focused commits rather than large ones:

✅ **Good:**
```bash
git commit -m "feat(api): add article search endpoint"
git commit -m "test(api): add tests for article search"
git commit -m "docs(api): document article search endpoint"
```

❌ **Bad:**
```bash
git commit -m "feat(api): add search, update tests, fix bugs, update docs"
```

## Amending Commits

If you need to modify the last commit:

```bash
# Change commit message
git commit --amend -m "new message"

# Add forgotten files
git add forgotten-file.js
git commit --amend --no-edit
```

⚠️ **Warning:** Never amend commits that have been pushed to shared branches!

## Reverting Commits

If you need to undo a commit:

```bash
# Create a new commit that undoes changes
git revert <commit-hash>

# Use conventional commit format
git revert <commit-hash> -m "revert: undo article search endpoint

This reverts commit abc123. The feature caused performance
issues in production."
```

## Tools and Automation

### Commitizen (Recommended)
Interactive tool for generating conventional commits:

```bash
npm install -g commitizen cz-conventional-changelog

# Use it
git cz
```

### Commitlint (Optional)
Automatically enforce commit message conventions:

```bash
npm install --save-dev @commitlint/cli @commitlint/config-conventional
```

## Resources

- [Conventional Commits Specification](https://www.conventionalcommits.org/)
- [How to Write Good Commit Messages](https://chris.beams.io/posts/git-commit/)
- [Semantic Versioning](https://semver.org/)

---

**Remember:** Good commit messages are a love letter to your future self and teammates. Take the extra minute to write them well!
