# ironicbadger/nix-config

Repo contains configuration for personal machines, mostly running nix-darwin. I have no idea what I'm doing, and the deeper I go the less of a clue I have apparently.

## CLIProxyAPI Configuration

This repository includes a configuration for CLIProxyAPI, a proxy server for various AI model APIs (OpenAI, Claude, Gemini, etc.) that allows you to manage multiple API keys, route requests to different providers, and provides features like authentication, rate limiting, and model aliasing.

### Features

- **Service Management**: Automatic startup via launchd with management script
- **Provider Support**: Configured for Gemini, OpenAI, Claude, and other AI services
- **Configuration Validation**: Built-in validation and testing capabilities
- **Secure by Default**: Binds to localhost only, with authentication options
- **Opencode Integration**: Seamlessly integrates with Opencode for unified AI access

### Usage

After building and switching to this configuration:

1. Start the service: `cliproxyapi-manager start`
2. Test the connection: `cliproxyapi-manager test`
3. View available commands: `cliproxyapi-manager` (without arguments)

For more detailed information, see `configs/cliproxyapi/README.md`.

### Integration with Opencode

CLIProxyAPI is preconfigured to integrate with Opencode. Once both services are running, Opencode can use CLIProxyAPI as a unified backend to access multiple AI services through a single endpoint. See the CLIProxyAPI README for detailed integration instructions.
