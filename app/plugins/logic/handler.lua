local base_handler = require("app.plugins.base_handler")
local buffer = require("app.plugins.logic.buffer")

local handler = base_handler:extend()

handler.PRIORITY = 2000

function handler:new(store, config)
    handler.super.new(self, "logic-buffer-plugin")
    self.store = store
    self.config = config
end

return handler