function onInit()
  if User.isHost() then
		local db = DB.getRoot().getChild("money_convert")
		if db == nil then
			DB.createNode("money_convert")
			db = DB.getRoot().getChild("money_convert")
			db.setPublic(true)
			COIN_CONVERT = { CP=1, SP=10, EP=50, GP=100, PP=1000 }
			for name, value in pairs(COIN_CONVERT) do
				local elm = db.createChild()
				local dbname = elm.createChild("name", "string")
				dbname.setValue(name)
				local dbvalue = elm.createChild("value", "number")
				dbvalue.setValue(value)
			end
		end
  end
end

function getConversions()
  local db = DB.getRoot().getChild("money_convert")
	local conversions = {}
  if db ~= nil then
    db = DB.getRoot().getChild("money_convert")
    for n,v in pairs(db.getChildren()) do
      local name = v.getChild("name").getValue()
      local value = v.getChild("value").getValue()
      conversions[name] = value
    end
  end
  return conversions
end

function covertToCP(value, currency)
  return value * getConversions()[currency]
end

function convertFromCP(value, currency)
  local whole = math.floor(value / getConversions()[currency])
	local rest = value - (whole * getConversions()[currency])
  return whole, rest
end

function convertFromTo(value, from, to)
  local whole, rest = convertFromCP(covertToCP(value, from), to)
	rest = convertFromCP(rest, from)
	return whole, rest
end

function higherCoins(currency)
  vals = {}
  for name, value in pairs(getConversions()) do
    if value > getConversions()[currency] then
      table.insert(vals, name)
    end
	end
	return vals
end

function lowerCoins(currency)
  local vals = {}
  for name, value in pairs(getConversions()) do
    if value < getConversions()[currency] then
      table.insert(vals, name)
    end
	end
	return vals
end

function getMoneyInfo(db)  
  local aMoney = {}
  for index=1,6 do
    local i = "coins.slot" .. index
    local name = db.getChild(i .. ".name").getValue()
    local amount_node = db.getChild(i .. ".amount")
    local amount = amount_node.getValue()
    if name ~= "" then
      aMoney[name] = { 
        name = name,
        amount = function() return amount_node.getValue() end,
        alter = function(x) amount_node.setValue(amount_node.getValue() + x) end,
        set = function(x) amount_node.setValue(x) end
      } ;
    end
  end
	return aMoney
end

function convert(db, amount, from, to)
  if db == nil then
    ChatManager.SystemMessage("ERROR: DB is nil?  Something went wrong")
    return
  end

  if amount <= 0 then
    ChatManager.SystemMessage("ERROR: Amount must be > 0")
    return
  end
  if money_type == "" then
    ChatManager.SystemMessage("ERROR: Must specify money type")
    return
  end

  local aMoney = getMoneyInfo(db)
  local from_money = aMoney[from]
  if from_money == nil then
    ChatManager.SystemMessage("ERROR: Unable to find money type: '" .. from .. "'")
    return
  end
  local to_money = aMoney[to]
  if to_money == nil then
    ChatManager.SystemMessage("ERROR: Unable to find money type: '" .. to .. "'")
    return
  end
  
  if amount > from_money.amount() then
	  if from_money.amount() == 0 then
			ChatManager.SystemMessage("ERROR: balance for " .. from_money.name .. " is 0")
		else
			ChatManager.SystemMessage("ERROR: Amount must be <= " .. from_money.amount())
		end
    return
  end

  local whole, frac = convertFromTo(amount, from_money.name, to_money.name)
  local removed = convertFromTo(whole, to_money.name, from_money.name)
  ChatManager.SystemMessage("NOTICE: Converting " .. amount .. " " .. from_money.name .. " into " .. whole .. " " .. to_money.name .. " (leaving " .. frac .. "+" .. (from_money.amount() - removed - frac) .. "=" .. (from_money.amount() - removed) .. from_money.name .. ")")
  to_money.alter(whole)
  from_money.alter(-1 * removed)
end
