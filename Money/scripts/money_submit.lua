function onInit()
  if GameSystem.currencyDefault then
		window["money_type"].setValue(GameSystem.currencyDefault)
	end
  window["money_times"].setValue(1)
end

function onButtonPress()
  local db = window.getDatabaseNode()
  if db == nil then
    ChatManager.SystemMessage("ERROR: DB is nil?  Something went wrong")
    return
  end

  local pos
  if self.getName() == "add" then
    pos = 0
  else
    pos = 1
  end
  local orig_value = window["money_amount"].getValue()
  local times = window["money_times"].getValue()
  if times <= 0 then
    ChatManager.SystemMessage("ERROR: Times must be > 1")
  end
  value = orig_value * times
  local reason = window["money_reason"].getValue()
  local money_type = window["money_type"].getValue()
  if money_type == "" then
    ChatManager.SystemMessage("ERROR: Must specify money type")
    return
  end
  if reason == "" then
    ChatManager.SystemMessage("ERROR: Must specify reason")
    return
  end
  if pos == 1 then
    value = value * -1
  end
  if value == 0 then
    ChatManager.SystemMessage("ERROR: Value cant be zero")
    return
  end

  local aMoney = Money.getMoneyInfo(db)
  local money = aMoney[money_type]
  if money == nil then
    ChatManager.SystemMessage("ERROR: Unable to find money type: '" .. money_type .. "'")
    return
  end

  if value + money.amount() < 0 then
    for _,name in pairs(Money.higherCoins(money.name)) do
		  if aMoney[name] and aMoney[name].amount() > 0 then
				local amt = Money.convertFromTo(1, name, money.name)
			  aMoney[name].alter(-1)
				money.alter(amt)
			  ChatManager.SystemMessage("NOTICE: Converting 1 " .. name .. " to " .. amt .. " " .. money.name .. ", New total=" .. money.amount())
				break
			end
		end
		if value + money.amount() < 0 then
		  local total=0
			for _,name in pairs(Money.lowerCoins(money.name)) do
				if aMoney[name] and aMoney[name].amount() > 0 then
				  total = total + Money.convertFromTo(aMoney[name].amount(), name, money.name)
				end
			end
			if value + money.amount() + total < 0 then
				ChatManager.SystemMessage("ERROR: Unable to alter money.  current_value=" .. money.amount() .. ". Convertable amount=" .. money.amount() + total .. money.name)
				return
			end
			local need = math.abs(value + money.amount())
			for _,name in pairs(Money.lowerCoins(money.name)) do
				if aMoney[name] and aMoney[name].amount() > 0 then
				  whole, frac = Money.convertFromTo(aMoney[name].amount(), name, money.name)
					convert = math.min(need, whole)
					local not_convert = whole - convert
					if not_convert > 0 then
						frac = frac + Money.convertFromTo(not_convert, money.name, name)
					end
					local converted = Money.convertFromTo(convert, money.name, name)
					ChatManager.SystemMessage("NOTICE: Converting " .. converted .. " " .. name .. " into " .. convert .. " " .. money.name .. " (leaving " .. frac .. " " .. name .. ")")
					money.alter(convert)
					aMoney[name].set(frac)
					need = need - convert
					if (need == 0) then
						break
					end
				end
			end
		end
  end

  local chat = ChatManager.createBaseMessage();
  local name = db.getChild('name').getValue()
  local text=nil
  if (value > 0) then
    text = " ADD "
  else
    text = " SUBTRACT "
  end
  times_text = ""
  if times > 1 then
    times_text = " " .. times .. "X" .. " (" .. math.abs(value) .. money_type .. ")"
  end

  chat.text = name .. text .. orig_value ..  money_type .. times_text .. " reason=" .. reason
  Comm.deliverChatMessage(chat)
  money.alter(value)
  window["money_reason"].setValue("")
  -- window["money_amount"].setValue(0)
end
