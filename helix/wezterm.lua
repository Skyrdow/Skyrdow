-- Pull in the wezterm API
local wezterm = require 'wezterm'
local config = wezterm.config_builder()
local act = wezterm.action
config.default_cwd = "C:/Users/lucas/Documents/Git"

config.enable_kitty_keyboard = true
config.enable_kitty_graphics = true  
config.color_scheme = 'Argonaut'
config.font = wezterm.font("CaskaydiaMono Nerd Font", {weight = 'DemiBold'})
config.font_size = 13

config.window_decorations = "RESIZE|TITLE"
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true

config.window_padding = {
  left = 0,
  right = 0,
  top = 0,
  bottom = 0,
}

config.inactive_pane_hsb = {
  saturation = 0.9,
  brightness = 0.9,
}

config.use_dead_keys = false

config.keys = {
  {
    key = '+',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' },
  },
  {
    key = '_',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' },
  },
  {
    key = '~',
    mods = 'SHIFT',
    action = wezterm.action.CloseCurrentTab { confirm = true },
  },
  {
    key = 'w',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.CloseCurrentPane { confirm = true },
  },
  { key = 'LeftArrow', mods = 'SHIFT|CTRL', action = act.ActivatePaneDirection 'Left' },
  { key = 'LeftArrow', mods = 'SHIFT|ALT|CTRL', action = act.AdjustPaneSize{ 'Left', 5 } },
  { key = 'RightArrow', mods = 'SHIFT|CTRL', action = act.ActivatePaneDirection 'Right' },
  { key = 'RightArrow', mods = 'SHIFT|ALT|CTRL', action = act.AdjustPaneSize{ 'Right', 5 } },
  { key = 'UpArrow', mods = 'SHIFT|CTRL', action = act.ActivatePaneDirection 'Up' },
  { key = 'UpArrow', mods = 'SHIFT|ALT|CTRL', action = act.AdjustPaneSize{ 'Up', 5 } },
  { key = 'DownArrow', mods = 'SHIFT|CTRL', action = act.ActivatePaneDirection 'Down' },
  { key = 'DownArrow', mods = 'SHIFT|ALT|CTRL', action = act.AdjustPaneSize{ 'Down', 5 } },
  { key = ')', mods = 'SHIFT|CTRL', action = wezterm.action.ShowTabNavigator },
}

-- and finally, return the configuration to wezterm
return config
