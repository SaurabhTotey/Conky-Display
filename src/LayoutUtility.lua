require "cairo"

--TODO: see if caching renders is possible (eg. draw them on a saved surface?) and allow components to specify when they should be updated/re-rendered

local LayoutUtility = {
	displayElements = {}
}

--[[
Initializes the LayoutUtility and sets how it should draw things
]]
function LayoutUtility.initialize(totalRows, totalCols, elementPadding)
	assert(not LayoutUtility.isInitialized())

	LayoutUtility.totalRows = totalRows
	LayoutUtility.totalCols = totalCols
	LayoutUtility.elementPadding = elementPadding
end

--[[
Returns whether this LayoutUtility has been initialized
]]
function LayoutUtility.isInitialized()
	return LayoutUtility.totalRows ~= nil and LayoutUtility.totalCols ~= nil and LayoutUtility.elementPadding ~= nil
end

--[[
Adds a display element to this layout utility which is a rectangular section of something to draw
It must define a key and render method (where the coordinates of the drawing happen relative to (0,0)) and give a row, column, row span, and column span
render should take in a context, width, height, and a key
The element is only re-rendered whenever the key is nil or returns a different value from the previous render
]]
function LayoutUtility.addDisplayElement(row, col, rowSpan, colSpan, render, key)
	table.insert(LayoutUtility.displayElements, {
		row = row,
		col = col,
		rowSpan = rowSpan,
		colSpan = colSpan,
		render = render,
		key = key
	})
end

--[[
Actually renders all display elements and handles the coordinate transformations to ensure that all render calls work correctly
TODO: manage keys and not rendering elements with unchanged keys
]]
function LayoutUtility.render(context)
	assert(LayoutUtility.isInitialized())

	local columnWidth = (conky_window.width / 2 - LayoutUtility.elementPadding * (LayoutUtility.totalCols + 1)) / LayoutUtility.totalCols
	local rowHeight = (conky_window.height - LayoutUtility.elementPadding * (LayoutUtility.totalRows + 1)) / LayoutUtility.totalRows

	for i, displayElement in ipairs(LayoutUtility.displayElements) do
		local keyChanged = displayElement.key == nil --TODO: or displayElement.key returns a different value
		if not keyChanged then
			goto continue --TODO: we still need to render the element, we just don't need to re-run displayElement.render
		end

		local row = displayElement.row
		local col = displayElement.col
		local rowSpan = displayElement.rowSpan
		local colSpan = displayElement.colSpan

		local x = col * columnWidth + (col + 1) * LayoutUtility.elementPadding + conky_window.width / 2
		local y = row * rowHeight + (row + 1) * LayoutUtility.elementPadding
		local w = columnWidth * colSpan + (colSpan - 1) * LayoutUtility.elementPadding
		local h = rowHeight * rowSpan + (rowSpan - 1) * LayoutUtility.elementPadding

		cairo_translate(context, x, y)
		displayElement.render(context, w, h)
		cairo_identity_matrix(context)

		::continue::
	end
end

return LayoutUtility
