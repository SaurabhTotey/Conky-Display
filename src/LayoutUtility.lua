require "cairo"

--TODO: see if caching renders is possible (eg. draw them on a saved surface?) and allow components to specify when they should be updated/re-rendered

local LayoutUtility = {
	displayElementInstances = {}
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
Creates a display element which is a rectangular section of something to draw
It must define a render method (where the coordinates of the drawing happen relative to (0,0)) and give a row and column span
render should take in a context, width, and a height
]]
function LayoutUtility.createDisplayElement(rowSpan, colSpan, render)
	return {
		rowSpan = rowSpan,
		colSpan = colSpan,
		render = render
	}
end

--[[
Accepts a display element to start rendering
Always places the display element in the lowest row first and then the first available column
]]
function LayoutUtility.addDisplayElement(displayElement)
	assert(LayoutUtility.isInitialized())

	--Returns whether the given row and column is occupied by another display element
	function isSpaceOccupied(r, c)
		for i, elementInstance in ipairs(LayoutUtility.displayElementInstances) do
			if elementInstance.row <= r and elementInstance.row + elementInstance.displayElement.rowSpan > r and elementInstance.col <= c and elementInstance.displayElement.colSpan > c then
				return true
			end
		end
		return false
	end

	--Finds the first unoccupied row and column TODO: this can be made more efficient and can be improved to stop overlaps
	local currentRow = -1
	local currentCol = -1
	for row = 0, LayoutUtility.totalRows - 1 do
		for col = 0, LayoutUtility.totalCols - 1 do
			if not isSpaceOccupied(row, col) then
				currentRow = row
				currentCol = col
				break
			end
		end
		if currentRow ~= -1 then
			break
		end
	end

	--Adds an instance of the displayElement to the LayoutUtility: instance contain all the information of a display element in additon to position
	table.insert(LayoutUtility.displayElementInstances, {
		displayElement = displayElement,
		row = currentRow,
		col = currentCol
	})
end

--[[
Actually renders all display elements and handles the coordinate transformations to ensure that all render calls work correctly
]]
function LayoutUtility.render(context)
	assert(LayoutUtility.isInitialized())

	local columnWidth = (conky_window.width / 2 - LayoutUtility.elementPadding * (LayoutUtility.totalCols + 1)) / LayoutUtility.totalCols
	local rowHeight = (conky_window.height - LayoutUtility.elementPadding * (LayoutUtility.totalRows + 1)) / LayoutUtility.totalRows

	for i, elementInstance in ipairs(LayoutUtility.displayElementInstances) do
		local row = elementInstance.row
		local col = elementInstance.col
		local rowSpan = elementInstance.displayElement.rowSpan
		local colSpan = elementInstance.displayElement.colSpan

		local x = col * columnWidth + (col + 1) * LayoutUtility.elementPadding + conky_window.width / 2
		local y = row * rowHeight + (row + 1) * LayoutUtility.elementPadding
		local w = columnWidth * colSpan + (colSpan - 1) * LayoutUtility.elementPadding
		local h = rowHeight * rowSpan + (rowSpan - 1) * LayoutUtility.elementPadding

		cairo_translate(context, x, y)
		elementInstance.displayElement.render(context, w, h)
		cairo_identity_matrix(context)
	end
end

return LayoutUtility
