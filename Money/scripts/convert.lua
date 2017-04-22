function onButtonPress()
  local db = window.getDatabaseNode()
  local amount = window["money_convert_amt"].getValue()
  local from = window["money_convert_from"].getValue()
  local to = window["money_convert_to"].getValue()
  Money.convert(db, amount, from, to)
end

