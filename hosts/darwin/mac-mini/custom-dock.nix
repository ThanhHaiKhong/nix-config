{ config, ... }:
{
  system.defaults.dock = {
    persistent-apps = [
      "System/Applications/Apps.app"
      "System/Applications/System Settings.app"
      "/Applications/ChatGPT Atlas.app"
      "/Applications/Xcode.app"
      "/Applications/Visual Studio Code.app"
      "/Applications/WezTerm.app"
    ];
  };
}