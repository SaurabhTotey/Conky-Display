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

	-------------------- TITLE --------------------
	local titleText = "Saurabh Totey"
	DrawingUtility.setTextOptions(context, 150)
	local titleSize = DrawingUtility.getTextSize(context, titleText)
	DrawingUtility.writeText(context, titleText, conky_window.width * 3 / 4 - titleSize.w / 2, titleSize.h + 10)

	-------------------- WEATHER --------------------
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
	local scaleX = 512 / cairo_image_surface_get_width(weatherIcon)
	local scaleY = 512 / cairo_image_surface_get_height(weatherIcon)
	cairo_scale(context, scaleX, scaleY)
	cairo_set_source_surface(context, weatherIcon, conky_window.width / 2 / scaleX, (titleSize.h + 20) / scaleY)
	cairo_paint(context)
	cairo_scale(context, 1, 1)

end
