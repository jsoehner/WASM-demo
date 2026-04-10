# CI/CD Setup for WASM Agent Viewer

This document describes the GitHub Actions workflows used to build, test, and release the WASM Agent Viewer packages.

## Workflows Overview

### 1. `build-and-release-viewer.yml` - Main Release Workflow

**Purpose:** Complete automated pipeline for building, testing, and releasing viewer packages.

**Triggers:**
- Push to `main` branch (builds and tests only)
- Tag push with `v*` pattern (creates full release)
- Pull requests to `main` (builds and tests)
- Manual trigger with release type selection

**Jobs:**
1. **build-and-package** - Builds WASM and creates distribution packages
2. **test-distribution** - Tests the created packages
3. **create-release** - Creates GitHub releases (tag-triggered only)
4. **nightly-release** - Creates nightly releases (manual trigger only)

**Artifacts:**
- `viewer-distribution-{run_id}` - Complete distribution directory
- `viewer-zip-package` - ZIP archive
- `viewer-tar-gz-package` - TAR.GZ archive

### 2. `manual-build-viewer.yml` - Manual Build Workflow

**Purpose:** On-demand building of viewer packages without creating releases.

**Triggers:**
- Manual workflow dispatch only

**Features:**
- Builds WASM module
- Creates distribution packages
- Optional artifact upload (7-day retention)
- No releases or testing

### 3. Legacy Workflows

The following workflows are kept for compatibility but may be deprecated:

- `build-wasm.yml` - Basic WASM building
- `build-viewer.yml` - Multi-platform WASM building
- `build-windows-x64.yml` - Windows-specific building
- `build-and-deploy.yml` - Basic build and deploy

## Usage

### Creating a Release

1. **Automatic Release:**
   ```bash
   ./release.sh patch  # or minor/major
   ```

2. **Manual Tag:**
   ```bash
   git tag v1.2.3
   git push origin v1.2.3
   ```

3. **Nightly Release:**
   - Go to GitHub Actions
   - Run "Build and Release Viewer Packages"
   - Select "nightly" release type

### Manual Build

1. Go to GitHub Actions tab
2. Select "Manual Build Viewer Packages"
3. Click "Run workflow"
4. Choose whether to upload artifacts
5. Download artifacts from the completed workflow

## Workflow Details

### Build Process

1. **Setup Environment:**
   - Install Rust toolchain with WASM target
   - Cache Rust dependencies
   - Install wasm-pack

2. **Build WASM:**
   - Compile Rust to WebAssembly
   - Generate JavaScript bindings
   - Output to `viewer/pkg/`

3. **Package Distribution:**
   - Run `package-viewer.sh`
   - Create `dist/` directory with all files
   - Generate ZIP and TAR.GZ archives

4. **Test Distribution:**
   - Extract packages
   - Test server startup
   - Verify required files exist
   - Check web interface accessibility

5. **Create Release:**
   - Upload packages to GitHub releases
   - Generate release notes
   - Set appropriate prerelease flags

## Configuration

### Environment Variables

- `CARGO_TERM_COLOR: always` - Enable colored cargo output

### Permissions

- `contents: write` - Required for creating releases
- `packages: write` - Required for package uploads

### Artifact Retention

- Release artifacts: 30 days
- Manual build artifacts: 7 days

## Troubleshooting

### Workflow Fails

1. **Check Rust/WASM setup:**
   - Ensure `wasm32-unknown-unknown` target is installed
   - Verify wasm-pack installation

2. **Packaging issues:**
   - Check that `package-viewer.sh` is executable
   - Verify all required files exist

3. **Release creation:**
   - Ensure GITHUB_TOKEN has proper permissions
   - Check tag format (must start with 'v')

### Manual Testing

To test workflows locally before pushing:

```bash
# Test the build process
./build-and-package.sh

# Test the packaging
./package-viewer.sh

# Test the distribution
cd dist && ./start-server.sh
```

## File Structure

```
.github/workflows/
├── build-and-release-viewer.yml    # Main release workflow
├── manual-build-viewer.yml         # Manual build workflow
├── build-wasm.yml                  # Legacy WASM build
├── build-viewer.yml                # Legacy viewer build
├── build-windows-x64.yml           # Legacy Windows build
└── build-and-deploy.yml            # Legacy deploy workflow
```

## Release Process

1. **Development:** Make changes on feature branches
2. **Testing:** Create pull requests to trigger builds
3. **Release:** Merge to main and create version tags
4. **Distribution:** Automated releases with downloadable packages

## Security Notes

- Workflows use `actions/checkout@v4` for secure code checkout
- `GITHUB_TOKEN` is automatically provided by GitHub
- No sensitive data is stored in workflow files
- Artifacts are automatically cleaned up after retention period