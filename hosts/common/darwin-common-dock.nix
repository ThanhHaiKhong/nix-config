{ config, ... }:
{
  system.defaults.dock = {
    persistent-apps = [
      "/Applications/AIDente.app"
      "/Applications/ChatGPT Atlas.app"
      "/Applications/Xcode.app"
      "/Applications/Visual Studio Code.app"
      "/Applications/WezTerm.app"
    ];
  };
}
