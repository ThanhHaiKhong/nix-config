{ config, ... }:
{
  system.defaults.dock = {
    persistent-apps = [
      "System/Applications/Apps.app"
      "/Applications/AIDente.app"
      "System/Applications/System Settings.app"
      "/Applications/ChatGPT Atlas.app"
      "/Applications/Xcode.app"
      "/Applications/Visual Studio Code.app"
      "/Applications/WezTerm.app"
    ];
  };
}