-- dap-events.lua
--
-- File for registering functions to close dap REPL after the debug session
-- is terminated or exited.

local dap = require("dap")
local key = "repl-close"

dap.listeners.after.event_terminated[key] = function()
    dap.repl.close()
end

dap.listeners.after.event_exited[key] = function()
    dap.repl.close()
end

