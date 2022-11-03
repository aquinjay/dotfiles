local sm_status_ok, sm = pcall(require, "session_manager")
if not sm_status_ok then
  return
end

sm.setup()
