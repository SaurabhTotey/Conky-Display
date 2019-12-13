require "cairo"

local LayoutUtility = {
	displayElementInstances = {}
}

--[[
Initializes the LayoutUtility and sets how it should draw things
]]
function LayoutUtility.initialize(totalRows, totalCols, elementPadding)
	assert(LayoutUtility.totalRows == nil and LayoutUtility.totalCols == nil and LayoutUtility.elementPadding == nil)

	LayoutUtility.totalRows = totalRows
	LayoutUtility.totalCols = totalCols
	LayoutUtility.elementPadding = elementPadding
end

--[[
Creates a display element which is a rectangular section of something to draw
It must define a render method (where the coordinates of the drawing happen relative to (0,0)) and give a row and column span
render should take in a width and a height
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
	assert(LayoutUtility.totalRows ~= nil and LayoutUtility.totalCols ~= nil and LayoutUtility.elementPadding ~= nil)

	--Returns whether the given row and column is occupied by another display element
	function isSpaceOccupied(r, c)
		for i, elementInstance in ipairs(LayoutUtility.displayElementInstances) do
			if elementInstance.row <= r and elementInstance.row + elementInstance.displayElement.rowSpan > r and elementInstance.col <= c and elementInstance.displayElement.colSpan > c then
				return true
			end
		end
		return false
	end

	--Finds the first unoccupied row and column TODO: this can be made more efficient
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
	assert(LayoutUtility.totalRows ~= nil and LayoutUtility.totalCols ~= nil and LayoutUtility.elementPadding ~= nil)

	for i, elementInstance in ipairs(LayoutUtility.displayElementInstances) do
		local row = elementInstance.row
		local col = elementInstance.col
		local rowSpan = elementInstance.displayElement.rowSpan
		local colSpan = elementInstance.displayElement.colSpan

		local w = (conky_window.width / 2 - LayoutUtility.elementPadding * (LayoutUtility.totalCols + 1)) / LayoutUtility.totalCols * colSpan
		local h = (conky_window.height - LayoutUtility.elementPadding * (LayoutUtility.totalRows + 1)) / LayoutUtility.totalRows * rowSpan
		local x = (col - 1) * w + col * LayoutUtility.elementPadding
		local y = (row - 1) * h + row * LayoutUtility.elementPadding

		cairo_translate(context, x, y)
		elementInstance.displayElement.render(w, h)
		cairo_identity_matrix(context)
	end
end

return LayoutUtility
