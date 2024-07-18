local isDead = false

function ShowBillsMenu()
	ESX.TriggerServerCallback('esx_billing:getBills', function(bills)
		if #bills > 0 then
			local elements = {}

			for k,v in ipairs(bills) do
				elements[#elements+1] = {
					icon = "fas fa-scroll",
					title = ('%s - %s '):format(v.label, TranslateCap('invoices_item', ESX.Math.GroupDigits(v.amount))),
					billId = v.id,
					onSelect = function()
						local billId = v.id
						
						ESX.TriggerServerCallback('esx_billing:payBill', function(resp)
							ShowBillsMenu()
		
							if not resp then
								return
							end
							TriggerEvent("esx_billing:paidBill", billId)
						end, billId)
					end
				}
			end

			lib.registerContext({
				id = 'bills',
				title = TranslateCap('invoices'),
				icon = "fas fa-scroll",
				options = elements
			})

			lib.showContext('bills')
		else
			ESX.ShowNotification(TranslateCap('no_invoices'))
		end
	end)
end

RegisterCommand('sendbill', function()
	local input = lib.inputDialog('FACTURE AMBULANCE', {'Amount'})
	local Player = PlayerPedId()

	if input then
		 local amount = tonumber(input[1])
	 
		 TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(Player), 'society_police', 'Facture Ambulance', amount)
	 end
end, false)

RegisterCommand('showbills', function()
	if not isDead then
		ShowBillsMenu()
	end
end, false)

RegisterKeyMapping('showbills', TranslateCap('keymap_showbills'), 'keyboard', 'F7')

AddEventHandler('esx:onPlayerDeath', function() isDead = true end)
AddEventHandler('esx:onPlayerSpawn', function(spawn) isDead = false end)
