require "cairo"

local DrawingUtility = {}

--[[
A function that sets the context's color to the given r, g, b, and a values
Default color is purple
]]
function DrawingUtility.setColor(context, r, g, b, a)

	--Getting parameters
	r = r or 138
	g = g or 43
	b = b or 226
	a = a or 255

	--Actually setting color of context
	cairo_set_source_rgba(context, r / 255, g / 255, b / 255, a / 255)

end

--[[
A function that sets the options for writing and drawing text on the screen
]]
function DrawingUtility.setTextOptions(context, fontSize, fontFamily, r, g, b, a, fontWeight, fontSlant)

	--Getting parameters
	fontSize = fontSize or 12
	fontFamily = fontFamily or "mono"
	fontWeight = fontWeight or CAIRO_FONT_WEIGHT_NORMAL
	fontSlant = fontSlant or CAIRO_FONT_SLANT_NORMAL

	--Setting the configurations for drawing this text
	cairo_select_font_face(context, fontFamily, fontSlant, fontWeight)
	cairo_set_font_size(context, fontSize)
	DrawingUtility.setColor(context, r, g, b, a)

end

--[[
A function that draws the given text at the given position
All parameters are required
It is probably useful to call DrawingUtility.setTextOptions before calling this method
]]
function DrawingUtility.writeText(context, text, x, y)
	cairo_move_to(context, x, y)
	cairo_show_text(context, text)
	cairo_stroke(context)
end

return DrawingUtility
