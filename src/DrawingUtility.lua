require "cairo"

local DrawingUtility = {}

local storedImageSurfaces = {}

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

	--Setting the configurations for drawing this text
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
Gets a surface that represents the image at the given path
]]
function DrawingUtility.getImageSurface(path)
	local imageSurface = cairo_image_surface_create_from_png(path);
	table.insert(storedImageSurfaces, imageSurface);
	return imageSurface
end

--[[
Frees all references to stored image surfaces so that no memory leaks occur
]]
function DrawingUtility.freeAllImages()
	for i = 1, table.getn(storedImageSurfaces) do
		cairo_surface_destroy(storedImageSurfaces[i])
		storedImageSurfaces[i] = nil
	end
end

return DrawingUtility
