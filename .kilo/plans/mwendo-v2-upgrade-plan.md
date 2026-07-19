# Mwendo v2.0 Upgrade Plan

## Overview
This plan.md improvements needed to prepare the Mwendo running tracker application for version 2.0 release.plan outlines the technical improvements needed to prepare the Mwendo running tracker application for version 2.0 release. The focus areas include data persistence, GPS tracking accuracy, localization, UI/UX improvements, and feature enhancements.

## 1. Data Persistence - Fix Run Data Saving Issue

### Problem Analysis
The app currently uses a JSON file-based approach for activity storage with a stubbed Drift database implementation that needs to be completed.

### Solution
Complete the migration from JSON file storage to proper Drift/SQLite implementation.

### Implementation Steps:
1. Complete Drift Database Setup
   - Run `flutter pub run build_runner build` to generate the Drift implementation
   - Complete the database schema in `tables.dart` with all necessary fields
   - Implement DAOs for Activities, Users, etc.

2. Migrate ActivityRepository to Use Drift
   - Replace JSON file operations with Drift database operations
   - Ensure backward compatibility by migrating existing JSON data to SQLite on first launch

3. Implement Proper Error Handling and Transactions
   - Use Drift's transaction capabilities for data integrity
   - Add proper error handling and logging

### Validation
- Verify that runs persist after app restart
- Verify data integrity through backup/restore testing
- Test with large numbers of activities

## 2. GPS Tracking Accuracy - Fix Jagged Line Issue

### Problem Analysis
The app implements EMA smoothing but users still report jagged lines, indicating need for improved smoothing algorithm.

### Solution
Enhance the GPS smoothing algorithm with adaptive Kalman filtering and improved point selection.

### Implementation Steps:
1. Implement Adaptive Kalman Filter for better GPS smoothing
2. Improve Adaptive Sampling Rate based on motion state
3. Enhance Point Culling Algorithm with distance and angle thresholds
4. Add Motion State Detection to adjust filtering parameters

### Validation
- Test with GPS simulation tools to verify smoothness
- Compare recorded paths against known straight paths
- Test in various environments (urban, suburban, open areas)

## 3. Localization (i18n) - Migrate Hardcoded Strings

### Problem Analysis
The app has a localization system but still contains hardcoded English strings throughout the codebase.

### Solution
Identify all hardcoded strings and replace them with calls to the localization system.

### Implementation Steps:
1. Identify all hardcoded strings using grep/search
2. Add missing translations to `app_strings.dart`
3. Replace hardcoded strings with `L10n.tr('key')` calls
4. Update Semantics labels and accessibility labels
5. Test both languages (English and Swahili)

### Validation
- Verify all UI elements display correctly in both languages
- Check that accessibility services read correct localized text
- Ensure no hardcoded strings remain in production builds

## 4. UI/UX Development

### 4.1 Settings Screen - Debug and Complete Functionality

#### Problem Analysis
Need to examine the current settings implementation to identify what's missing or broken.

#### Solution
Complete the settings screen with all necessary options and proper state management.

#### Implementation Steps:
1. Review current settings implementation
2. Identify missing features (units, themes, notifications, etc.)
3. Implement missing settings options
4. Ensure proper persistence of settings
5. Add proper localization for all settings labels

#### Validation
- Test all settings options for correct functionality
- Verify settings persist after app restart
- Check localization in both languages
- Ensure accessibility compliance

### 4.2 Profile Screen - Design and Implement Robust User Profile

#### Problem Analysis
Need to examine the current profile implementation and enhance it to be more robust and feature-complete.

#### Solution
Create a comprehensive profile screen with edit capabilities, statistics, and achievements.

#### Implementation Steps:
1. Analyze current profile implementation
2. Design enhanced profile UI with tabs/sections
3. Implement profile editing functionality
4. Add statistics and achievements display
5. Integrate with authentication system
6. Add proper localization

#### Validation
- Test UI on different screen sizes
- Verify localization works correctly
- Test form validation and submission
- Ensure accessibility compliance

## 5. Feature Enhancement

### 5.1 Optimize "Race a Ghost" Feature

#### Problem Analysis
Need to examine the current ghost race implementation to identify performance bottlenecks and enhancement opportunities.

#### Solution
Improve the ghost race feature with better performance, smoother animations, and enhanced user feedback.

#### Implementation Steps:
1. Review current ghost race implementation
2. Optimize ghost position calculation for better performance
3. Enhance visual feedback with better animations and UI
4. Add audio cues for motivation
5. Improve ghost rendering on the map

#### Validation
- Measure performance improvements (FPS, memory usage)
- Test visual quality and smoothness
- Verify user feedback mechanisms work correctly
- Ensure battery efficiency

### 5.2 Implement New "Route Planner" Feature

#### Problem Analysis
Need to implement a new feature that allows users to select predefined routes and track their progress relative to those routes.

#### Solution
Create a route planning system with predefined routes, route following guidance, and progress tracking.

#### Implementation Steps:
1. Design route data structure and storage
2. Create route selection UI
3. Implement route following logic
4. Add visual guidance on map
5. Provide progress feedback to user
6. Integrate with existing tracking system

#### Validation
- Test route following accuracy
- Verify UI responsiveness with long routes
- Test offline functionality if applicable
- Ensure battery efficiency with continuous location updates

## 6. Build and Release Process Improvements

### Solution
Enhance the build and release process for better quality assurance.

### Implementation Steps:
1. Set up automated testing (unit, widget, integration tests)
2. Implement CI/CD pipeline with GitHub Actions
3. Add code quality checks (linting, formatting)
4. Create release notes generation process
5. Implement beta testing distribution via Firebase App Store/Google Play Internal Testing

## Risk Assessment and Mitigation

### Risks:
1. **Data Migration Issues** - Risk of losing user data during database migration
   - Mitigation: Implement backup/restore functionality, keep JSON fallback temporarily

2. **Performance Regression** - New features might impact app performance
   - Mitigation: Implement performance benchmarks, use profiling tools

3. **Localization Inconsistencies** - Missing translations leading to mixed language UI
   - Mitigation: Implement automated checks for missing translations

4. **Battery Drain** - Enhanced GPS processing might increase battery usage
   - Mitigation: Optimize algorithms, provide user-configurable accuracy settings

### Timeline:
- **Week 1-2**: Data persistence migration and localization fixes
- **Week 3**: GPS accuracy improvements and settings screen completion
- **Week 4**: Profile screen enhancement and feature development
- **Week 5**: Integration, testing, and polishing
- **Week 6**: Beta testing and final release preparation

## Success Criteria
1. All run data persists correctly across app restarts
2. GPS tracking shows significantly improved smoothness (>50% reduction in jagged appearance)
3. 100% of UI strings are localized (no hardcoded English strings in production)
4. Settings screen is fully functional with all options persisting correctly
5. Profile screen provides comprehensive user information and editing capabilities
6. Race a Ghost feature shows improved performance and user engagement
7. Route Planner feature is fully functional and intuitive to use
8. App passes all automated tests and meets performance benchmarks