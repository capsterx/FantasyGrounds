
function onInit()
  window.select_label.setValue("Select User")
  window.select_node.setValue("")
end

function onClickDown()
  setVisible(false)
  window.transfer.setVisible(false)
  window.select_user.closeAll()
  local db = window.getDatabaseNode()
  for _,v in pairs(DB.getChildren("partysheet.partyinformation")) do
    local sClass, sRecord = DB.getValue(v, "link");
    if sClass == "charsheet" and sRecord then
      local name = DB.getValue(v, "name");
      local name = StringManager.trim(DB.getValue(v, "name", ""));
      if sRecord ~= db.getPath() then
        local w = window.select_user.createWindow();
        w.name.setValue(name);
        w.link.setValue(sRecord)
      end
    end
  end
  local w = window.select_user.createWindow();
  w.name.setValue("PARTYSHEET");
  w.link.setValue("partysheet")
    
  window.select_user.setVisible(true)
end
