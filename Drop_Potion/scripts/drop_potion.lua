function onDrop(rSource, rTarget, draginfo)
  local sDragType = draginfo.getType();
  if sDragType == "shortcut" then
    local sClass, sRecord = draginfo.getShortcutData();
    if sClass == "item" then
      local node = draginfo.getDatabaseNode();
      local sSource = ItemManager.getItemSourceType(node)
      -- partysheet || charsheet
      if sSource == 'charsheet' then
        local desc = DB.getValue(node, "description", "")
        local name = DB.getValue(node, "name", "")
        local aActions = PowerManager.parsePower(name, desc, true);
        if #aActions ~= 1 then
          if #aActions > 1 then
            ChatManager.SystemMessage("ERROR: mutiple actions on item description")
          end
          return false
        end

        local action = aActions[1]
        if action['type'] ~= 'heal' then
          ChatManager.SystemMessage("ERROR: only heal actions supported")
          return false
        end

        local nCount = DB.getValue(node, "count", 0);
        if nCount > 0 then
          local rRolls = {}
          local roll = ActionHeal.getRoll(rTarget, action)
          table.insert(rRolls, roll);
          ActionsManager.performMultiAction(nil, rTarget, rRolls[1].sType, rRolls);
          
          DB.setValue(node, "count", "number", nCount - 1);
          local newCount = DB.getValue(node, "count", 0);

          return true
        else
          ChatManager.SystemMessage("ERROR: Not enough current inventory to apply")
          return true
        end
      end
    end
  end
end

function onInit()
  CombatManager.setCustomDrop(onDrop);
end
