# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Passenger-docker is a set of Docker images designed as base images for Ruby, Python, Node.js, and Meteor web applications. These images are built on top of baseimage-docker and include Phusion Passenger as the application server.

## Architecture Overview

The project creates multiple Docker image variants:

1. **Language-specific images**: `passenger-ruby32`, `passenger-ruby33`, `passenger-ruby34`, `passenger-python39-313`, `passenger-nodejs`, `passenger-jruby93-94`
2. **Special images**: 
   - `passenger-full`: Contains all languages and runtimes
   - `passenger-customizable`: Base system only, for custom configurations

Key architectural components:

- **Base image**: Built from Ubuntu 24.04 LTS with baseimage-docker's init system
- **Build system**: Uses RVM for Ruby version management, supports multiple Python versions via Deadsnakes PPA
- **Web stack**: Nginx 1.24 + Phusion Passenger 6 (disabled by default)
- **Services**: Redis 7.0 and Memcached (optional, disabled by default)

## Build Commands

Build specific images:
```bash
make build_ruby32     # Build Ruby 3.2 image
make build_ruby33     # Build Ruby 3.3 image
make build_ruby34     # Build Ruby 3.4 image
make build_python312  # Build Python 3.12 image
make build_nodejs     # Build Node.js image
make build_full       # Build full image with all languages
make build_all        # Build all images
```

Build for specific architecture:
```bash
BUILD_ARM64=0 make build_ruby32  # Build only for AMD64
BUILD_AMD64=0 make build_ruby32  # Build only for ARM64
```

Build with custom repository:
```bash
NAME="myrepo/passenger" VERSION=2.5.1 make build_ruby32
```

## Test Commands

Run tests:
```bash
bundle install        # Install test dependencies
bundle exec rspec     # Run all tests
```

## Development Workflow

1. The build process starts with `Dockerfile.base` to create the base image
2. Each variant uses the main `Dockerfile` with different buildconfig settings
3. Images are built using Docker Buildx for multi-architecture support
4. Shell scripts in `image/` handle installation of specific components

Key files to understand:
- `image/install_image.sh`: Main installation orchestrator
- `image/buildconfig`: Controls which components to install
- `image/*-*.sh`: Individual component installers (Ruby versions, Python, Node.js, etc.)
- `image/finalize.sh`: Cleanup and optimization after installation

## Working with the Codebase

When modifying installation scripts:
- Always check `image/buildconfig` for feature flags
- Use `/pd_build/` prefix for scripts during build
- Follow the pattern of checking buildconfig before installing components
- Remember that images support both AMD64 and ARM64 architectures

When adding new Ruby versions:
- Add new script in `image/ruby-X.Y.Z.sh`
- Update `image/nginx-passenger.sh` to include the new version
- Update `image/ruby-support/finalize.sh` for wrapper scripts
- Add to `CRUBY_IMAGES` in `Makefile`

## Important Notes

- The project uses RVM for Ruby management to provide better isolation between Ruby versions
- All images are built on baseimage-docker which provides proper init, cron, and syslog support
- Passenger and Nginx are disabled by default and must be explicitly enabled in derived images
- The `/home/app` directory with `app` user (UID 9999) is the standard location for applications