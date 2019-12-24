require "cairo"

local DrawingUtility = {}

--[[
A function that makes a rectangle
]]
function DrawingUtility.Rectangle(x, y, w, h)
	local rectangle = {}
	rectangle.x = x;
	rectangle.y = y;
	rectangle.w = w;
	rectangle.h = h;
	return rectangle;
end

--[[
A function that sets the context's color to the given r, g, b, and a values
Default color is black
]]
function DrawingUtility.setColor(context, r, g, b, a)

	--Getting parameters
	r = r or 0
	g = g or 0
	b = b or 0
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

	--Setting the configurations for drawing text
	cairo_select_font_face(context, fontFamily, fontSlant, fontWeight)
	cairo_set_font_size(context, fontSize)
	DrawingUtility.setColor(context, r, g, b, a)

end

--[[
Gets the size that a given string of text will take up when rendered under the current settings
]]
function DrawingUtility.getTextSize(context, text)
	local extents = cairo_text_extents_t:create()
	cairo_text_extents(context, text, extents)
	return DrawingUtility.Rectangle(extents.x_bearing, extents.y_bearing, extents.width, extents.height)
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

--[[
A function that fits the given text inside the given rectangle, growing to take up as much available space inside the rectangle as possible
align is an optional parameter that specifies whether the text should be centered or left aligned ("center", "left"); default is center
Will change the text fontSize
Returns the new text font size
]]
function DrawingUtility.fitTextInsideRectangle(context, text, rectangle, align)

	--Getting parameters
	align = align or "center"

	--Exits if the bounds are unusable
	if rectangle.w <= 0 or rectangle.h <= 0 then
		return
	end

	--Finds the biggest font size that will allow the text to fit inside the given rectangle
	local maximalFittingFontSize = 1000
	cairo_set_font_size(context, maximalFittingFontSize)
	local textSize = DrawingUtility.getTextSize(context, text)
	while textSize.w > rectangle.w or textSize.h > rectangle.h do
		maximalFittingFontSize = maximalFittingFontSize - 1
		cairo_set_font_size(context, maximalFittingFontSize)
		textSize = DrawingUtility.getTextSize(context, text)
	end

	--Write the text in the correct aligned position
	if align == "center" then
		DrawingUtility.writeText(context, text, rectangle.x + (rectangle.w - textSize.w) / 2, rectangle.y + (rectangle.h + textSize.h) / 2)
	else
		DrawingUtility.writeText(context, text, rectangle.x, rectangle.y + textSize.h)
	end

	return maximalFittingFontSize

end

--[[
Sets the options for how lines will be drawn on screen
Affects anything that is made with lines (such as rectangles)
]]
function DrawingUtility.setLineOptions(context, width, r, g, b, a, cap, join)

	--Getting parameters
	width = width or 1
	r = r or 255
	g = g or 255
	b = b or 255
	a = a or 255
	cap = cap or CAIRO_LINE_CAP_BUTT
	join = join or CAIRO_LINE_JOIN_MITER

	--Setting the configurations for drawing lines
	cairo_set_line_width(context, width)
	cairo_set_line_cap(context, cap)
	cairo_set_line_join(context, join)
	DrawingUtility.setColor(context, r, g, b, a)

end

--[[
Draws a line from the given x and y to the given x and y
]]
function DrawingUtility.drawLine(context, startX, startY, endX, endY)
	cairo_move_to(context, startX, startY)
	cairo_line_to(context, endX, endY)
	cairo_stroke(context)
end

--[[
Draws a rectangle using the given rectangle table
Uses line options
]]
function DrawingUtility.drawRectangle(context, rectangle)
	cairo_rectangle(context, rectangle.x, rectangle.y, rectangle.w, rectangle.h)
	cairo_stroke(context)
end

return DrawingUtility
