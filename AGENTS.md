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

## Current Tech Stack

- Erlang/OTP: Check `.tool-versions` file
- Elixir: Check `.tool-versions` file  
- Phoenix: Check `mix.exs` dependencies
- Database: SQLite via ecto_sqlite3
- Authentication: ueberauth with Google OAuth
- Styling: Tailwind CSS
- Assets: esbuild