-- 
--[[
---> 用于落地操作来自于（）的数据
--------------------------------------------------------------------------
---> 参考文献如下
-----> /
-----------------------------------------------------------------------------------------------------------------
--[[
---> 统一函数指针
--]]
local require = require
--------------------------------------------------------------------------

--[[
---> 统一引用导入APP-LIBS
--]]
--------------------------------------------------------------------------
-----> 基础库引用
local o_repo = require("app.store.orm.base_repo")

-----> 工具引用
--

-----> 外部引用
--
--------------------------------------------------------------------------


--[[
---> 当前对象
--]]
local model = o_repo:extend()

-----------------------------------------------------------------------------------------------------------------

--[[
---> 实例构造器
------> 子类构造器中，必须实现 model.super.new(self, conf, store, self._source, self._conf_db_node)
--]]
function model:new(conf, store)
	-- 指定名称
	self._source = "[sys_users]"
	self._conf_db_node = "user"

	-- 传导至父类填充基类操作对象
	model.super.new(self, conf, store, self._source, self._conf_db_node)
end

-----------------------------------------------------------------------------------------------------------------

--[[
---> 特殊自定义需求ok，records
--]]
-- function model:find_(attr)
-- 	local cond, params = self:resolve_attr(attr)
-- 	return self._adapter.current_model.find_all(cond, table.unpack(params))
-- end

-----------------------------------------------------------------------------------------------------------------

return model