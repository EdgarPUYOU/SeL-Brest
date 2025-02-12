local fader_table = {201,202,203,204,205,206,207,208,216,217,218,219,220,221,222,223,224}
local encoder_table = {401, 402, 403, 404, 405, 406, 407 ,408}
local osc_config = 2
local history_fader, history_status, history_enc, history_time, osc_send_status = {}, {}, {}, {}, {}
local history_gm = 0
local history_gm_time, gm_osc_send_status = 0, 0
local osc_template = 'SendOSC %i "/%s%i,f,%f"'
local enabled = false
local Printf, Echo, GetExecutor, Cmd, ipairs, mfloor = Printf, Echo, GetExecutor, Cmd, ipairs, math.floor
local refresh_period, timeout_seconds = 0.05, 0.3
local timeout = timeout_seconds / refresh_period

local function send_osc(etype, exec_no, value)
  -- Printf(osc_template:format(osc_config, etype, exec_no, value))
  Cmd(osc_template:format(osc_config, etype, exec_no, value))
end

local function poll_fdr(exec_no)
  local exec = GetExecutor(exec_no)
  -- local value = exec and mfloor(exec:GetFader{}) or 0
  local value = exec and exec:GetFader{} or 0
  local last_value = history_fader[exec_no]
  local status = exec and exec.Object and exec.Object:HasActivePlayback() and 1 or 0
  local last_status = history_status[exec_no] 
  if value ~= last_value then
    history_fader[exec_no] = value
    history_time[exec_no] = 0
    osc_send_status[exec_no] = 0
  else
    if history_time[exec_no] >= timeout and osc_send_status[exec_no] == 0 then
      send_osc('Fader', exec_no, value)
      osc_send_status[exec_no] = 1
    end
    history_time[exec_no] = history_time[exec_no] + 1
  end
  if status ~= last_status then
    send_osc('Key', exec_no, status)
    history_status[exec_no] = status
  end
end

local function poll_enc(exec_no)
  local exec = GetExecutor(exec_no)
  -- local value = exec and mfloor(exec:GetFader{}) or 0
  local value = exec and exec:GetFader{} or 0
  local last_value = history_enc[exec_no]
  if value ~= last_value then
    history_enc[exec_no] = value
    send_osc('Encoder', exec_no, value)
  end
end

local function poll_gm()
	-- Update the Grand Master
	local value = ShowData().Masters.Grand.Master.NORMEDVALUE
	if value ~= history_gm then
		history_gm = value
		history_gm_time = 0
		gm_osc_send_status = 0
	else
		if history_gm_time >= timeout and gm_osc_send_status == 0 then
			send_osc('GrandMaster', 0, value)
			gm_osc_send_status = 1
		end
		history_gm_time = history_gm_time + 1
	end
end
	

local function mainloop()
  while enabled do
    poll_gm()
    for _, exec_no in ipairs(fader_table) do poll_fdr(exec_no) end
    for _, exec_no in ipairs(encoder_table) do poll_enc(exec_no) end
    coroutine.yield(refresh_period)
  end
end

local function maintoggle()
  if enabled then
    enabled = false
  else
    enabled = true
    history_fader, history_status = {}, {}
    mainloop()
  end
end

return maintoggle