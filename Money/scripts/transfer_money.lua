-- OOB_MSGTYPE_TRANSFER_MONEY = "transfer_money";

function onInit()
  -- OOBManager.registerOOBMsgHandler(OOB_MSGTYPE_TRANSFER_MONEY, handleTransferMoney);
end


function onButtonPress()
  local db = window.getDatabaseNode()
  local node = window.select_node.getValue()
  local currency = window.money_transfer_to.getValue()
  local amount = window.money_transfer_amt.getValue()
  
  if db == nil then
    ChatManager.SystemMessage("ERROR: No database?")
    return
  end

  if node == "" then
    ChatManager.SystemMessage("ERROR: Must Select a User")
    return
  end
  
  --local nodeTargetRecord = DB.findNode(node);
  --if not nodeTargetRecord then
  --  ChatManager.SystemMessage("ERROR: User does not exist?")
  --  return;
  --end
  local from = db.getChild('name').getValue()
  local to = window.select_label.getValue()

  if amount <= 0 then
    ChatManager.SystemMessage("ERROR: Amount must be >= 0")
    return
  end
  local aMoney_from = Money.getMoneyInfo(db)
  if aMoney_from[currency] == nil then
    ChatManager.SystemMessage("ERROR: " .. from .. " does not have currency '" .. currency .. "' in their inventory")
    return
  end
  if aMoney_from[currency].amount() < amount then
    ChatManager.SystemMessage("ERROR: " .. from .. " does not have " .. amount .. currency .. "' in their inventory.  There is only " .. aMoney_from[currency].amount())
    return
  end

  --local aMoney_to = Money.getMoneyInfo(nodeTargetRecord)
  --if aMoney_to[currency] == nil then
  --  ChatManager.SystemMessage("ERROR: " .. to .. " does not have currency '" .. currency .. "' in their inventory")
  --  return;
  --end

  local chat = ChatManager.createBaseMessage();

  chat.text = from .. " transfer " .. amount .. currency .. " to " .. to
  Comm.deliverChatMessage(chat)
  aMoney_from[currency].alter(-1 * amount)
  ItemManager.sendCurrencyTransfer (node, currency, amount) 
end
