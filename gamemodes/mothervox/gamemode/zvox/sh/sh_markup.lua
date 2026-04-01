ZVox = ZVox or {}

-- returns a MarkupText table
-- (table of tables)
function ZVox.ParseMarkup(message)
	local accR, accG, accB = 255, 255, 255

	local textLines = {}
	for ln in string.gmatch(message, "[^\n]+") do
		local lineEntry = {}
		local subbedLine = ln
		for i = 1, 512 do -- we won't have more than 512 tokens
			local findStart, findEnd, findStr = string.find(subbedLine, "^([^<>]+)") -- check for initial
			if findStart then
				findStr = string.gsub(findStr, "&gt;", ">")
				findStr = string.gsub(findStr, "&lt;", "<")
				findStr = string.gsub(findStr, "&amp;", "&")


				lineEntry[#lineEntry + 1] = {{accR, accG, accB }, findStr}
				subbedLine = string.sub(subbedLine, findEnd + 1)
			end

			findStart, findEnd, findStr = string.find(subbedLine, "^(%b<>[^<>]+)")
			if not findStart then
				break
			end

			local colBlock = string.match(findStr, "%b<>")
			if not colBlock then
				ZVox.PrintError("Malformed markup for ZVox.MarkupParse, full text below...")
				ZVox.PrintError(message)
				break
			end

			local r, g, b = string.match(colBlock, "<(%d+),(%d+),(%d+)>")
			accR = tonumber(r) or 0
			accG = tonumber(g) or 0
			accB = tonumber(b) or 0

			local msg = string.match(findStr, "%b<>([^<>]+)")

			-- replace &gt; and &lt; too
			msg = string.gsub(msg, "&gt;", ">")
			msg = string.gsub(msg, "&lt;", "<")
			msg = string.gsub(msg, "&amp;", "&")

			subbedLine = string.sub(subbedLine, findEnd + 1)
			lineEntry[#lineEntry + 1] = {{accR, accG, accB}, msg}
		end

		textLines[#textLines + 1] = lineEntry
	end

	return textLines
end


function ZVox.RenderMarkup(self, markupObject, textSz, xOff, yOff, alpha)
	xOff = xOff or 0
	yOff = yOff or 0
	textSz = textSz or 1
	alpha = alpha or 255

	local xAccum = xOff
	local yAccum = yOff
	local colAccumObj = Color(255, 255, 255)
	colAccumObj:SetUnpacked(255, 255, 255, alpha)
	for i = 1, #markupObject do
		local linesHere = markupObject[i]

		for j = 1, #linesHere do
			local lineHere = linesHere[j]

			local colEntry = lineHere[1]
			colAccumObj:SetUnpacked(colEntry[1], colEntry[2], colEntry[3], alpha)
			local tW = ZVox.DrawRetroText(self, lineHere[2], xAccum, yAccum, colAccumObj, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, textSz)
			xAccum = xAccum + tW
		end
		xAccum = xOff
		yAccum = yAccum + 12 * textSz -- NEWLINE!!
	end
end