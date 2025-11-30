# Task Completion Checklist

## Before Committing Code

### 1. Code Quality
- [ ] Code compiles without errors
- [ ] No new warnings introduced
- [ ] Code follows existing style conventions
- [ ] Complex logic has explanatory comments
- [ ] No debugging code left in (e.g., excessive print statements)
- [ ] No hardcoded test values in production code paths

### 2. Build Verification
```bash
# Verify the project builds successfully
mise x -- tuist build
```

### 3. Dependency Management
If dependencies were modified:
```bash
# Reinstall dependencies
mise x -- tuist install

# Regenerate project
mise x -- tuist generate
```

### 4. Configuration Files
- [ ] No sensitive data in committed files
- [ ] Version numbers updated if needed (`MARKETING_VERSION` in xcconfig)
- [ ] Build number management handled by Fastlane (don't manually increment)

### 5. Asset and Resource Changes
- [ ] New assets added to `Resources/` folder
- [ ] Asset catalog images properly named and configured
- [ ] Resources referenced correctly in code

### 6. Git Hygiene
```bash
# Check what's changed
git status

# Review changes
git diff

# Stage changes
git add .

# Commit with descriptive message
git commit -m "feat: descriptive message in English or Korean"

# Push to remote
git push origin <branch-name>
```

## Before Deploying

### 1. Pre-Deployment Verification
- [ ] All tests pass (if tests exist)
- [ ] App runs on physical device
- [ ] App runs on simulator
- [ ] No crashes on launch
- [ ] Core functionality works as expected
- [ ] AdMob ads loading correctly (or test ads in debug)
- [ ] Firebase configuration intact (`GoogleService-Info.plist`)

### 2. Version Management
- [ ] Update `MARKETING_VERSION` in `Configs/app.release.xcconfig` if releasing new version
- [ ] Fastlane will auto-increment `CURRENT_PROJECT_VERSION` (build number)
- [ ] Changelog/release notes prepared

### 3. Configuration Check
- [ ] Using correct bundle ID: `com.credif.sendadv`
- [ ] Code signing configured for release
- [ ] Provisioning profiles valid
- [ ] Certificates not expired

### 4. Integration Verification
- [ ] Google AdMob integration working
  - FullAd: ca-app-pub-9684378399371172/2975452443
  - Launch: ca-app-pub-9684378399371172/6626536187
  - Native: ca-app-pub-9684378399371172/8770326405
- [ ] Firebase services operational (Crashlytics, Analytics, Messaging, RemoteConfig)
- [ ] Kakao integration functional (if used)
- [ ] Contact permissions handled correctly

### 5. Privacy and Compliance
- [ ] Privacy descriptions up to date in Info.plist:
  - `NSUserTrackingUsageDescription`
  - `NSContactsUsageDescription`
- [ ] App tracking transparency properly implemented
- [ ] Encryption export compliance: `ITSAppUsesNonExemptEncryption` = NO

### 6. TestFlight Deployment
```bash
# Deploy to TestFlight only
fastlane ios release description:'변경사항 설명' isReleasing:false
```

### 7. App Store Deployment
```bash
# Deploy and submit for review
fastlane ios release description:'변경사항 설명' isReleasing:true
```

## After Deployment

### 1. Verify Upload
- [ ] Check App Store Connect for new build
- [ ] Verify build number and version
- [ ] Check for processing errors

### 2. TestFlight Testing
- [ ] Install TestFlight build
- [ ] Verify core functionality
- [ ] Check crash reporting in Firebase
- [ ] Monitor analytics

### 3. App Store Submission (if isReleasing:true)
- [ ] Review submission status in App Store Connect
- [ ] Monitor for review feedback
- [ ] Prepare for potential app review questions

### 4. Post-Release Monitoring
- [ ] Monitor Firebase Crashlytics for crashes
- [ ] Check Firebase Analytics for user behavior
- [ ] Review AdMob performance
- [ ] Watch for user feedback

## Emergency Rollback

If critical issues are discovered:

### 1. Stop Distribution
- Pause TestFlight distribution in App Store Connect
- Contact Apple to halt App Store release if already submitted

### 2. Fix and Redeploy
```bash
# Fix the issue
# Commit the fix
git commit -m "fix: critical issue description"

# Redeploy
fastlane ios release description:'긴급 수정: 문제 설명' isReleasing:false
```

### 3. Communicate
- Notify internal team
- Update TestFlight release notes
- Prepare user communication if needed

## Routine Maintenance

### Weekly/Regular Checks
- [ ] Update dependencies if needed (check for updates)
- [ ] Review Firebase analytics and crashlytics
- [ ] Monitor AdMob revenue and performance
- [ ] Check for OS/Xcode updates compatibility

### Dependency Updates
```bash
# Check Package.resolved for current versions
cat .package.resolved

# Update to latest compatible versions
mise x -- tuist install
mise x -- tuist generate
mise x -- tuist build
```

## Notes
- Build numbers are automatically managed by Fastlane
- GitHub Actions CI/CD runs on every manual trigger
- Always test on physical device before App Store submission
- Keep certificates and provisioning profiles up to date
