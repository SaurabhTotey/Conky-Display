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
It must define a render method (where the coordinates of the drawing happen relative to (0,0)) and give a row, column, row span, and column span
render should take in a context, width, and a height
]]
function LayoutUtility.addDisplayElement(row, col, rowSpan, colSpan, render)
	table.insert(LayoutUtility.displayElements, {
		row = row,
		col = col,
		rowSpan = rowSpan,
		colSpan = colSpan,
		render = render
	})
end

--[[
Actually renders all display elements and handles the coordinate transformations to ensure that all render calls work correctly
]]
function LayoutUtility.render(context)
	assert(LayoutUtility.isInitialized())

	local columnWidth = (conky_window.width / 2 - LayoutUtility.elementPadding * (LayoutUtility.totalCols + 1)) / LayoutUtility.totalCols
	local rowHeight = (conky_window.height - LayoutUtility.elementPadding * (LayoutUtility.totalRows + 1)) / LayoutUtility.totalRows

	for i, displayElement in ipairs(LayoutUtility.displayElements) do
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
	end
end

return LayoutUtility
