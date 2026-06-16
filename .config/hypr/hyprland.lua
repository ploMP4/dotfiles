------------------
---- MONITORS ----
------------------

hl.monitor({
	output = "eDP-1",
	mode = "1920x1200@60",
	position = "0x0",
	scale = 1,
	disabled = true,
})

hl.monitor({
	output = "HDMI-A-1",
	mode = "1920x1024@60",
	position = "0x0",
	scale = 1,
})

---------------------
---- MY PROGRAMS ----
---------------------

local terminal = "ghostty"
local fileManager = "thunar"
local browser = "zen-browser"
local menu = "wofi --show drun"

-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
	hl.exec_cmd("waybar")
	hl.exec_cmd("/home/plo/sandbox/phonto/target/release/phonto --rand")
end)

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

hl.env("XCURSOR_SIZE", 24)
hl.env("HYPRCURSOR_SIZE", 24)
hl.env("GTK_THEME", "Arc-dark")

-----------------------
----- PERMISSIONS -----
-----------------------

hl.permission({ binary = "/usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland", type = "screencopy", mode = "allow" })

-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
	general = {
		gaps_in = 5,
		gaps_out = 3,

		border_size = 1,

		col = {
			active_border = {
				colors = { "rgba(33ccffee)", "rgba(00ff99ee)" },
				angle = 45,
			},
			inactive_border = "rgba(595959aa)",
		},

		resize_on_border = false,
		allow_tearing = false,
		layout = "dwindle",
	},

	decoration = {
		rounding = 4,
		rounding_power = 2,

		active_opacity = 1.0,
		inactive_opacity = 0.92,

		shadow = {
			enabled = true,
			range = 4,
			render_power = 3,
			color = "rgba(1a1a1aee)",
		},

		blur = {
			enabled = true,
			size = 4,
			passes = 2,
			vibrancy = 0.1696,
		},
	},

	animations = {
		enabled = true,
	},
})

hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })

hl.animation({ leaf = "global", enabled = false, speed = 10, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows", enabled = true, speed = 2.79, bezier = "quick" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.1, bezier = "quick", style = "popin 87%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.49, bezier = "quick", style = "popin 87%" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.73, bezier = "quick" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.46, bezier = "quick" })
hl.animation({ leaf = "fade", enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers", enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 4, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.5, bezier = "linear", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = false, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = false, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces", enabled = false, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn", enabled = false, 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = false, 1.94, bezier = "almostLinear", style = "fade" })

hl.config({
	dwindle = {
		preserve_split = true,
	},
})

hl.config({
	master = {
		new_status = "master",
	},
})

hl.config({
	scrolling = {
		fullscreen_on_one_column = true,
	},
})

hl.config({
	misc = {
		force_default_wallpaper = 1,
		disable_hyprland_logo = true,
		session_lock_xray = true,
	},
})

hl.config({
	input = {
		kb_layout = "us, gr",
		kb_variant = "",
		kb_model = "",
		kb_options = "grp:toggle",
		kb_rules = "",

		follow_mouse = 1,

		sensitivity = 0,

		touchpad = {
			natural_scroll = true,
		},
	},
})

hl.device({
	name = "epic-mouse-v1",
	sensitivity = -0.5,
})

---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "ALT"

hl.bind(mainMod .. "+ Return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. "+ Q", hl.dsp.window.close())
hl.bind(mainMod .. "+ E", hl.dsp.exec_cmd("~/.config/hypr/scripts/lock.sh"))
hl.bind(mainMod .. "+ N", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. "+ W", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. "+ Space", hl.dsp.window.float())
hl.bind(mainMod .. "+ D", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. "+ P", hl.dsp.window.pseudo())
hl.bind(mainMod .. "+ G", hl.dsp.group.toggle())
hl.bind(mainMod .. "+ F", hl.dsp.window.fullscreen())
hl.bind(
	mainMod .. "+ Print",
	hl.dsp.exec_cmd('hyprshot -m region && notify-send "Screenshot saved to ~/$(date +"%Y-%m-%d-%T")-screenshot.png"')
)
hl.bind(mainMod .. "+ S", hl.dsp.exec_cmd("killall -SIGUSR1 waybar"))
hl.bind(mainMod .. "+ B", hl.dsp.exec_cmd("~/.config/hypr/scripts/wallpaper-selector.sh"))
hl.bind("SUPER_L", hl.dsp.exec_cmd("~/sandbox/stochos/target/release/stochos --hint"))
hl.bind("SHIFT + SUPER_L", hl.dsp.exec_cmd("~/sandbox/stochos/target/release/stochos"))
hl.bind("CTRL + SUPER_L", hl.dsp.exec_cmd("~/sandbox/stochos/target/release/stochos --free"))

hl.bind(mainMod .. "+ h", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. "+ l", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. "+ k", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. "+ j", hl.dsp.focus({ direction = "down" }))

hl.bind(mainMod .. "+ SHIFT + h", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. "+ SHIFT + l", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. "+ SHIFT + k", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. "+ SHIFT + j", hl.dsp.window.move({ direction = "down" }))

for i = 1, 10 do
	local key = (i == 1 and 7)
		or (i == 2 and 8)
		or (i == 3 and 9)
		or (i == 7 and 1)
		or (i == 8 and 2)
		or (i == 9 and 3)
		or (i % 10)

	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

hl.bind(mainMod .. "+ mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. "+ mouse_up", hl.dsp.focus({ workspace = "e-1" }))

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys for volume and LCD brightness
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMicMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })

-- Requires playerctl
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

hl.window_rule({
	-- Ignore maximize requests from all apps. You'll probably like this.
	name = "suppress-maximize-events",
	match = { class = ".*" },

	suppress_event = "maximize",
})

hl.window_rule({
	name = "zen-on-workspace-2",
	match = { title = "^(.*Zen.*)" },
	move = "workspace 2",
})

hl.window_rule({
	name = "thunar-on-workspace-3",
	match = { title = "^(.*Thunar.*)" },
	move = "workspace 3",
})

hl.window_rule({
	name = "thunderbird-on-workspace-4",
	match = { title = "^(.*Thunderbird.*)" },
	move = "workspace 4",
})

hl.bind(
	"switch:off:Lid Switch",
	hl.dsp.exec_cmd('hyprctl keyword monitor "eDP-1, preferred, auto, 1"'),
	{ locked = true }
)

hl.bind("switch:on:Lid Switch", hl.dsp.exec_cmd('hyprctl keyword monitor "eDP-1, disable"'), { locked = true })
