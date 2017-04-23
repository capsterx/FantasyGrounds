function messageResult(bSecret, rSource, rTarget, rMessageGM, rMessagePlayer)
  local aWords=StringManager.parseWords(rMessageGM.text)
  local show = OptionsManager.getOption("SHRR")
  if aWords[1] == 'Attack' then
    local bHas = rMessageGM.text:find("CRITICAL") or rMessageGM.text:find("AUTOMATIC")
    if not bHas then
      OptionsManager.setOption("SHRR", 'off')
    end
  end
  origMessageResult(bSecret, rSource, rTarget, rMessageGM, rMessagePlayer) 
  OptionsManager.setOption("SHRR", show)
end

local origMessageResult

function onInit()
  HideAttack.origMessageResult = ActionsManager.messageResult
  ActionsManager.messageResult = messageResult
end
