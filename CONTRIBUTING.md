
# Contributing to Life is Skill iOS App

We are excited that you're interested in contributing to the Life is Skill iOS app! Your contributions help improve the app and bring it closer to the community’s needs. Please take a moment to review the guidelines below to make the process smooth and consistent.

## Table of Contents
- [How to Contribute](#how-to-contribute)
- [Reporting Issues](#reporting-issues)
- [Development Workflow](#development-workflow)
- [Code Guidelines](#code-guidelines)
- [Submitting Pull Requests](#submitting-pull-requests)
- [Code of Conduct](#code-of-conduct)

---

## How to Contribute

1. **Fork the repository**: Fork the project to your own GitHub account by clicking the "Fork" button at the top right of the repository page.
2. **Clone your fork**: Clone the forked repository to your local machine to begin working:
   ```bash
   git clone https://github.com/your-username/lifeisskill.git
   ```
3. **Create a new branch**: Create a new branch to work on your changes:
   ```bash
   git checkout -b feature/AmazingFeature
   ```
4. **Make your changes**: Implement your feature, bug fix, or documentation improvements.
5. **Commit your changes**: Ensure your commit messages follow good practices and are concise:
   ```bash
   git commit -m "Add feature to enable this amazing thing"
   ```
6. **Push your changes**: Push your changes to your forked repository:
   ```bash
   git push origin feature/AmazingFeature
   ```
7. **Submit a pull request**: Go to the original repository and open a pull request to merge your changes.

---

## Reporting Issues

If you find bugs or have feature requests, feel free to open an issue in the GitHub repository.

1. **Check existing issues**: First, check the [issue tracker](https://github.com/k-droscova/lifeisskill/issues) to see if the issue has already been reported.
2. **Submit a new issue**: If the issue hasn’t been reported yet, create a new issue with the following details:
   - Describe the bug or feature request.
   - Provide steps to reproduce the issue (for bugs).
   - Mention the environment (iOS version, device type) if applicable.

---

## Development Workflow

### Setting Up the Project

1. **Clone the repository**:
   ```bash
   git clone https://github.com/k-droscova/lifeisskill.git
   ```
2. **Install dependencies**: Follow the instructions in the [Installation](#installation) section of the `README.md`.
3. **Create a `config.xcconfig` file**: As described in the `README.md`, create your own configuration file for API keys and environment settings.

### Running Tests

Before submitting your changes, ensure that everything works as expected by running tests:

1. **Run unit tests**:
   ```bash
   Cmd + U
   ```
2. **Run UI tests**:
   ```bash
   Cmd + U
   ```

Make sure all tests pass before submitting your pull request.

---

## Code Guidelines

- Follow the **Swift best practices** and **Apple Human Interface Guidelines**.
- Keep your code clean, modular, and easy to understand.
- Write descriptive commit messages.
- Ensure any UI changes match the design and are responsive across different devices (we support both iPhones and iPads with iOS version 16.0 and above)

---

## Submitting Pull Requests

1. **Keep pull requests focused**: Each pull request should address a single feature or issue. Avoid mixing unrelated changes.
2. **Write clear descriptions**: Explain why the change is needed and how it addresses the issue or improves the app.
3. **Link relevant issues**: Reference any GitHub issues that the pull request addresses (e.g., `Fixes #123`).
4. **Rebase before submitting**: Ensure your branch is up to date with the `main` or `master` branch:
   ```bash
   git fetch origin
   git rebase origin/main
   ```
5. **Review feedback**: Be responsive to feedback from maintainers. We may suggest changes or improvements.

---

## Code of Conduct

By participating in this project, you agree to abide by the [Code of Conduct](./CODE_OF_CONDUCT.md). We expect all contributors to uphold a welcoming and respectful environment for everyone involved.

