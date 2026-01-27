{ config, ... }:
{
  system.defaults.dock = {
    persistent-apps = [
      "System/Applications/Apps.app"
      "System/Applications/System Settings.app"
      "/Applications/ChatGPT Atlas.app"
      "/Applications/Xcode.app"
      "/Applications/Zed.app"
      "/Applications/WezTerm.app"
    ];
  };
}