require "cairo"

local DrawingUtility = {}

--[[
A function that draws the given text at the given position
context, text, x, and y are required parameters
]]
function DrawingUtility.writeText(context, text, x, y, fontSize, fontFamily, r, g, b, a, fontWeight, fontSlant)

	--Getting parameters
	fontSize = fontSize or 12
	fontFamily = fontFamily or "mono"
	r = r or 138
	g = g or 43
	b = b or 226
	a = a or 255
	fontWeight = fontWeight or CAIRO_FONT_WEIGHT_NORMAL
	fontSlant = fontSlant or CAIRO_FONT_SLANT_NORMAL

	--Setting the configurations for drawing this text
	cairo_select_font_face(context, fontFamily, fontSlant, fontWeight)
	cairo_set_font_size(context, fontSize)
	cairo_set_source_rgba(context, r / 255, g / 255, b / 255, a / 255)

	--Actually drawing the text
	cairo_move_to(context, x, y)
	cairo_show_text(context, text)
	cairo_stroke(context)

end

return DrawingUtility
