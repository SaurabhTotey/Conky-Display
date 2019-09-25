require "cairo"

local LayoutUtility = {
	displayElementInstances = {},
	currentRow = 0,
	currentCol = 0
}

--[[
Initializes the LayoutUtility and sets how it should draw things
]]
function LayoutUtility.initialize(totalRows, totalCols)
	--TODO: assert that initialize hasn't been called before (totalRows and totalCols are uninitialized)

	LayoutUtility.totalRows = totalRows
	LayoutUtility.totalCols = totalCols
end

--[[
Creates a display element which is a rectangular section of something to draw
It must define a render method (where the coordinates of the drawing happen relative to (0,0)) and give a row and column span
]]
function LayoutUtility.createDisplayElement(rowSpan, colSpan, render)
	return {
		rowSpan = rowSpan,
		colSpan = colSpan,
		render = render
	}
end

--[[
A function that returns whether the position at the specified row and column is occupied
]]
function LayoutUtility.isPositionOccupied(row, col)
	return false --TODO:
end

--[[
Accepts a display element to start rendering
Always places the display element in the lowest row first and then the first available column
]]
function LayoutUtility.addDisplayElement(displayElement)
	--TODO: assert that LayoutUtility has been initialized (totalRows and totalCols are initialized)

	--Adds an instance of the displayElement to the LayoutUtility: instance contain all the information of a display element in additon to position
	table.insert(LayoutUtility.displayElementInstances, {
		displayElement = displayElement,
		row = LayoutUtility.currentRow,
		col = LayoutUtility.currentCol
	})

	--TODO: update currentRow and currentCol
end

--[[
Actually renders all display elements and handles the coordinate transformations to ensure that all render calls work correctly
TODO: consult https://www.cairographics.org/manual/cairo-Transformations.html for cairo_translate and cairo_identity_matrix to reset transformation
]]
function LayoutUtility.render(context)
	--TODO:
end

return LayoutUtility
