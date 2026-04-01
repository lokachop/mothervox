ZVox = ZVox or {}

ZVox.CommunicationFrame = ZVox.CommunicationFrame
function ZVox.OpenCommunication(who, content)
	if IsValid(ZVox.CommunicationFrame) then
		ZVox.CommunicationFrame:Close()
	end

	ZVox.CommunicationFrame = vgui.Create("ZVUI_DFrame")
	ZVox.CommunicationFrame:SetSize(800, 600)
	ZVox.CommunicationFrame:Center()
	ZVox.CommunicationFrame:MakePopup()
	ZVox.CommunicationFrame:SetTitle("Communication")
	ZVox.CommunicationFrame:SetDraggable(true)

	ZVox.IncrementPauseStack()
	function ZVox.CommunicationFrame:OnClose()
		ZVox.DecrementPauseStack()
	end

	local fancyBG = vgui.Create("ZVUI_FancyDPanel", ZVox.CommunicationFrame)
	fancyBG:Dock(FILL)

	local pnlContainerScroll = vgui.Create("ZVUI_DScrollPanel", fancyBG)
	pnlContainerScroll:Dock(FILL)

	table.insert(content, 1, "")
	table.insert(content, 1, "'" .. who .. "'")
	table.insert(content, 1, "** Transmission Received **")
	table.insert(content, #content + 1, "** Transmission Terminated **")

	local col1 = Color(25, 189, 26)
	for i = 1, #content do
		local pnlContainerText = vgui.Create("DPanel", pnlContainerScroll)
		pnlContainerText:SetTall(48)
		pnlContainerText:Dock(TOP)

		function pnlContainerText:Paint(w, h)
			-- TODO: i don't have enough fucking time to figure out why this shit clips off

			ZVox.DrawRetroText(self, content[i], 0, h / 2, col1, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 4)
		end
	end

	surface.PlaySound("mothervox/sfx/ui/message.wav")
end