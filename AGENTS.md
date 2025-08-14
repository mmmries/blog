# Agent Guidelines for Blog Project

This document contains useful commands and guidelines for agents working on this Phoenix blog application.

## Version Management Commands

### Checking Available Versions

To check available Erlang and Elixir versions through ASDF:
```bash
# Update the ASDF cache by updating plugins
asdf update plugin --all

# List all available Erlang versions
asdf list all erlang

# List all available Elixir versions  
asdf list all elixir

# Check current installed versions
asdf current
```

### Checking Outdated Dependencies

To check for outdated Hex packages:
```bash
# Check all outdated dependencies
mix hex.outdated

# Check specific dependency
mix hex.outdated APP_NAME
```

### Removing Dependencies

When removing a dependency from `mix.exs`, follow these steps to clean up properly:
```bash
# 1. Remove the dependency from mix.exs deps list
# 2. Unlock the specific dependency from mix.lock
mix deps.unlock DEPENDENCY_NAME

# 3. Clean up any unused transitive dependencies
mix deps.clean --unused

# 4. Verify remaining dependencies are correct
mix deps.get

# 5. Ensure everything still compiles
mix compile
```

**Example**: When we removed libcluster, we ran:
```bash
mix deps.unlock libcluster
mix deps.clean --unused  # Also removed unused ueberauth_identity
mix deps.get
mix compile
```

## Project Structure

This Phoenix application includes:
- Personal blog functionality
- SVG generation tool 
- Home automation interface for garage door control

## Upgrade Considerations

When upgrading Phoenix and Phoenix LiveView:
- Phoenix LiveView upgrades often introduce breaking changes
- **IMPORTANT**: Update Dockerfile versions to match `.tool-versions`
- Test all three main features after upgrades:
  1. Blog functionality
  2. SVG generation tool
  3. Garage automation interface

## Development Requirements

### NATS Server for Testing

To run the full test suite, you must have a local NATS server running:

```bash
# Install NATS server (if not already installed)
# macOS: brew install nats-server
# Other platforms: https://docs.nats.io/running-a-nats-service/introduction/installation

# Start NATS server (default port 4222)
nats-server

# Run tests in another terminal
mix test
```

**Important**: The application always expects a NATS connection to be available. In production, it uses NGS Global with JWT authentication. In development/testing, it connects to localhost:4222 by default.

## Current Tech Stack

- Erlang/OTP: Check `.tool-versions` file
- Elixir: Check `.tool-versions` file  
- Phoenix: Check `mix.exs` dependencies
- Database: SQLite via ecto_sqlite3
- Authentication: ueberauth with Google OAuth
- Styling: Tailwind CSS
- Assets: esbuild
- Messaging: NATS (gnat library)