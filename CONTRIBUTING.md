# Contributing to Ultimate Bashrc Ecosystem

First off, thank you for considering contributing to the Ultimate Bashrc Ecosystem! 🎉

This project aims to be the most comprehensive and intelligent Bash configuration system, and contributions from the community are what make it truly ultimate.

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
- [Development Setup](#development-setup)
- [Module Development Guidelines](#module-development-guidelines)
- [Coding Standards](#coding-standards)
- [Testing](#testing)
- [Pull Request Process](#pull-request-process)
- [Community](#community)

## 📜 Code of Conduct

This project adheres to a Code of Conduct that all contributors are expected to follow:

- Be respectful and inclusive
- Welcome newcomers and help them get started
- Focus on constructive criticism
- Accept feedback gracefully
- Prioritize the community's best interests

## 🤝 How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check existing issues to avoid duplicates. When creating a bug report, include:

- **Clear title and description**
- **Steps to reproduce**
- **Expected behavior**
- **Actual behavior**
- **System information** (OS, Bash version, etc.)
- **Relevant logs or error messages**

### Suggesting Enhancements

Enhancement suggestions are welcome! Please provide:

- **Use case** - Why is this enhancement needed?
- **Proposed solution** - How should it work?
- **Alternatives considered** - What other solutions did you think about?
- **Additional context** - Screenshots, mockups, etc.

### Contributing Code

1. **Fix bugs** - Look for issues labeled `bug`
2. **Add features** - Check issues labeled `enhancement`
3. **Improve documentation** - Help others understand the project
4. **Create new modules** - Extend the ecosystem
5. **Optimize performance** - Make things faster
6. **Add tests** - Improve reliability

## 🛠️ Development Setup

### Prerequisites

```bash
# Required
- Bash 4.0+
- Git
- Basic Unix tools (grep, sed, awk)

# Recommended for testing
- Docker
- shellcheck
- bats (Bash Automated Testing System)
```

### Setup Development Environment

```bash
# Fork the repository on GitHub

# Clone your fork
git clone https://github.com/YOUR_USERNAME/Ultimate-BashRC-Ecosystem.git
cd Ultimate-BashRC-Ecosystem

# Add upstream remote
git remote add upstream https://github.com/dnoice/Ultimate-BashRC-Ecosystem.git

# Create development branch
git checkout -b feature/your-feature-name

# Install in development mode
./install.sh --dev
```

## 📦 Module Development Guidelines

### Module Structure

```bash
#!/bin/bash
# =============================================================================
# ULTIMATE BASHRC ECOSYSTEM - MODULE NAME
# File: XX_module-name.sh
# =============================================================================
# Brief description of what this module does
# =============================================================================

# Module metadata (required)
declare -r MODULE_NAME_VERSION="1.0.0"
declare -r MODULE_NAME="Module Name"
declare -r MODULE_AUTHOR="Your Name"

# Module initialization
echo -e "${BASHRC_CYAN}🔧 Loading $MODULE_NAME...${BASHRC_NC}"

# ===========================
# MODULE FUNCTIONS
# ===========================

# Function with documentation
# Usage: function_name [OPTIONS] ARGUMENTS
# Description: What this function does
function_name() {
    local arg1="$1"
    # Implementation
}

# ===========================
# MODULE INITIALIZATION
# ===========================

# Export functions
export -f function_name

# Create aliases
alias fn='function_name'

# Module completion message
echo -e "${BASHRC_GREEN}✅ $MODULE_NAME Loaded${BASHRC_NC}"
```

### Module Guidelines

1. **Naming Convention**
   - Files: `XX_module-name.sh` (XX = two-digit number)
   - Functions: `module_function_name` (snake_case)
   - Variables: `MODULE_VARIABLE` (UPPER_SNAKE_CASE for exports)

2. **Dependencies**
   - Minimize external dependencies
   - Check for required commands
   - Provide fallbacks when possible

3. **Performance**
   - Avoid heavy operations during sourcing
   - Use lazy loading for expensive functions
   - Cache results when appropriate

4. **Error Handling**
   - Always check command success
   - Provide meaningful error messages
   - Don't exit the shell on errors

5. **Documentation**
   - Include usage examples
   - Document all exported functions
   - Add help functions for complex features

## 📝 Coding Standards

### Shell Script Best Practices

```bash
# Use strict mode
set -euo pipefail

# Quote variables
echo "$variable"  # Good
echo $variable    # Bad

# Use [[ ]] for conditionals
[[ -f "$file" ]]  # Good
[ -f "$file" ]    # Okay but less robust

# Check command existence
if command -v git &> /dev/null; then
    # git is available
fi

# Use local variables in functions
function_name() {
    local var="value"
}

# Handle errors gracefully
command || {
    echo "Error: Command failed" >&2
    return 1
}
```

### Color Usage

```bash
# Use predefined colors
echo -e "${BASHRC_GREEN}Success${BASHRC_NC}"
echo -e "${BASHRC_RED}Error${BASHRC_NC}"
echo -e "${BASHRC_YELLOW}Warning${BASHRC_NC}"
echo -e "${BASHRC_CYAN}Info${BASHRC_NC}"
```

### Comments and Documentation

```bash
# Section headers
# =============================================================================
# SECTION NAME
# =============================================================================

# Function documentation
# Description: Brief description of function
# Usage: function_name [OPTIONS] ARGUMENTS
# Arguments:
#   $1 - Description of first argument
#   $2 - Description of second argument
# Returns:
#   0 - Success
#   1 - Error
# Example:
#   function_name "arg1" "arg2"
```

## 🧪 Testing

### Running Tests

```bash
# Run shellcheck on all modules
shellcheck modules/*.sh

# Run unit tests (if available)
./test-suite.sh

# Test installation
./install.sh --test

# Test specific module
source modules/XX_module-name.sh
module_function_test
```

### Writing Tests

Create test files in `tests/` directory:

```bash
#!/usr/bin/env bats

@test "function_name returns success" {
    source ../modules/XX_module-name.sh
    run function_name "test"
    [ "$status" -eq 0 ]
}

@test "function_name handles errors" {
    source ../modules/XX_module-name.sh
    run function_name --invalid
    [ "$status" -eq 1 ]
}
```

## 🚀 Pull Request Process

1. **Update your fork**
   ```bash
   git fetch upstream
   git checkout main
   git merge upstream/main
   ```

2. **Create feature branch**
   ```bash
   git checkout -b feature/your-feature
   ```

3. **Make changes**
   - Write clean, documented code
   - Follow coding standards
   - Add tests if applicable

4. **Test thoroughly**
   ```bash
   # Test your changes
   ./install.sh
   source ~/.bashrc
   
   # Run tests
   shellcheck your-files.sh
   ```

5. **Commit with clear messages**
   ```bash
   git add .
   git commit -m "feat: Add amazing feature
   
   - Detailed description
   - What problem it solves
   - How it works"
   ```

6. **Push and create PR**
   ```bash
   git push origin feature/your-feature
   ```
   Then create a Pull Request on GitHub

### PR Guidelines

- **Title**: Clear and descriptive
- **Description**: Explain what, why, and how
- **Testing**: Describe how you tested
- **Screenshots**: Include if UI-related
- **Breaking changes**: Clearly document

### Commit Message Format

```
type: Brief description

Longer explanation if needed.

Fixes #123
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `style`: Formatting
- `refactor`: Code restructuring
- `test`: Testing
- `chore`: Maintenance

## 🌟 Community

### Getting Help

- **Issues**: [GitHub Issues](https://github.com/dnoice/Ultimate-BashRC-Ecosystem/issues)
- **Discussions**: [GitHub Discussions](https://github.com/dnoice/Ultimate-BashRC-Ecosystem/discussions)
- **Wiki**: [Project Wiki](https://github.com/dnoice/Ultimate-BashRC-Ecosystem/wiki)

### Recognition

Contributors will be:
- Listed in the README
- Credited in release notes
- Given collaborator access (for regular contributors)

## 📚 Additional Resources

- [Bash Manual](https://www.gnu.org/software/bash/manual/)
- [Shell Style Guide](https://google.github.io/styleguide/shellguide.html)
- [Bash Pitfalls](https://mywiki.wooledge.org/BashPitfalls)
- [ShellCheck](https://www.shellcheck.net/)

---

Thank you for contributing to make the Ultimate Bashrc Ecosystem even more ultimate! 🚀
