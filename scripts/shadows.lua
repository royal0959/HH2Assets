-- the stuff below is made by Royal
-- they deserve a LOT of kudos for everything here

function rejuvenatorHit(damage, activator, caller)
	local damageThreshold = 1

	if damage < damageThreshold then
		return
	end

	caller:AddCond(43, 5, activator)

	timer.Simple(5, function()
		caller:Suicide()
	end)
end

function chargerLogic(_, activator)
	local callbacks = {}

	local function removeCallbacks() 
		for _, callbackData in pairs(callbacks) do
			activator:RemoveCallback(callbackData.Type, callbackData.ID)
		end
	end

	callbacks.keypress = { -- Apply animation when bot pushes M2
		Type = 7,
		ID = activator:AddCallback(7, function(_, key)
			if key ~= IN_ATTACK2 then
				return
			end
			
			if activator.m_flChargeMeter < 100 then
                return
            end

			activator:PlaySequence("Charger_Charge") 
		end),
	}

	callbacks.spawned = {
		Type = 1,
		ID = activator:AddCallback(1, function()
			removeCallbacks()
		end),
	}

	callbacks.died = {
		Type = 9,
		ID = activator:AddCallback(9, function()
			removeCallbacks()
		end),
	}
end

local function cashforhits(activator)
	local callbacks = {}

	local function removeCallbacks()
		for _, callbackId in pairs(callbacks) do
			activator:RemoveCallback(callbackId)
		end
	end

	callbacks.damagetype = activator:AddCallback(ON_DAMAGE_RECEIVED_PRE, function(_, damageInfo)
		-- PrintTable(damageInfo)

		local damage = damageInfo.Damage

		if damage <= 0 then
			return
		end

		local damageType = damageInfo.DamageType
		local hitter = damageInfo.Attacker

		if (damageType & DMG_BURN) ~= 0 then
			return
		end

		local isCrit = (damageType & DMG_CRITICAL) ~= 0

		if isCrit then
			damage = damage * 3
		end

		local curHealth = activator.m_iHealth

		local isLethal = curHealth - (damage + 1) <= 0

		if not isLethal then
			hitter:AddCurrency(10)
			return
		end
		
		if IsLethal then
			hitter:AddCurrency(100)
			return
		end

		if (damageType & DMG_BLAST) ~= 0 then
            hitter:AddCurrency(75) -- used to be 50
        --    print("explosive?")
        elseif (damageType & DMG_MELEE) == 0 and (damageType & DMG_CRITICAL) ~= 0 then -- this is used for headshots, may overlap with Instakill
            hitter:AddCurrency(150)
        --    print("crit?")
        elseif (damageType & DMG_MELEE) ~= 0 then
            hitter:AddCurrency(150)
        --    print("melee?")
        elseif (damageType & DMG_BULLET) ~= 0 then
            hitter:AddCurrency(100)
        --    print("bullet?")
		elseif (damageType & DMG_USE_HITLOCATIONS) ~= 0 then
            hitter:AddCurrency(100)
        --    print("fancier bullet?")
        else
            hitter:AddCurrency(100)
        --    print("hell if I know")
        end

	end)

	callbacks.spawned = activator:AddCallback(1, function()
		removeCallbacks()
	end)

	callbacks.died = activator:AddCallback(9, function()
		removeCallbacks()
	end)
end

function OnWaveSpawnBot(bot)
	timer.Simple(1, function()
		cashforhits(bot)
	end)
end

function playertracker(_, activator) -- the only thing here made by Sntr
	local callbacks = {}
	
	local function removeCallbacks()
		for _, callbackId in pairs(callbacks) do
			activator:RemoveCallback(callbackId)
		end
	end
	
	local function DeathCounter()

		local deathcount = activator.m_iDeaths
	
		if deathcount >= 3 and deathcount < 4
		then
			util.PrintToChat(activator,"You have received a $750 comeback bonus.")
			activator:AddCurrency(750)
		end
		if deathcount >= 5 and deathcount < 6
		then
			util.PrintToChat(activator,"You have received a $1500 comeback bonus.")
			activator:AddCurrency(1500)
		end
		if deathcount > 7 and deathcount < 8
		then
			util.PrintToChat(activator,"You have received a $3000 comeback bonus.")
			activator:AddCurrency(3000)
		end
	end
	
	callbacks.damagetype = activator:AddCallback(ON_DAMAGE_RECEIVED_PRE, function(_, damageInfo)

		local damage = damageInfo.Damage
		local curHealth = activator.m_iHealth
				
		if damage > curHealth and activator:InCond(70) == 1 then --  give full heal + uber when condition 70 is removed
			activator:AddCond(5,2.5)
			activator:AddHealth(300,1)
			activator:PlaySoundtoSelf("misc/halloween/merasmus_stun.wav")
			activator:RemoveCond(70) -- so people can't be undying forever
		end
	end)
	
--	callbacks.output = activator:AddCallback(ON_INPUT, function(_, medicbonus_relay)
--
--		local playerclass = activator.m_iClass
--		local playercount = math_counter.m_OutValue
--	
--		if playerclass == 5
--		then
--			activator:AddCurrency( playercount * 75 )
--		end
--	end)
		
	callbacks.spawned = activator:AddCallback(1, function()
		removeCallbacks()
	end)

	callbacks.died = activator:AddCallback(9, function()
		removeCallbacks()
		DeathCounter()
	end)
	
end

-- and here's the stuff made by Washy
-- likewise, plenty of kudos

function OnGameTick()
	for _, player in pairs(ents.GetAllPlayers()) do
		if player:IsRealPlayer() then
			if player.m_bUsingActionSlot == 1 and player.InteractCooldown ~= true then
				player.HoldTime = player.HoldTime + 1
				if player.HoldTime > 13 and player.InteractWith ~= "nothing" then
					ents.FindByName(player.InteractWith):AcceptInput("Press",_,player)
					ents.FindByName("dumpster_msg"):AcceptInput("Disable")
					ents.FindByName("dumpster_msg"):AcceptInput("Enable")
					player.InteractCooldown = true
					player.HoldTime = 0
					timer.Simple(2, function() player.InteractCooldown = false end)
				end
			else
				player.holdTime = 0
			end
		end
	end
end

function OnPlayerConnected(player)
	if player:IsRealPlayer() then
		player.HoldTime = 0
		player.InteractWith = "nothing"
		player.InteractCooldown = false
	end
end

function OnWaveStart()
	timer.Simple(0.5,function()
		ents.FindByName("dumpster_msg"):AddCallback(ON_START_TOUCH,
			function(_, player)
				if player:IsRealPlayer() and player.m_nCurrency >= 950 then
					player.InteractWith = "dumpsterbutton"
				end
			end)
		ents.FindByName("dumpster_msg"):AddCallback(ON_END_TOUCH,
			function(_, player)
				if player:IsRealPlayer() then
					player.InteractWith = "nothing"
				end
			end)
		ents.FindByName("vm_jugmsg"):AddCallback(ON_START_TOUCH,
			function(_, player)
				if player:IsRealPlayer() and player.m_nCurrency >= 2500 then
					player.InteractWith = "vm_jugbutton"
				end
			end)
		ents.FindByName("vm_jugmsg"):AddCallback(ON_END_TOUCH,
			function(_, player)
				if player:IsRealPlayer() then
					player.InteractWith = "nothing"
				end
			end)
		ents.FindByName("vm_quickrevmsg"):AddCallback(ON_START_TOUCH,
			function(_, player)
				if player:IsRealPlayer() and player.m_nCurrency >= 1500 then
					player.InteractWith = "vm_quickrevbutton"
				end
			end)
		ents.FindByName("vm_quickrevmsg"):AddCallback(ON_END_TOUCH,
			function(_, player)
				if player:IsRealPlayer() then
					player.InteractWith = "nothing"
				end
			end)
		ents.FindByName("vm_speedmsg"):AddCallback(ON_START_TOUCH,
			function(_, player)
				if player:IsRealPlayer() and player.m_nCurrency >= 3000 then
					player.InteractWith = "vm_speedbutton"

				end
			end)
		ents.FindByName("vm_speedmsg"):AddCallback(ON_END_TOUCH,
			function(_, player)
				if player:IsRealPlayer() then
					player.InteractWith = "nothing"
				end
			end)
			ents.FindByName("vm_blastermsg"):AddCallback(ON_START_TOUCH,
			function(_, player)
				if player:IsRealPlayer() and player.m_nCurrency >= 1500 then
					player.InteractWith = "vm_blasterbutton"
				end
			end)
		ents.FindByName("vm_blastermsg"):AddCallback(ON_END_TOUCH,
			function(_, player)
				if player:IsRealPlayer() then
					player.InteractWith = "nothing"
				end
			end)
		ents.FindByName("vm_dtmsg"):AddCallback(ON_START_TOUCH,
			function(_, player)
				if player:IsRealPlayer() and player.m_nCurrency >= 2000 then
					player.InteractWith = "vm_dtbutton"
				end
			end)
		ents.FindByName("vm_dtmsg"):AddCallback(ON_END_TOUCH,
			function(_, player)
				if player:IsRealPlayer() then
					player.InteractWith = "nothing"
				end
			end)
	--	ents.FindByName("vm_flopmsg"):AddCallback(ON_START_TOUCH,
	--		function(_, player)
	--			if player:IsRealPlayer() and player.m_nCurrency >= 1000 then
	--				player.InteractWith = "vm_flopbutton"
	--			end
	--		end)
	--	ents.FindByName("vm_flopmsg"):AddCallback(ON_END_TOUCH,
	--		function(_, player)
	--			if player:IsRealPlayer() then
	--				player.InteractWith = "nothing"
	--			end
	--		end)
	end)
end