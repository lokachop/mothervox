ZVox = ZVox or {}

ZVox.CreditsFrame = ZVox.CreditsFrame
function ZVox.OpenCredits()
	if IsValid(ZVox.CreditsFrame) then
		ZVox.CreditsFrame:Close()
	end

	ZVox.CreditsFrame = vgui.Create("ZVUI_DFrame")
	ZVox.CreditsFrame:SetSize(800, 600)
	ZVox.CreditsFrame:Center()
	ZVox.CreditsFrame:MakePopup()
	ZVox.CreditsFrame:SetTitle("ZVox Credits")



	local creditsScrollPanel = vgui.Create("ZVUI_DScrollPanel", ZVox.CreditsFrame)
	creditsScrollPanel:Dock(FILL)

	local creditsSorted = ZVox.GetSortedCreditsList()
	for i = 1, #creditsSorted do
		local entrySID = creditsSorted[i]
		local creditEntry = ZVox.GetCreditsEntry(entrySID)

		if creditEntry.hidden then
			continue
		end

		local panelCredits = vgui.Create("ZVUI_PlayerCreditPanel", creditsScrollPanel)
		panelCredits:Dock(TOP)

		panelCredits:SetSteamID64(entrySID)

		panelCredits:SetName(creditEntry.name)
		panelCredits:SetNameColour(creditEntry.nameColor)

		panelCredits:SetRole(creditEntry.role)
	end
end



concommand.Add("zvox_open_credits", function()
	ZVox.OpenCredits()
end)