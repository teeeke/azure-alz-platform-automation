# Branch Strategy Documentation

## Branch Structure
- `main` - Production-ready code
- `develop` - Main development branch
- `feature/*` - New features and improvements
- `hotfix/*` - Emergency fixes for production
- `release/*` - Release candidates

## Branch Rules

### Main Branch (main)
- Protected branch
- No direct commits
- Requires pull request with reviews
- Must be up-to-date before merging
- CI/CD must pass

### Development Branch (develop)
- Protected branch
- No direct commits
- Requires pull request with at least one review
- Must be up-to-date before merging
- CI/CD must pass

### Feature Branches (feature/*)
- Created from: develop
- Merge into: develop
- Naming: feature/description-of-feature
- Delete after merge

### Hotfix Branches (hotfix/*)
- Created from: main
- Merge into: main and develop
- Naming: hotfix/description-or-issue-number
- Delete after merge

### Release Branches (release/*)
- Created from: develop
- Merge into: main and develop
- Naming: release/version-number
- Delete after merge

## Workflow

1. **Feature Development**
   ```bash
   git checkout develop
   git pull
   git checkout -b feature/new-feature
   # Make changes
   git commit -m "feat: description"
   git push origin feature/new-feature
   # Create PR to develop
   ```

2. **Hotfix Process**
   ```bash
   git checkout main
   git pull
   git checkout -b hotfix/issue-description
   # Make fixes
   git commit -m "fix: description"
   git push origin hotfix/issue-description
   # Create PR to main AND develop
   ```

3. **Release Process**
   ```bash
   git checkout develop
   git pull
   git checkout -b release/1.0.0
   # Make release preparations
   git commit -m "chore: release 1.0.0"
   git push origin release/1.0.0
   # Create PR to main AND develop
   ```

## Commit Message Format
Follow [Conventional Commits](https://www.conventionalcommits.org/):
- feat: New feature
- fix: Bug fix
- docs: Documentation changes
- style: Formatting changes
- refactor: Code restructuring
- test: Adding/modifying tests
- chore: Maintenance tasks

## Pull Request Process
1. Update documentation
2. Update tests if needed
3. Ensure CI/CD passes
4. Request review
5. Address feedback
6. Squash and merge
