function apply_max(rRoll)
	local bMax = rRoll.sDesc:match("%[MAX%]");
  -- Debug.chat("bmax=" .. bMax)
	if bMax then
		for _,vDie in ipairs(rRoll.aDice) do
			local sSign, sColor, sDieSides = vDie.type:match("^([%-%+]?)([dDrRgGbBpP])([%dF]+)");
			if sDieSides then
				local nResult;
				if sDieSides == "F" then
					nResult = 1;
				else
					nResult = tonumber(sDieSides) or 0;
				end
				
				if sSign == "-" then
					nResult = 0 - nResult;
				end
				
				vDie.result = nResult;
				if sColor == "d" or sColor == "D" then
					if sSign == "-" then
						vDie.type = "-b" .. sDieSides;
					else
						vDie.type = "b" .. sDieSides;
					end
				end
			end
		end
	end
end

local origModHeal
local origOnHeal

function modHeal(rSource, rTarget, rRoll)
  -- Debug.chat("modHeal")
  ActionHeal.modHeal(rSource, rTarget, rRoll)
  local bMax =  ModifierStack.getModifierKey("HEAL_MAX")
  if bMax then
    rRoll.sDesc = rRoll.sDesc .. " [MAX]"
  end
end

function onHeal(rSource, rTarget, rRoll)
  -- Debug.chat("onHeal")
  apply_max(rRoll)
  ActionHeal.onHeal(rSource, rTarget, rRoll)
end

function onInit()
  ActionsManager.registerModHandler("heal", modHeal);                                              
  ActionsManager.registerResultHandler("heal", onHeal);
end
