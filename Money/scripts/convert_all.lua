function onButtonPress()
  local db = window.getDatabaseNode()
  local amount = window["money_convert_amt"].getValue()
  local to = "GP"
  local aMoney = Money.getMoneyInfo(db)
  for name, value in pairs(Money.getConversions()) do
    if name ~= to then
      local from_money = aMoney[name]
      if from_money ~= nil then
        if (from_money.amount() > 0) then
          Money.convert(db, from_money.amount(), from_money.name, to)
        end
      end
    end
	end
end

