require "cairo"

local LayoutUtility = {
	displayElementInstances = {}
}

--[[
Initializes the LayoutUtility and sets how it should draw things
]]
function LayoutUtility.initialize(totalRows, totalCols, elementPadding)
	--TODO: assert that initialize hasn't been called before (totalRows and totalCols are uninitialized)

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
	--TODO: assert that LayoutUtility has been initialized (totalRows and totalCols are initialized)

	--TODO: find first unoccupied row and col; go by rows first and then by cols
	local currentRow = 0
	local currentCol = 0

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
	--TODO: assert that LayoutUtility has been initialized (totalRows and totalCols are initialized)

	for i, elementInstance in ipairs(LayoutUtility.displayElementInstances) do
		local row = elementInstance.row
		local col = elementInstance.col
		local rowSpan = elementInstance.displayElement.rowSpan
		local colSpan = elementInstance.displayElement.colSpan

		--TODO: initialize x, y, w, and h correctly
		local x = col
		local y = row
		local w = colSpan
		local h = rowSpan

		cairo_translate(context, x, y)
		elementInstance.displayElement.render(w, h)
		cairo_identity_matrix(context)
	end
end

return LayoutUtility
