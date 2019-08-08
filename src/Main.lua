require "cairo"
local DrawingUtility = require("/Development/Personal/Conky-Display/src/DrawingUtility")

--[[
Main entry point of the application
Gets repeatedly called every update
]]
function conky_main()

	--Ensure that the conky window acutally exists for what we are doing
	if conky_window == nil then
		return
	end

	--Create variables useful for drawing and such: will need to get passed into the draw function and then freed
	local cairoSurface = cairo_xlib_surface_create(conky_window.display, conky_window.drawable, conky_window.visual, conky_window.width, conky_window.height)
	local cairoContext = cairo_create(cairoSurface)

	draw(cairoSurface, cairoContext)

	--Free resources
	cairo_destroy(cairoContext)
	cairo_surface_destroy(cairoSurface)

end


--[[
The draw function that describes how the window will look
]]
function draw(surface, context)

	-- TITLE --
	local titleText = "Saurabh Totey"
	DrawingUtility.setTextOptions(context, 150)
	local titleSize = DrawingUtility.getTextSize(context, titleText)
	DrawingUtility.writeText(context, titleText, conky_window.width * 3 / 4 - titleSize.w / 2, titleSize.h + 10)

end
