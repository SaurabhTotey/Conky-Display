require "cairo"
local http = require("socket.http")
local json = require("/Development/Personal/Conky-Display/src/json")
local DrawingUtility = require("/Development/Personal/Conky-Display/src/DrawingUtility")

environmentVariables = nil

--[[
Main entry point of the application
Gets repeatedly called every update
]]
function conky_main()

	--Ensure that the conky window acutally exists for what we are doing
	if conky_window == nil then
		return
	end

	--Create variables useful for drawing and such: will need to get passed into the draw function and then freed
	local cairoSurface = cairo_xlib_surface_create(conky_window.display, conky_window.drawable, conky_window.visual, conky_window.width, conky_window.height)
	local cairoContext = cairo_create(cairoSurface)

	--Extract environment variables if they haven't yet been set
	if environmentVariables == nil then
		environmentVariables = {}
		for line in io.lines("Development/Personal/Conky-Display/.env") do
			local splitIndex = string.find(line, "=")
			environmentVariables[string.sub(line, 1, splitIndex - 1)] = string.sub(line, splitIndex + 1, string.len(line))
		end
	end

	draw(cairoSurface, cairoContext)

	--Free resources
	DrawingUtility.freeAllImages();
	cairo_destroy(cairoContext)
	cairo_surface_destroy(cairoSurface)

end


--[[
The draw function that describes how the window will look
]]
function draw(surface, context)

	-------------------- LEFT DIVIDER --------------------
	DrawingUtility.drawLine(context, conky_window.width / 2, 50, conky_window.width / 2, conky_window.height - 140)

	-------------------- TITLE --------------------
	local titleText = "Saurabh Totey"
	DrawingUtility.setTextOptions(context, 100)
	local titleSize = DrawingUtility.getTextSize(context, titleText)
	DrawingUtility.writeText(context, titleText, conky_window.width * 3 / 4 - titleSize.w / 2, titleSize.h + 10)

	-------------------- CONSTANTS FOR FIRST ROW --------------------
	local firstRowPadding = 50
	local firstRowNumberOfColumns = 3
	local columnWidth = (conky_window.width / 2 - (firstRowNumberOfColumns + 1) * firstRowPadding) / firstRowNumberOfColumns
	local rowWidth = 280
	local rowX = conky_window.width / 2
	local rowY = titleSize.h + 80

	-------------------- WEATHER --------------------
	--Draw rectangle around area for displaying weather; is only used for debugging
	DrawingUtility.drawRectangle(context, DrawingUtility.Rectangle(rowX + firstRowPadding, rowY, columnWidth, rowWidth))
	--Load weather data
	local weatherDataString, status, headers = http.request("http://api.openweathermap.org/data/2.5/weather?appid=" .. environmentVariables["WEATHER_KEY"] .. "&id=" .. environmentVariables["CITY_ID"] .. "&units=metric")
	local weatherData = json.decode(weatherDataString)
	--Load weather icon file information
	local iconImageData, status, headers = http.request("http://openweathermap.org/img/wn/" .. weatherData["weather"][1]["icon"] .. "@2x.png")
	local weatherIconPath = "/home/saurabhtotey/Development/Personal/Conky-Display/assets/weatherIcon.png"
	local weatherIconFile = assert(io.open(weatherIconPath, "wb"))
	weatherIconFile:write(iconImageData)
	weatherIconFile:close()
	--Get weather icon as a surface and manipulate/draw it
	local weatherIcon = DrawingUtility.getImageSurface(weatherIconPath)
	local scaleX = columnWidth / 2 / cairo_image_surface_get_width(weatherIcon)
	local scaleY = columnWidth / 2 / cairo_image_surface_get_height(weatherIcon)
	cairo_scale(context, scaleX, scaleY)
	cairo_set_source_surface(context, weatherIcon, (rowX + firstRowPadding) / scaleX, rowY / scaleY)
	cairo_paint(context)
	cairo_scale(context, 1 / scaleX, 1 / scaleY)
	--Write the weather description
	local weatherDescription = weatherData["weather"][1]["description"]
	local weatherDescriptionFontSize = 1000
	DrawingUtility.setTextOptions(context, weatherDescriptionFontSize)
	local weatherDescriptionSize = DrawingUtility.getTextSize(context, weatherDescription)
	while weatherDescriptionSize.w > columnWidth / 2 - 25 do
		weatherDescriptionFontSize = weatherDescriptionFontSize - 1
		DrawingUtility.setTextOptions(context, weatherDescriptionFontSize)
		weatherDescriptionSize = DrawingUtility.getTextSize(context, weatherDescription)
	end
	DrawingUtility.writeText(context, weatherDescription, rowX + firstRowPadding + columnWidth / 2, rowY + rowWidth / 2)
	--Write the temperature
	local temperature = math.floor(weatherData["main"]["temp"] + 0.5) .. "°C"
	DrawingUtility.setTextOptions(context, 50)
	local temperatureSize = DrawingUtility.getTextSize(context, temperature)
	DrawingUtility.writeText(context, temperature, rowX + firstRowPadding + columnWidth / 2, rowY + rowWidth / 2 + temperatureSize.h)

	-------------------- WORD OF THE DAY --------------------
	--Draw rectangle around area for displaying the word of the day; is only used for debugging
	DrawingUtility.drawRectangle(context, DrawingUtility.Rectangle(rowX + firstRowPadding * 2 + columnWidth, rowY, columnWidth, rowWidth))

	-------------------- TIME AND DAY --------------------
	--Draw rectangle around area for displaying the date/time; is only used for debugging
	DrawingUtility.drawRectangle(context, DrawingUtility.Rectangle(rowX + firstRowPadding * 3 + columnWidth * 2, rowY, columnWidth, rowWidth))

end
