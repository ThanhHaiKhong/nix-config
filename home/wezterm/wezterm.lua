local wezterm = require("wezterm")
local mux = wezterm.mux
local config = wezterm.config_builder()

-- =======================
-- WINDOW CONFIGURATION
-- =======================

-- Window size and positioning
config.initial_cols = 110
config.initial_rows = 32
config.adjust_window_size_when_changing_font_size = false
config.use_resize_increments = false
config.allow_square_glyphs_to_overflow_width = "WhenFollowedBySpace"

-- Window decorations and padding
config.window_decorations = "RESIZE"
config.window_padding = {
  left = 20,
  right = 20,
  top = 20,
  bottom = 20,
}

-- Additional window configuration
config.window_background_opacity = 0.75
config.text_background_opacity = 1.0
config.macos_window_background_blur = 0
config.enable_tab_bar = true
config.tab_bar_at_bottom = false
config.tab_max_width = 100

-- Window appearance defaults
config.integrated_title_buttons = {"Hide", "Maximize", "Close"}
config.integrated_title_button_alignment = "Right"
config.integrated_title_button_style = "Windows"
config.integrated_title_button_color = "auto"

-- macOS-specific optimizations
config.native_macos_fullscreen_mode = false
config.macos_forward_to_ime_modifier_mask = "SHIFT|CTRL"

-- Explicitly configure Option keys for Emacs Meta key support
-- Left Option = Meta (for Emacs), Right Option = Compose (for special chars)
config.send_composed_key_when_left_alt_is_pressed = false
config.send_composed_key_when_right_alt_is_pressed = true

-- Window frame configuration
config.window_frame = {
  font = wezterm.font({
    family = "JetBrainsMono Nerd Font",
    weight = "Medium",
  }),
  font_size = 14.0,
}

-- Window behavior
config.window_close_confirmation = "NeverPrompt"
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false

-- Enhanced tab bar styling
config.tab_bar_style = {
  new_tab = " + ",
  new_tab_hover = " + ",
}

-- =======================
-- FONT CONFIGURATION
-- =======================

-- Primary font with fallback
config.font = wezterm.font_with_fallback({
  {
    family = "JetBrainsMono Nerd Font",
    weight = "Regular",
    harfbuzz_features = { "calt=1", "clig=1", "liga=1" },
  },
  -- Asian language support
  "PingFang SC",
  "Hiragino Sans",
  "Microsoft YaHei",
  -- Symbol and icon fallbacks
  "Symbols Nerd Font Mono",
  "Font Awesome 6 Free",
  -- Emoji support
  {
    family = "Apple Color Emoji",
    assume_emoji_presentation = true,
  },
  "Noto Color Emoji",
  "Segoe UI Emoji",
})

config.font_size = 17.0
config.line_height = 1.275
config.cell_width = 1.0

-- Additional font configuration
config.font_dirs = {
  -- Add custom font directories if needed
  -- "/Users/thanhhaikhong/.local/share/fonts",
  -- "/Users/thanhhaikhong/Library/Fonts",
}
config.font_locator = "CoreText"
config.font_shaper = "Harfbuzz"
config.freetype_load_flags = "DEFAULT"
config.freetype_load_target = "HorizontalLcd"
config.freetype_render_target = "Normal"
config.dpi = nil  -- Auto-detect DPI
config.bold_brightens_ansi_colors = true
config.warn_about_missing_glyphs = false  -- Reduce noise
config.custom_block_glyphs = true

-- Advanced font rendering options
-- config.font_rasterizer = "FreeType"
config.font_colr_rasterizer = "Harfbuzz"
config.anti_alias_custom_block_glyphs = true
config.sort_fallback_fonts_by_coverage = false
config.search_font_dirs_for_fallback = false
config.use_cap_height_to_scale_fallback_fonts = false
config.harfbuzz_features = {"kern", "liga", "clig"}
config.freetype_pcf_long_family_names = false

-- Font rules for different styles and contexts
config.font_rules = {
  -- Bold text
  {
    intensity = "Bold",
    font = wezterm.font_with_fallback({
      {
        family = "JetBrainsMono Nerd Font",
        weight = "Bold",
      },
      "PingFang SC",
      "Hiragino Sans",
      "Apple Color Emoji",
    }),
  },

  -- Italic text
  {
    italic = true,
    font = wezterm.font_with_fallback({
      {
        family = "JetBrainsMono Nerd Font",
        style = "Italic",
      },
      "PingFang SC",
      "Hiragino Sans",
      "Apple Color Emoji",
    }),
  },

  -- Bold italic text
  {
    intensity = "Bold",
    italic = true,
    font = wezterm.font_with_fallback({
      {
        family = "JetBrainsMono Nerd Font",
        weight = "Bold",
        style = "Italic",
      },
      "PingFang SC",
      "Hiragino Sans",
      "Apple Color Emoji",
    }),
  },

  -- Half intensity (dim) text
  {
    intensity = "Half",
    font = wezterm.font_with_fallback({
      {
        family = "JetBrainsMono Nerd Font",
        weight = "Light",
      },
      "PingFang SC",
      "Hiragino Sans",
      "Apple Color Emoji",
    }),
  },

  -- Half intensity italic
  {
    intensity = "Half",
    italic = true,
    font = wezterm.font_with_fallback({
      {
        family = "JetBrainsMono Nerd Font",
        weight = "Light",
        style = "Italic",
      },
      "PingFang SC",
      "Hiragino Sans",
      "Apple Color Emoji",
    }),
  },
}

-- =======================
-- COLOR SCHEME
-- =======================

-- Color scheme
config.color_scheme = "AdventureTime"

-- Custom color overrides
config.colors = {
  -- Default text and background colors
  foreground = '#c0c0c0',
  background = '#1e1e2e',

  -- Cursor colors
  cursor_bg = '#ffffff',
  cursor_fg = '#000000',
  cursor_border = '#ffffff',

  -- Selection colors
  selection_bg = 'rgba(50% 50% 50% 50%)',
  selection_fg = 'none',

  -- Scrollbar color
  scrollbar_thumb = '#45475a',

  -- Split line color between panes
  split = '#6c7086',

  -- ANSI colors (0-7)
  ansi = {
    '#45475a', -- black
    '#f38ba8', -- red
    '#a6e3a1', -- green
    '#f9e2af', -- yellow
    '#89b4fa', -- blue
    '#f5c2e7', -- magenta
    '#94e2d5', -- cyan
    '#bac2de', -- white
  },

  -- Bright ANSI colors (8-15)
  brights = {
    '#585b70', -- bright black
    '#f38ba8', -- bright red
    '#a6e3a1', -- bright green
    '#f9e2af', -- bright yellow
    '#89b4fa', -- bright blue
    '#f5c2e7', -- bright magenta
    '#94e2d5', -- bright cyan
    '#a6adc8', -- bright white
  },

  -- Arbitrary colors of the palette in the range from 16 to 255
  indexed = {
    [16] = '#fab387',
    [17] = '#f5e0dc',
  },

  -- Compose cursor color (when IME or dead key is being processed)
  compose_cursor = '#f9e2af',

  -- Copy mode and quick select colors
  copy_mode_active_highlight_bg = { Color = '#89b4fa' },
  copy_mode_active_highlight_fg = { Color = '#1e1e2e' },
  copy_mode_inactive_highlight_bg = { Color = '#45475a' },
  copy_mode_inactive_highlight_fg = { Color = '#c0c0c0' },

  quick_select_label_bg = { Color = '#f9e2af' },
  quick_select_label_fg = { Color = '#1e1e2e' },
  quick_select_match_bg = { Color = '#89b4fa' },
  quick_select_match_fg = { Color = '#1e1e2e' },

  -- Tab bar colors
  tab_bar = {
    background = '#213555',
    inactive_tab_edge = '#3E5879',

    active_tab = {
      bg_color = '#3E5879',
      fg_color = '#bac2de',
      intensity = 'Bold',
      underline = 'None',
      italic = false,
      strikethrough = false,
    },

    inactive_tab = {
      bg_color = '#213555',
      fg_color = '#3E5879',
      intensity = 'Normal',
      underline = 'None',
      italic = false,
      strikethrough = false,
    },

    inactive_tab_hover = {
      bg_color = '#3E5879',
      fg_color = '#f5c2e7',
      intensity = 'Normal',
      underline = 'None',
      italic = true,
      strikethrough = false,
    },

    new_tab = {
      bg_color = '#295F98',
      fg_color = '#bac2de',
      intensity = 'Normal',
      underline = 'None',
      italic = false,
      strikethrough = false,
    },

    new_tab_hover = {
      bg_color = '#3E5879',
      fg_color = '#a6e3a1',
      intensity = 'Normal',
      underline = 'None',
      italic = true,
      strikethrough = false,
    },
  },
}

-- =======================
-- TERMINAL BEHAVIOR
-- =======================

-- Terminal behavior configuration
config.scrollback_lines = 10000
config.enable_scroll_bar = false
config.term = "xterm-256color"
config.audible_bell = "SystemBeep"
config.visual_bell = {}
config.exit_behavior = "CloseOnCleanExit"
config.status_update_interval = 1000
config.bypass_mouse_reporting_modifiers = "SHIFT"

-- Advanced terminal features
config.enable_kitty_keyboard = false
config.enable_csi_u_key_encoding = false
config.detect_password_input = true
config.canonicalize_pasted_newlines = "None"

-- Additional terminal behavior options
config.clean_exit_codes = {}
config.skip_close_confirmation_for_processes_named = {
  "bash", "sh", "zsh", "fish", "tmux", "nu", "cmd.exe", "pwsh.exe", "powershell.exe"
}
config.enable_kitty_graphics = false
config.enable_title_reporting = false
config.alternate_buffer_wheel_scroll_speed = 3
config.min_scroll_bar_height = "0.5cell"
config.mouse_wheel_scrolls_tabs = true

-- Mouse and clipboard
config.mouse_bindings = {
  {
    event = { Down = { streak = 3, button = "Left" } },
    action = wezterm.action.SelectTextAtMouseCursor("SemanticZone"),
    mods = "NONE",
  },
}

-- Mouse configuration
config.disable_default_mouse_bindings = false
config.hide_mouse_cursor_when_typing = true
config.swallow_mouse_click_on_pane_focus = false
config.swallow_mouse_click_on_window_focus = false
config.pane_focus_follows_mouse = false
config.unzoom_on_switch_pane = true

-- Shell and program configuration
config.default_workspace = "main"
config.default_prog = nil  -- Use system default shell
config.default_cwd = nil   -- Use home directory
config.set_environment_variables = {
  -- TERM is set via config.term instead
}

-- Launcher menu
config.launch_menu = {
  { label = "Bash", args = { "bash", "-l" } },
  { label = "Zsh", args = { "zsh", "-l" } },
  { label = "Fish", args = { "fish", "-l" } },
  { label = "Python", args = { "python3" } },
  { label = "Node.js", args = { "node" } },
}

-- =======================
-- KEY BINDINGS
-- =======================

-- Key binding configuration
config.disable_default_key_bindings = false
config.debug_key_events = false
config.key_map_preference = "Mapped"

-- Leader key configuration (using CTRL+a for leader)
config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }

-- Local leader key table (using COMMA)
local local_leader = { key = ",", mods = "NONE", timeout_milliseconds = 1000 }

config.keys = {
  -- Font size adjustments
  {
    key = "=",
    mods = "CMD",
    action = wezterm.action.IncreaseFontSize,
  },
  {
    key = "-",
    mods = "CMD",
    action = wezterm.action.DecreaseFontSize,
  },
  {
    key = "0",
    mods = "CMD",
    action = wezterm.action.ResetFontSize,
  },

  -- Tab management
  {
    key = "t",
    mods = "CMD",
    action = wezterm.action.SpawnTab("CurrentPaneDomain"),
  },
  {
    key = "w",
    mods = "CMD",
    action = wezterm.action.CloseCurrentTab({ confirm = false }),
  },
  {
    key = "r",
    mods = "CMD",
    action = wezterm.action.ReloadConfiguration,
  },

  -- Workspace management (fixed conflicts - changed from CMD|SHIFT)
  {
    key = "n",
    mods = "CMD|ALT|SHIFT",
    action = wezterm.action.SwitchWorkspaceRelative(1),
  },
  {
    key = "p",
    mods = "CMD|ALT|SHIFT",
    action = wezterm.action.SwitchWorkspaceRelative(-1),
  },
  -- Removed duplicate workspace launcher (keeping CMD+SHIFT+W version)

  -- Pane splitting with leader key (simplified, no Shift needed)
  {
    key = "\\",
    mods = "LEADER",
    action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
  },
  {
    key = "-",
    mods = "LEADER",
    action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
  },
  {
    key = "x",
    mods = "LEADER",
    action = wezterm.action.CloseCurrentPane({ confirm = true }),
  },
  {
    key = "z",
    mods = "LEADER",
    action = wezterm.action.TogglePaneZoomState,
  },

  -- Alternative pane splitting (CMD based)
  {
    key = "d",
    mods = "CMD",
    action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
  },
  {
    key = "d",
    mods = "CMD|SHIFT",
    action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
  },

  -- Copy/Paste
  {
    key = "c",
    mods = "CMD",
    action = wezterm.action.CopyTo("Clipboard"),
  },
  {
    key = "v",
    mods = "CMD",
    action = wezterm.action.PasteFrom("Clipboard"),
  },

  -- Copy mode
  {
    key = "[",
    mods = "LEADER",
    action = wezterm.action.ActivateCopyMode,
  },

  -- Search (enhanced with navigation)
  {
    key = "f",
    mods = "CMD",
    action = wezterm.action.Search({ CaseInSensitiveString = "" }),
  },
  {
    key = "g",
    mods = "CMD",
    action = wezterm.action.Search({ CaseInSensitiveString = "" }),
  },
  {
    key = "/",
    mods = "LEADER",
    action = wezterm.action.Search({ CaseSensitiveString = "" }),
  },

  -- Clear screen
  {
    key = "k",
    mods = "CMD",
    action = wezterm.action.ClearScrollback("ScrollbackAndViewport"),
  },
  -- Removed Ctrl+L binding to allow shell's clear command to work
  -- {
  --   key = "l",
  --   mods = "CTRL",
  --   action = wezterm.action.ClearScrollback("ScrollbackOnly"),
  -- },

  -- Quick select
  {
    key = " ",
    mods = "LEADER",
    action = wezterm.action.QuickSelect,
  },

  -- Command palette (now available with original shortcut)
  {
    key = "p",
    mods = "CMD|SHIFT",
    action = wezterm.action.ActivateCommandPalette,
  },

  -- Debug overlay
  {
    key = "l",
    mods = "CMD|SHIFT",
    action = wezterm.action.ShowDebugOverlay,
  },

  -- Toggle fullscreen (removed duplicate CMD|CTRL+F)
  {
    key = "Enter",
    mods = "CMD",
    action = wezterm.action.ToggleFullScreen,
  },

  -- Tab navigation
  {
    key = "LeftArrow",
    mods = "CMD",
    action = wezterm.action.ActivateTabRelative(-1),
  },
  {
    key = "RightArrow",
    mods = "CMD",
    action = wezterm.action.ActivateTabRelative(1),
  },
  {
    key = "1",
    mods = "CMD",
    action = wezterm.action.ActivateTab(0),
  },
  {
    key = "2",
    mods = "CMD",
    action = wezterm.action.ActivateTab(1),
  },
  {
    key = "3",
    mods = "CMD",
    action = wezterm.action.ActivateTab(2),
  },
  {
    key = "4",
    mods = "CMD",
    action = wezterm.action.ActivateTab(3),
  },
  {
    key = "5",
    mods = "CMD",
    action = wezterm.action.ActivateTab(4),
  },
  {
    key = "6",
    mods = "CMD",
    action = wezterm.action.ActivateTab(5),
  },
  {
    key = "7",
    mods = "CMD",
    action = wezterm.action.ActivateTab(6),
  },
  {
    key = "8",
    mods = "CMD",
    action = wezterm.action.ActivateTab(7),
  },

  -- Pane navigation
  {
    key = "LeftArrow",
    mods = "CMD|ALT",
    action = wezterm.action.ActivatePaneDirection("Left"),
  },
  {
    key = "RightArrow",
    mods = "CMD|ALT",
    action = wezterm.action.ActivatePaneDirection("Right"),
  },
  {
    key = "UpArrow",
    mods = "CMD|ALT",
    action = wezterm.action.ActivatePaneDirection("Up"),
  },
  {
    key = "DownArrow",
    mods = "CMD|ALT",
    action = wezterm.action.ActivatePaneDirection("Down"),
  },

  -- Leader-based pane navigation (vim-like)
  {
    key = "h",
    mods = "LEADER",
    action = wezterm.action.ActivatePaneDirection("Left"),
  },
  {
    key = "l",
    mods = "LEADER",
    action = wezterm.action.ActivatePaneDirection("Right"),
  },
  {
    key = "k",
    mods = "LEADER",
    action = wezterm.action.ActivatePaneDirection("Up"),
  },
  {
    key = "j",
    mods = "LEADER",
    action = wezterm.action.ActivatePaneDirection("Down"),
  },

  -- Pane resizing
  {
    key = "LeftArrow",
    mods = "LEADER|SHIFT",
    action = wezterm.action.AdjustPaneSize({ "Left", 5 }),
  },
  {
    key = "RightArrow",
    mods = "LEADER|SHIFT",
    action = wezterm.action.AdjustPaneSize({ "Right", 5 }),
  },
  {
    key = "UpArrow",
    mods = "LEADER|SHIFT",
    action = wezterm.action.AdjustPaneSize({ "Up", 5 }),
  },
  {
    key = "DownArrow",
    mods = "LEADER|SHIFT",
    action = wezterm.action.AdjustPaneSize({ "Down", 5 }),
  },

  -- Send CTRL+a to terminal when pressing leader twice
  {
    key = "a",
    mods = "LEADER|CTRL",
    action = wezterm.action.SendKey({ key = "a", mods = "CTRL" }),
  },

  -- Scrollback
  {
    key = "PageUp",
    mods = "SHIFT",
    action = wezterm.action.ScrollByPage(-1),
  },
  {
    key = "PageDown",
    mods = "SHIFT",
    action = wezterm.action.ScrollByPage(1),
  },
  {
    key = "u",
    mods = "CTRL|SHIFT",
    action = wezterm.action.ScrollByPage(-0.5),
  },
  {
    key = "d",
    mods = "CTRL|SHIFT",
    action = wezterm.action.ScrollByPage(0.5),
  },

  -- Additional key assignments from WezTerm documentation

  -- Character selector (for emojis and special characters)
  {
    key = "u",
    mods = "CMD|SHIFT",
    action = wezterm.action.CharSelect({
      copy_on_select = true,
      copy_to = "ClipboardAndPrimarySelection",
    }),
  },

  -- Move tabs
  {
    key = "PageUp",
    mods = "CMD|SHIFT",
    action = wezterm.action.MoveTabRelative(-1),
  },
  {
    key = "PageDown",
    mods = "CMD|SHIFT",
    action = wezterm.action.MoveTabRelative(1),
  },

  -- Window management (added missing macOS standards)
  {
    key = "q",
    mods = "CMD",
    action = wezterm.action.QuitApplication,
  },
  {
    key = "m",
    mods = "CMD",
    action = wezterm.action.Hide,
  },
  {
    key = "n",
    mods = "CMD|SHIFT",
    action = wezterm.action.SpawnWindow,
  },
  {
    key = "h",
    mods = "CMD",
    action = wezterm.action.HideApplication,
  },

  -- Workspace switcher
  {
    key = "w",
    mods = "CMD|SHIFT",
    action = wezterm.action.ShowLauncherArgs({
      flags = "FUZZY|WORKSPACES",
    }),
  },

  -- Advanced pane navigation by index
  {
    key = "F1",
    mods = "ALT",
    action = wezterm.action.ActivatePaneByIndex(0),
  },
  {
    key = "F2",
    mods = "ALT",
    action = wezterm.action.ActivatePaneByIndex(1),
  },
  {
    key = "F3",
    mods = "ALT",
    action = wezterm.action.ActivatePaneByIndex(2),
  },
  {
    key = "F4",
    mods = "ALT",
    action = wezterm.action.ActivatePaneByIndex(3),
  },

  -- Rotate panes
  {
    key = "r",
    mods = "LEADER",
    action = wezterm.action.RotatePanes("Clockwise"),
  },
  {
    key = "R",
    mods = "LEADER|SHIFT",
    action = wezterm.action.RotatePanes("CounterClockwise"),
  },

  -- Tab management improvements (using macOS standard shortcuts)
  {
    key = "]",
    mods = "CMD|SHIFT",
    action = wezterm.action.ActivateTabRelative(1),
  },
  {
    key = "[",
    mods = "CMD|SHIFT",
    action = wezterm.action.ActivateTabRelative(-1),
  },
  {
    key = "`",
    mods = "CMD",
    action = wezterm.action.ActivateLastTab,
  },

  -- Send arbitrary text
  {
    key = "Enter",
    mods = "LEADER",
    action = wezterm.action.PromptInputLine({
      description = "Enter new name for tab",
      action = wezterm.action_callback(function(window, pane, line)
        if line then
          window:active_tab():set_title(line)
        end
      end),
    }),
  },

  -- Shift+Enter sends just a newline character (literal line break) - primary binding
  {
    key = "Enter",
    mods = "SHIFT",
    action = wezterm.action.SendString("\n"),
  },
  -- Alternative Ctrl+Shift+Enter binding for compatibility
  {
    key = "Enter",
    mods = "CTRL|SHIFT",
    action = wezterm.action.SendString("\n"),
  },

  -- Activate multiline mode for multi-line input
  {
    key = "Return",
    mods = "CTRL",
    action = wezterm.action.ActivateKeyTable({
      name = "multiline_mode",
      timeout_milliseconds = 1000,
    }),
  },
  -- Alternative for Enter key to enter multiline mode
  {
    key = "Enter",
    mods = "CTRL",
    action = wezterm.action.ActivateKeyTable({
      name = "multiline_mode",
      timeout_milliseconds = 1000,
    }),
  },
  -- Split pane with current working directory (simplified shortcuts)
  {
    key = "v",
    mods = "LEADER",
    action = wezterm.action.SplitVertical({ cwd = "CurrentPaneDomain" }),
  },
  {
    key = "h",
    mods = "LEADER|SHIFT",
    action = wezterm.action.SplitHorizontal({ cwd = "CurrentPaneDomain" }),
  },

  -- Scrollback commands
  {
    key = "Home",
    mods = "SHIFT",
    action = wezterm.action.ScrollToTop,
  },
  {
    key = "End",
    mods = "SHIFT",
    action = wezterm.action.ScrollToBottom,
  },

  -- Selection shortcuts
  {
    key = "a",
    mods = "CMD",
    action = wezterm.action.SelectTextAtMouseCursor("SemanticZone"),
  },

  -- Attach to existing multiplexer session
  {
    key = "a",
    mods = "LEADER",
    action = wezterm.action.AttachDomain("unix"),
  },

  -- Copy/paste variations
  {
    key = "Insert",
    mods = "CTRL",
    action = wezterm.action.CopyTo("PrimarySelection"),
  },
  {
    key = "Insert",
    mods = "SHIFT",
    action = wezterm.action.PasteFrom("PrimarySelection"),
  },

  -- Hide tab bar toggle
  {
    key = "b",
    mods = "LEADER",
    action = wezterm.action.EmitEvent("toggle-tabbar"),
  },

  -- Show launcher for applications
  {
    key = "o",
    mods = "LEADER",
    action = wezterm.action.ShowLauncher,
  },

  -- Spawn new tab in default domain
  {
    key = "T",
    mods = "CMD|SHIFT",
    action = wezterm.action.SpawnTab("DefaultDomain"),
  },

  -- Detach from session
  {
    key = "D",
    mods = "LEADER|SHIFT",
    action = wezterm.action.DetachDomain({ DomainName = "unix" }),
  },

  -- Show/hide scrollbar
  {
    key = "s",
    mods = "LEADER",
    action = wezterm.action.EmitEvent("toggle-scrollbar"),
  },

  -- Enhanced productivity bindings
  -- Quick access to command palette with a more accessible key
  {
    key = "x",
    mods = "CMD|SHIFT",
    action = wezterm.action.ActivateCommandPalette,
  },
  -- Easy access to copy mode
  {
    key = "/",
    mods = "CMD|SHIFT",
    action = wezterm.action.ActivateCopyMode,
  },
  -- Keep existing search functionality; remove potentially conflicting duplicate
  -- Better pane switching with alternative shortcuts to avoid conflicts
  {
    key = "UpArrow",
    mods = "CMD|SHIFT",
    action = wezterm.action.ActivatePaneDirection("Up"),
  },
  {
    key = "DownArrow",
    mods = "CMD|SHIFT",
    action = wezterm.action.ActivatePaneDirection("Down"),
  },
  {
    key = "LeftArrow",
    mods = "CMD|SHIFT",
    action = wezterm.action.ActivatePaneDirection("Left"),
  },
  {
    key = "RightArrow",
    mods = "CMD|SHIFT",
    action = wezterm.action.ActivatePaneDirection("Right"),
  },

  -- Toggle between last two tabs
  {
    key = "Tab",
    mods = "CMD",
    action = wezterm.action.ActivateLastTab,
  },
}

-- =======================
-- PERFORMANCE
-- =======================

-- Rendering performance
config.max_fps = 120
config.animation_fps = 60

-- GPU acceleration
config.front_end = "WebGpu"
config.webgpu_power_preference = "HighPerformance"
config.prefer_egl = true
-- config.enable_wayland = true --- IGNORE --- Only for Wayland systems(Linux)

-- =======================
-- ADVANCED FEATURES
-- =======================

-- Enable undercurl, dotted and dashed underlines
config.underline_thickness = 3
config.underline_position = -6

-- Hyperlink rules
config.hyperlink_rules = wezterm.default_hyperlink_rules()

-- Quick select patterns (for URLs, file paths, etc.)
config.quick_select_patterns = {
  "https?://\\S+",
  "file://\\S+",    
  "\\b\\w+://(?:[\\w.-]+)\\S*\\b",
  "[\\w._-]+@[\\w._-]+\\.[\\w._-]+",
  "\\b[0-9a-f]{7,40}\\b",  -- Git hashes
  "\\b\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\b",  -- IP addresses
  "/[^\\s]*",  -- File paths
}

-- Miscellaneous configuration
config.automatically_reload_config = true
config.check_for_updates = true

-- Scroll to bottom when typing
config.scroll_to_bottom_on_input = true

-- Color scheme overrides for better visibility
config.force_reverse_video_cursor = false

-- Smart tab switching behavior
config.switch_to_last_active_tab_when_closing_tab = true

-- Inactive pane dimming for better focus
config.inactive_pane_hsb = {
  saturation = 0.8,
  brightness = 0.7,
}

-- Additional missing configuration options with defaults
-- ===================================================

-- Input handling options
-- Note: Option key settings are configured in macOS-specific section above
config.treat_left_ctrlalt_as_altgr = false
config.use_ime = true
config.ime_preedit_rendering = "Builtin"
config.use_dead_keys = true
config.normalize_output_to_unicode_nfc = false

-- Cursor configuration
config.cursor_blink_rate = 800
config.cursor_blink_ease_in = "Constant"
config.cursor_blink_ease_out = "Constant"
config.default_cursor_style = "BlinkingBlock"
config.force_reverse_video_cursor = false

-- Text effects
config.text_blink_rate = 500
config.text_blink_ease_in = "Linear"
config.text_blink_ease_out = "Linear"
config.text_blink_rate_rapid = 250

-- Unicode and text processing
config.unicode_version = 9
config.treat_east_asian_ambiguous_width_as_wide = false
config.bidi_enabled = false
config.bidi_direction = "LeftToRight"

-- Selection and clipboard
config.selection_word_boundary = " \t\n{[}]()\"'`"
config.quote_dropped_files = "SpacesOnly"

-- Quick select configuration
-- config.quick_select_alphabet = "asdfqwerzxcvjklmiuopghtybn"
-- config.quick_select_remove_styling = false
-- config.disable_default_quick_select_patterns = false

-- Window management
config.quit_when_all_windows_are_closed = true
config.tiling_desktop_environments = {
  "X11 LG3D", "X11 Qtile", "X11 awesome", "X11 bspwm",
  "X11 dwm", "X11 i3", "X11 xmonad"
}

-- System integration
config.notification_handling = "AlwaysShow"
config.check_for_updates_interval_seconds = 86400
config.show_update_window = false
config.log_unknown_escape_sequences = false

-- Text rendering effects (configured in ADVANCED FEATURES section above)
config.strikethrough_position = nil
config.cursor_thickness = nil

-- Advanced rendering options
config.experimental_pixel_positioning = false

-- Key tables for modal bindings (empty by default)
config.key_tables = {
  -- Create a mode for multi-line input
  multiline_mode = {
    { key = "Enter", mods = "NONE", action = wezterm.action.SendString("\n") },
    { key = "Return", mods = "NONE", action = wezterm.action.SendString("\n") },
    { key = "Enter", mods = "SHIFT", action = wezterm.action.SendString("\n") },
    { key = "Return", mods = "SHIFT", action = wezterm.action.SendString("\n") },
    { key = "Escape", mods = "NONE", action = wezterm.action.PopKeyTable },
    { key = "c", mods = "CTRL", action = wezterm.action.PopKeyTable },
  }
}

-- =======================
-- EVENT HANDLERS
-- =======================

-- Configure window to open centered with 5/7 width and 4/5 height
wezterm.on('gui-startup', function(cmd)
  local tab, pane, window = mux.spawn_window(cmd or {})
  local gui_window = window:gui_window()

  -- Get screen dimensions
  local screen = wezterm.gui.screens().active
  local screen_width = screen.width
  local screen_height = screen.height

  -- Calculate window dimensions (5/7 width, 4/5 height)
  local window_width = math.floor(screen_width * 5 / 7)
  local window_height = math.floor(screen_height * 4 / 5)

  -- Calculate position to center the window
  local position_x = math.floor((screen_width - window_width) / 2)
  local position_y = math.floor((screen_height - window_height) / 2)

  -- Set window size and position
  gui_window:set_inner_size(window_width, window_height)
  gui_window:set_position(position_x, position_y)
end)

-- Event handler for toggling tab bar
wezterm.on("toggle-tabbar", function(window, pane)
  local overrides = window:get_config_overrides() or {}
  if not overrides.enable_tab_bar then
    overrides.enable_tab_bar = false
  else
    overrides.enable_tab_bar = nil
  end
  window:set_config_overrides(overrides)
end)

-- Event handler for toggling scrollbar
wezterm.on("toggle-scrollbar", function(window, pane)
  local overrides = window:get_config_overrides() or {}
  if not overrides.enable_scroll_bar then
    overrides.enable_scroll_bar = true
  else
    overrides.enable_scroll_bar = nil
  end
  window:set_config_overrides(overrides)
end)

-- Custom tab title formatter
wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  local title = tab.tab_title
  -- Fallback to active pane title if tab title not set
  if not title or #title == 0 then
    title = tab.active_pane.title
  end

  -- Get current working directory
  local cwd = tab.active_pane.current_working_dir
  if cwd then
    cwd = cwd.file_path or cwd
    -- Extract just the directory name
    local dir = cwd:match("([^/]+)/?$")
    if dir then
      title = dir
    end
  end

  -- Add process icon based on foreground process
  local process_name = tab.active_pane.foreground_process_name
  local process_icon = "  "
  if process_name then
    if process_name:find("vim") or process_name:find("nvim") then
      process_icon = " "
    elseif process_name:find("node") then
      process_icon = " "
    elseif process_name:find("python") then
      process_icon = " "
    elseif process_name:find("git") then
      process_icon = " "
    elseif process_name:find("docker") then
      process_icon = " "
    elseif process_name:find("cargo") or process_name:find("rust") then
      process_icon = " "
    end
  end

  local formatted_title = string.format(" %s%s ", process_icon, title)

  -- Truncate if needed
  if #formatted_title > max_width then
    formatted_title = wezterm.truncate_right(formatted_title, max_width)
  end

  return formatted_title
end)

return config
