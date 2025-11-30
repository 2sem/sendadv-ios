# Suggested Commands

## Setup and Installation

### Initial Setup
```bash
# Install mise (if not already installed)
brew install mise

# Install Tuist
mise install tuist

# Install project dependencies
mise x -- tuist install
```

### Project Generation
```bash
# Generate Xcode workspace and projects
mise x -- tuist generate

# Generate and open in Xcode
mise x -- tuist generate --open
```

## Development Commands

### Build and Clean
```bash
# Build the project
mise x -- tuist build

# Clean build artifacts
mise x -- tuist clean
```

### Tuist Commands
```bash
# Edit Tuist project files
mise x -- tuist edit

# Update dependencies
mise x -- tuist install

# Create dependency graph
mise x -- tuist graph
```

## Deployment

### Fastlane Deployment
```bash
# Install/update Fastlane
sudo gem install fastlane

# Deploy to TestFlight only
fastlane ios release description:'변경사항 설명' isReleasing:false

# Deploy to App Store for review
fastlane ios release description:'변경사항 설명' isReleasing:true
```

### Manual Fastlane Commands
```bash
# Build iOS app
fastlane ios release

# Upload to TestFlight
fastlane ios upload_testflight

# Upload to App Store
fastlane ios upload_appstore
```

## Git Commands (macOS)

### Common Git Operations
```bash
# Check status
git status

# Add changes
git add .

# Commit changes
git commit -m "commit message"

# Push to remote
git push origin <branch-name>

# Pull latest changes
git pull origin <branch-name>

# Create new branch
git checkout -b <branch-name>
```

## Xcode Commands

### Build from Command Line
```bash
# Build workspace
xcodebuild -workspace sendadv.xcworkspace -scheme App -configuration Debug build

# Build for release
xcodebuild -workspace sendadv.xcworkspace -scheme App -configuration Release build

# Clean build
xcodebuild -workspace sendadv.xcworkspace -scheme App clean
```

### Run Tests
```bash
# Run unit tests
xcodebuild test -workspace sendadv.xcworkspace -scheme App -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Debugging and Logs

### View Logs
```bash
# View iOS simulator logs
xcrun simctl spawn booted log stream --predicate 'processImagePath contains "sendadv"'

# View device logs
idevicesyslog
```

## Utility Commands (macOS)

### File Operations
```bash
# List files
ls -la

# Change directory
cd <path>

# Find files
find . -name "*.swift"

# Search in files
grep -r "search term" .
```

### Process Management
```bash
# List running processes
ps aux | grep Xcode

# Kill process
kill -9 <PID>
```

## Environment Information

### System Info
```bash
# Check Xcode version
xcodebuild -version

# Check Swift version
swift --version

# Check Tuist version
mise x -- tuist version

# Check mise tools
mise list
```

## Common Workflows

### After Pulling Changes
```bash
mise x -- tuist install
mise x -- tuist generate
```

### Before Committing
```bash
git status
git add .
git commit -m "descriptive message"
git push
```

### CI/CD Trigger
The GitHub Actions workflow is manually triggered from the GitHub UI with:
- **isReleasing**: true (App Store) or false (TestFlight only)
- **body**: Changelog description
