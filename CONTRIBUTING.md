# Contributing to SelfControl CLI

Thank you for your interest in contributing to SelfControl CLI! This document provides guidelines and information for contributors.

## 🚀 Getting Started

### Prerequisites

- **macOS 12.0+** (required for SelfControl.app integration)
- **Bash 4.0+** (default on macOS)
- **Git** for version control
- **SelfControl.app** installed (for testing)

### Development Setup

1. **Fork and Clone**
   ```bash
   git clone https://github.com/your-username/selfcontrol-cli.git
   cd selfcontrol-cli
   ```

2. **Create Development Branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Run Tests**
   ```bash
   ./tests/test_runner.sh
   ```

## 📋 Development Guidelines

### Code Standards

- **Bash Best Practices**: Follow shell scripting best practices
- **Error Handling**: Use `set -euo pipefail` for strict error handling
- **Input Validation**: Always validate and sanitize user inputs
- **Documentation**: Document all functions and complex logic
- **Testing**: Write tests for new functionality

### File Organization

```
selfcontrol-cli/
├── bin/                    # Main executable
├── lib/                    # Core libraries
├── config/                 # Configuration files and examples
├── docs/                   # Documentation
├── scripts/                # Utility scripts
├── tests/                  # Test suite
└── .github/               # GitHub workflows and templates
```

### Naming Conventions

- **Functions**: Use `snake_case` (e.g., `cmd_schedule_list`)
- **Variables**: Use `UPPER_CASE` for constants, `lower_case` for locals
- **Files**: Use `kebab-case` for scripts, `snake_case` for libraries

## 🧪 Testing

### Running Tests

```bash
# Run all tests
./tests/test_runner.sh

# Run specific test suites
./tests/test_runner.sh basic      # Basic functionality
./tests/test_runner.sh config     # Configuration validation
./tests/test_runner.sh schedule   # Schedule functionality
./tests/test_runner.sh syntax     # Script syntax validation
./tests/test_runner.sh install    # Installation system
```

### Writing Tests

- Add tests for new functionality in `tests/test_runner.sh`
- Follow the existing test structure and naming conventions
- Ensure tests are isolated and don't affect system state
- Test both success and failure scenarios

### Test Requirements

- All tests must pass before submitting PR
- New functionality must include corresponding tests
- Tests should be fast and reliable

## 🔧 Development Workflow

### Feature Development

1. **Plan**: Document the feature in an issue first
2. **Branch**: Create a feature branch from `dev`
3. **Develop**: Implement with tests
4. **Test**: Run full test suite
5. **Document**: Update documentation as needed
6. **Submit**: Create pull request

### Bug Fixes

1. **Reproduce**: Create a test that reproduces the bug
2. **Fix**: Implement the fix
3. **Verify**: Ensure the test passes
4. **Submit**: Create pull request with test

### Pull Request Process

1. **Fork** the repository
2. **Create** a feature branch
3. **Commit** changes with clear messages
4. **Push** to your fork
5. **Submit** a pull request

### Commit Message Format

```
type(scope): brief description

Detailed description of changes

Fixes #issue-number
```

Types: `feat`, `fix`, `docs`, `test`, `refactor`, `chore`

## 📚 Documentation

### Code Documentation

- **Function Headers**: Document purpose, parameters, and return values
- **Complex Logic**: Add inline comments for complex algorithms
- **Examples**: Include usage examples in function documentation

### User Documentation

- **README**: Keep installation and usage instructions current
- **API Docs**: Update `docs/API.md` for new commands
- **Troubleshooting**: Add common issues to `docs/TROUBLESHOOTING.md`

## 🐛 Bug Reports

### Before Submitting

1. **Search** existing issues
2. **Test** on latest version
3. **Gather** system information

### Bug Report Template

```markdown
**Describe the bug**
A clear description of what the bug is.

**To Reproduce**
Steps to reproduce the behavior:
1. Run command '...'
2. See error

**Expected behavior**
What you expected to happen.

**System Information**
- macOS version:
- SelfControl CLI version:
- SelfControl.app version:

**Additional context**
Any other relevant information.
```

## ✨ Feature Requests

### Before Submitting

1. **Search** existing feature requests
2. **Consider** if it fits the project scope
3. **Think** about implementation complexity

### Feature Request Template

```markdown
**Is your feature request related to a problem?**
A clear description of what the problem is.

**Describe the solution you'd like**
A clear description of what you want to happen.

**Describe alternatives you've considered**
Alternative solutions or workarounds.

**Additional context**
Any other context about the feature request.
```

## 🔒 Security

### Reporting Security Issues

- **DO NOT** open public issues for security vulnerabilities
- **Email** security issues to: security@selfcontrol-cli.com
- **Include** detailed reproduction steps
- **Wait** for acknowledgment before public disclosure

### Security Guidelines

- **Input Validation**: Always validate user inputs
- **Path Traversal**: Prevent directory traversal attacks
- **Command Injection**: Sanitize inputs to prevent injection
- **File Permissions**: Use appropriate file permissions

## 📋 Code Review Process

### For Contributors

- **Self Review**: Review your own code before submitting
- **Test Coverage**: Ensure adequate test coverage
- **Documentation**: Update documentation as needed
- **Responsive**: Respond to review feedback promptly

### For Maintainers

- **Timely Reviews**: Aim for reviews within 48 hours
- **Constructive Feedback**: Provide helpful, actionable feedback
- **Test Verification**: Ensure tests pass before merging
- **Documentation**: Verify documentation updates

## 🏷️ Release Process

### Version Numbering

- **Major**: Breaking changes
- **Minor**: New features (backward compatible)
- **Patch**: Bug fixes (backward compatible)

### Release Checklist

- [ ] All tests pass
- [ ] Documentation updated
- [ ] Changelog updated
- [ ] Version bumped
- [ ] Tagged and released

## 🤝 Community Guidelines

### Code of Conduct

- **Be Respectful**: Treat everyone with respect
- **Be Constructive**: Provide helpful feedback
- **Be Patient**: Remember that contributors are volunteers
- **Be Inclusive**: Welcome contributors of all backgrounds

### Getting Help

- **GitHub Issues**: For bugs and feature requests
- **GitHub Discussions**: For questions and community support
- **Documentation**: Check existing docs first

## 📞 Contact

- **Maintainer**: [Your Name](mailto:your-email@example.com)
- **GitHub**: [@your-username](https://github.com/your-username)
- **Project**: [SelfControl CLI](https://github.com/aristeoibarra/selfcontrol-cli)

## 📄 License

By contributing to SelfControl CLI, you agree that your contributions will be licensed under the MIT License.

---

Thank you for contributing to SelfControl CLI! 🎉
