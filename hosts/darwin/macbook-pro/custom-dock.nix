{ config, ... }:
{
  system.defaults.dock = {
    persistent-apps = [
      "/Applications/Apps.app"
      "/Applications/AIDente.app"
      "/Applications/System Settings.app"
      "/Applications/ChatGPT Atlas.app"
      "/Applications/Xcode.app"
      "/Applications/Visual Studio Code.app"
      "/Applications/WezTerm.app"
    ];
  };
}