{
  config,
  lib,
  ...
}:

{
  ########################################
  #
  ## Work MCP (local per-customer spaces)
  # Only enabled on the work MacBook; the ai.nix profile ships the module
  # everywhere but leaves it disabled, and other hosts get no `work` MCP
  # client entry.
  #
  ########################################
  programs = {
    work-mcp = {
      enable = true;
      customerDiscovery = lib.mkDefault true;
      workRoot = "${config.home.homeDirectory}/Projects/work";
      excludeCustomers = [ ".shell" ];
    };

    prime-agent.settings.mcpServers.work-mcp = {
      type = "http";
      url = config.programs.work-mcp.url;
    };

    opencode.settings.mcp.work-mcp = {
      type = "remote";
      url = config.programs.work-mcp.url;
    };
  };
}
