
function onInit()
  Debug.chat("Init!", oldInit)
  registerMenuItem(Interface.getString("char_label_transfer"), "insert", 4);
end

function onMenuSelection(selection)
  if selection == 4 then
    local node = getDatabaseNode();
    if not node then
      Debug.chat("fail")
      close();
      return;
    end

    -- Debug.chat(User.getActiveIdentities())
    -- Debug.chat(User.getActiveUsers())
    -- Debug.chat(User.getAllActiveIdentities())
    -- Debug.chat(DB.getChildren("partysheet.partyinformation"))
    -- Debug.chat(GameSystem.requestCharSelectDetailClient())
    -- Debug.chat(GameSystem.receiveCharSelectDetailClient())
    -- Debug.chat("Start")
    -- Debug.chat(User.getRemoteIdentities("charsheet", "name", foobarfoo));
    -- Debug.chat("done with that")
    -- Debug.chat(DB.getRoot().getValue())
    -- Debug.chat(DB.getRoot().getChild('charsheet').getChildren())
    local party = DB.getRoot().getChild('partysheet.partyinformation').getChildren()
    local aParty = {}
    for _,v in pairs(party) do
      local sClass, sRecord = DB.getValue(v, "link");
      if sClass == "charsheet" and sRecord then
        local nodePC = DB.findNode(sRecord);
        if nodePC then
          local sName = DB.getValue(v, "name", "");
          table.insert(aParty, { name = sName, node = nodePC } );
        end
      end
    end
    Debug.chat(aParty)
    for _,v in ipairs(aParty) do
      Debug.chat(v.name)
      local amount = v.node.getChild("coins.slot1.amount")
      Debug.chat(amount.getValue())
      Debug.chat(amount)
      amount.setValue(amount.getValue() + 1)
      Debug.chat(v.node.getChild("coins.slot1.amount").getValue())
    end
  end
end

function foobarfoo(id, vDetails, nodeLocal)
  Debug.chat("foo")
  Debug.chat(id)
  Debug.chat(vDetails)
  Debug.chat(nodeLocal)
end
