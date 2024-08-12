local wezterm = require("wezterm")

local config = wezterm.config_builder()

----------------------- Theme  ----------------------------

config.color_scheme = "Catppuccin Mocha"

-----------------------------------------------------------

config.keys = {
	------------------ toggling pane -----------------------------
	-- F12 to toggle the terminal pane on the side
	{
		key = "F12",
		action = wezterm.action_callback(function(_, pane)
			local tab = pane:tab()
			local panes = tab:panes_with_info()
			if #panes == 1 then
				pane:split({
					direction = "Right",
					size = 0.4,
				})
			elseif not panes[1].is_zoomed then
				panes[1].pane:activate()
				tab:set_zoomed(true)
			elseif panes[1].is_zoomed then
				tab:set_zoomed(false)
				panes[2].pane:activate()
			end
		end),
	},
	------------------ splitting panes -----------------------------
	-- split horizontal
	{
		key = "|",
		mods = "CTRL|SHIFT|ALT",
		action = wezterm.action.SplitHorizontal({}),
	},
	-- split vertical
	{
		key = "_",
		mods = "CTRL|SHIFT|ALT",
		action = wezterm.action.SplitVertical({}),
	},
	------------------ switching pane -----------------------------
	-- activate pane selection mode with the default alphabet (labels are "a", "s", "d", "f" and so on)
	{ key = "8", mods = "CTRL", action = wezterm.action.PaneSelect },
	-- activate pane selection mode with numeric labels
	{
		key = "9",
		mods = "CTRL",
		action = wezterm.action.PaneSelect({
			alphabet = "1234567890",
		}),
	},
	-- show the pane selection mode, but have it swap the active and selected panes
	{
		key = "0",
		mods = "CTRL",
		action = wezterm.action.PaneSelect({
			mode = "SwapWithActive",
		}),
	},
}

return config
