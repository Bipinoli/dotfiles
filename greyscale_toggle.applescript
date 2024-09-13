try
	tell application "System Preferences"
		activate
		-- get properties
	end tell
	
	tell application "System Events"
		tell process "System Preferences"
			set frontmost to true
			delay 0.5
			get entire contents
			
			tell menu item "Search" of menu "View" of menu bar item "View" of menu bar 1
				click
				keystroke "D"
				keystroke "i"
				keystroke "s"
				keystroke "p"
				keystroke "l"
				keystroke "a"
				keystroke "y"
				keystroke " "
				keystroke "c"
				keystroke "o"
				keystroke "l"
				keystroke "o"
				keystroke "u"
				keystroke "r"
				keystroke " "
				keystroke "f"
				keystroke "i"
				keystroke "l"
				keystroke "t"
				keystroke "e"
				keystroke "r"
				keystroke return
				delay 1
				keystroke return
			end tell
			
			delay 2
			click checkbox "Enable Colour Filters" of tab group 1 of group 1 of window "Accessibility"
			
			get entire contents
		end tell
	end tell
	
	tell application "System Preferences"
		delay 0.5
		quit
	end tell
on error
	activate
	display dialog "Something went wrong!"
end try