{ config, ... }:
{
  system.defaults.dock = {
    persistent-apps = [
      "/Applications/ChatGPT Atlas.app"
      "/Applications/Signal.app"
      "/Applications/Discord.app"
      "/Applications/Visual Studio Code.app"
      "/Applications/WezTerm.app"
    ];
  };
}