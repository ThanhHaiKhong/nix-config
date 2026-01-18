{ config, ... }:
{
  system.defaults.dock = {
    persistent-apps = [
      "/Applications/ChatGPT Atlas.app"
      "/Applications/Telegram.app"
      "/Applications/Discord.app"
      "/Applications/Visual Studio Code.app"
      "/Applications/OBS.app"
      "/Applications/WezTerm.app"
    ];
  };
}