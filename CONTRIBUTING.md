# Contributing to Qibla Compass Offline

Thank you for considering contributing to Qibla Compass Offline! This document provides guidelines and instructions for contributing.

## Code of Conduct

- Be respectful and inclusive
- Focus on constructive feedback
- Help create a positive environment for all contributors

## How to Contribute

### Reporting Bugs

1. Check if the bug has already been reported in Issues
2. If not, create a new issue with:
   - Clear title and description
   - Steps to reproduce
   - Expected vs actual behavior
   - Screenshots if applicable
   - Device and OS information
   - App version

### Suggesting Features

1. Check if the feature has been suggested
2. Create a new issue with:
   - Clear description of the feature
   - Use cases and benefits
   - Possible implementation approach
   - Mockups or examples if applicable

### Pull Requests

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature-name`
3. Make your changes following our coding standards
4. Test thoroughly on both Android and iOS
5. Commit with clear messages: `git commit -m 'Add: feature description'`
6. Push to your fork: `git push origin feature/your-feature-name`
7. Open a Pull Request with:
   - Clear description of changes
   - Related issue numbers
   - Screenshots/videos if UI changes
   - Testing done

## Development Setup

1. Install Flutter SDK 3.8.1+
2. Clone the repository
3. Run `flutter pub get`
4. Run `flutter run` to test

## Coding Standards

### File Organization
- Follow the structure in PROJECT_STRUCTURE.md
- Place files in appropriate folders
- Use feature-based organization

### Naming Conventions
- Files: `snake_case.dart`
- Classes: `PascalCase`
- Variables/Functions: `camelCase`
- Constants: `SCREAMING_SNAKE_CASE` or `camelCase` for private

### Code Style
- Follow Dart style guide
- Use `flutter analyze` to check for issues
- Format code with `dart format .`
- Use meaningful variable names
- Add comments for complex logic
- Keep functions small and focused

### State Management
- Use GetX controllers for state
- Use GetX bindings for dependency injection
- Keep business logic in controllers
- Keep UI code in views

### Best Practices
1. **Error Handling**: Always handle errors gracefully
2. **Logging**: Use Logger utility instead of print
3. **Performance**: Optimize for low-end devices
4. **Offline Support**: Ensure features work offline when possible
5. **Accessibility**: Follow accessibility guidelines
6. **Testing**: Write tests for critical functionality
7. **Documentation**: Document complex code and APIs

### Commit Messages
Use conventional commits format:
- `Add: new feature`
- `Fix: bug description`
- `Update: changes to existing feature`
- `Refactor: code improvements`
- `Docs: documentation changes`
- `Style: formatting changes`
- `Test: test additions or changes`
- `Chore: maintenance tasks`

## Testing

### Before Submitting PR
- [ ] Code compiles without errors
- [ ] No analyzer warnings
- [ ] Tested on Android
- [ ] Tested on iOS (if applicable)
- [ ] Tested on different screen sizes
- [ ] Tested offline functionality
- [ ] No performance regressions
- [ ] UI follows Material Design 3

### Running Tests
```bash
flutter test
flutter analyze
dart format --set-exit-if-changed .
```

## Code Review Process

1. Maintainers will review your PR
2. Address any requested changes
3. Once approved, PR will be merged
4. Your contribution will be acknowledged

## Areas for Contribution

### High Priority
- Bug fixes
- Performance improvements
- Accessibility improvements
- Test coverage
- Documentation

### Feature Ideas
- Additional prayer time calculation methods
- More Quran features (translations, tafsir)
- Customizable themes
- Widget support
- Apple Watch support
- Wear OS support

### Documentation
- Improve README
- Add code comments
- Create tutorials
- Translate documentation

## Questions?

Feel free to:
- Open an issue for questions
- Join discussions
- Ask in pull request comments

## Recognition

Contributors will be:
- Listed in CONTRIBUTORS.md
- Mentioned in release notes
- Acknowledged in the app (for significant contributions)

Thank you for contributing to Qibla Compass Offline! 🙏
