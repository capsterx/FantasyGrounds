

-- Timer variables
local timerRunning = false;
local startTime = 0;
local timePassed = 0;
local timerDuration = 30;
local timerType = 0;
local timerTurnReset = true;
local reportPlayerTimes = false;

-- Protocol variables
local timerGeneration = 0;

-- Display variables
local timerDisplay = nil;
local timerStatus = nil;

----------------------------------------
--       Utility Functions
----------------------------------------

function max(a, b)
	if a > b then
		return a
	else
		return b
	end
end

-- -- Are you fucking kidding me, Lua? 
function tablesize(t)
	count = 0
	for k,v in pairs(t) do
		 count = count + 1
	end
	return count
end

function parseMessage(msg)
	i, i = string.find(msg, "|")
	if i == nil then
		return nil
	end
	
	cmd = string.sub(msg, 0, i-1)
	msg = string.sub(msg, i+1)

	i, i = string.find(msg, "|")
	if i == nil then
		return nil
	end

	gen = string.sub(msg, 0, i-1)
	param = string.sub(msg, i+1)
	
	gen = tonumber(gen)
	param = tonumber(param)
	
	return cmd, gen, param
end

----------------------------------------
--      Property Methods
----------------------------------------
function onInit()
	-- Debug.console("onInit - ct_combat_timer");
	
	-- old_onLogin = User.onLogin;
	-- User.onLogin = onLogin;
	-- activeUsers = User.getActiveUsers()
	OOBManager.registerOOBMsgHandler("ct_timer", receiveOOBMessage)
	if User.isHost() == true then
		CombatManager.setCustomTurnStart(customTurnStart);
	end
	
	-- Set default values for the timer (Doesn't start the timer if it's
	-- not running).
	resetTimer();
end

function onClose()
	if old_onLogin ~= nil then
		User.onLogin = old_onLogin;
	end
	
	--Stop message notifications
	OOBManager.registerOOBMsgHandler("ct_timer", nil)

	--Stop the timer if it's running
	-- stopTimer();
end

function onDoubleClick( x, y )
	-- Debug.console("onDoubleClick");

	resetTimer();
end

function customTurnStart(nodeCT)
	-- We'll still get turn notifications even if the window is closed.
	-- resetTimer should do the right thing.
	-- Debug.console("customTurnStart", nodeCT);

  if timerTurnReset then
    resetTimer();
  end
end

function receiveEndTurn(msg)
	-- Debug.console("endturn", msg.user);
end

----------------------------------------
--      Subwindow callbacks
----------------------------------------
function registerTimerDisplay(display)
	-- Debug.console("registerTimerDisplay", display);
	timerDisplay = display;
end

function registerTimerStatus(status)
	-- Debug.console("registerTimerStatus", status);
	timerStatus = status;
end

----------------------------------------
--      Helper functions
----------------------------------------

function updateView(param)
	--Add support for count-up timers
	-- Debug.console("updateView");
	
	if param == nil then
		return
	end
	
	if timerDisplay ~= nil then
		timerDisplay.setValue(formatTimer(param));
	end
end

function updateStatus()
	if timerStatus ~= nil then
		timerStatus.update();
	end
end

function formatTimer(seconds)
	minutes = seconds / 60;
	seconds = seconds % 60;
	return string.format("%02d:%02d", minutes, seconds);
end

----------------------------------------
--      Accessor functions
----------------------------------------

function isTimerRunning()
	return timerRunning;
end

function getTimerType()
	return timerType;
end

function setTimerType(tType)
	timerType = tType;
	resetTimer();
end

function setTurnReset(tType)
	timerTurnReset = tType;
end

function setTimerDuration(tTime)
	timerDuration = tTime;
	resetTimer();
end

function getTimerDuration()
	return timerDuration;
end

function setReportTimes(bReport)
	reportPlayerTimes = bReport;
end

function getReportTimes()
	return reportPlayerTimes;
end

function toggleTimer()
	-- Debug.console("toggleTimer - ct_combat_timer");
	
	if User.isHost() == false then
		-- Debug.console("toggleTimer - Error: Only host can toggle the timer");
		return
	end
	
	if timerRunning == false then
		startTimer();
	else
		stopTimer();
	end
end

function getTimerValue()
	if timerType == 0 then -- Count Down
		if timerRunning then
			return timerDuration - timePassed  - (os.time() - startTime);
		else
			return timerDuration - timePassed;
		end
	else -- Count Up
		if timerRunning then
			return timePassed + os.time() - startTime;
		else
			return timePassed;
		end
	end
end
----------------------------------------
--      Timer Protocol
----------------------------------------

-- Host Messages:
-- 	CT_START
-- 	CT_STOP
-- 	CT_RESET
-- 	CT_PING
-- User Messages:
-- 	CT_PONG

function startTimer()
	if User.isHost() == false or timerRunning == true then
		return;
	end
	
	if tablesize(User.getActiveUsers()) < 1 then
		warningmsg = {};
		warningmsg.text = "WARNING: Combat Timer only ticks with multiple users connected.";
		warningmsg.sender = "CombatTimer"
		Comm.addChatMessage(warningmsg)
	end

	-- Debug.console("Combat Timer started!", startTime);
	
	timerGeneration = 0;
	timerRunning = true;

	updateStatus();
	
	--Only update the startTimer
	startTime = os.time();
	
	startmsg = {};
	startmsg.type = "ct_timer"
	startmsg.text = "CT_START" .. "|" .. timerGeneration .. "|" .. getTimerValue();
	startmsg.secret = true;
	startmsg.sender = User.getUsername()
	
	-- Debug.console("Sending startmsg");

	Comm.deliverOOBMessage(startmsg);
end

function stopTimer()
	if timerRunning == false then
		return;
	end

	-- Debug.console("Combat Timer stopped!", os.time() - startTime);
	
	timerGeneration = 0;
	timerRunning = false;

	-- Reset remaining expiration from the startTime
	timePassed = timePassed + os.time() - startTime;
	
	updateStatus();
	
	-- Allow the code to get this far on if User.isHost() == true.  This
	-- function is called on de-initialization.
	if User.isHost() == false then
		return
	end
	
	stopmsg = {};
	stopmsg.type = "ct_timer"
	stopmsg.text = "CT_STOP" .. "|" .. timerGeneration .. "|" .. getTimerValue();
	stopmsg.secret = true;
	stopmsg.sender = User.getUsername()
	
	-- Debug.console("Sending stopmsg");
	
	Comm.deliverOOBMessage(stopmsg);
end

function resetTimer()
	if User.isHost() == false then
		return;
	end
	
	startTime = os.time();
	-- Debug.console("Combat Timer reset!", startTime);
	
	timerGeneration = 0;
	-- Only meaningful if resetTimer is called while timerRunning == true
	startTime = os.time(); 
	timePassed = 0;
	
	updateView(getTimerValue());
	
	--Reset the timer to the expirationTime value
	resetmsg = {};
	resetmsg.type = "ct_timer"
	resetmsg.text = "CT_RESET" .. "|" .. timerGeneration .. "|" .. getTimerValue();
	resetmsg.secret = true;
	resetmsg.sender = User.getUsername()
	
	-- Debug.console("Sending resetmsg");

	Comm.deliverOOBMessage(resetmsg);
end

function ping(param)
	if timerRunning == false then
		return;
	end
	
	timerGeneration = timerGeneration + 1;
	
	pingmsg = {};
	pingmsg.type = "ct_timer"
	pingmsg.text = "CT_PING" .. "|" .. timerGeneration .. "|" .. param;
	pingmsg.secret = true;
	pingmsg.sender = User.getUsername()
	
	Comm.deliverOOBMessage(pingmsg);
end

function pong(user)
	if timerRunning == false then
		return;
	end
	
	pongmsg = {}
	pongmsg.type = "ct_timer"
	pongmsg.text = "CT_PONG" .. "|" .. timerGeneration .. "|" .. 0;
	pongmsg.secret = true;
	pongmsg.sender = User.getUsername()
	
	Comm.deliverOOBMessage(pongmsg, user);
end

-- Also technically a callback, but used to receive OOB protocol messages
function receiveOOBMessage(msg)
	-- Debug.console(msg.type, msg.text, msg.sender);
	
	cmd, gen, param = parseMessage(msg.text);
	
	if User.isHost() then
		if cmd == "CT_PONG" and gen == timerGeneration and timerRunning then
			-- Only send a Ping to keep the timer running if the timer is going to keep counting
			timeleft = getTimerValue();
			if timeleft >= 0 then
				ping(timeleft);
				updateView(timeleft);
			end
		end
	else -- not User.isHost() 
		if cmd == "CT_PING" and timerGeneration <= gen then
			-- Send a response message to keep the timer running
			timerGeneration = gen
			pong(msg.sender);
			
			--Update the view with the latest numbers
			updateView(param);
		elseif cmd == "CT_START" or cmd == "CT_RESET" then
			timerGeneration = gen;
			
			if cmd == "CT_START" then
				timerRunning = true;
			end
			
			updateStatus();

			-- Send a Pong to keep the timer running if the timer is going to keep counting
			pong(msg.sender);
			
			--Update the view with the latest numbers from the server
			updateView(param);

		elseif cmd == "CT_STOP" then
			timerGeneration = gen;
			timerRunning = false;
	
			updateStatus();
			
			--Update the view with the latest numbers
			updateView(param);
		end
	end
end
