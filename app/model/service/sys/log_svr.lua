-- 
--[[
---> 
--------------------------------------------------------------------------
---> 参考文献如下
-----> 
--------------------------------------------------------------------------
---> Examples：
-----> 
--]]
--
-----------------------------------------------------------------------------------------------------------------
--[[
---> 统一函数指针
--]]
local require = require

local n_log = ngx.log
local n_err = ngx.ERR
local n_info = ngx.INFO
local n_debug = ngx.DEBUG
--------------------------------------------------------------------------

--[[
---> 统一引用导入APP-LIBS
--]]
--------------------------------------------------------------------------
-----> 基础库引用
local m_base = require("app.model.base_model")
local l_uuid = require("app.lib.uuid")

-----> 工具引用
--

-----> 外部引用
--

-----> 数据仓储引用
local r_log = require("app.model.repository.sys.log_repo")

-----------------------------------------------------------------------------------------------------------------

--[[
---> 当前对象
--]]
local model = m_base:extend()

--[[
---> 实例构造器
------> 子类构造器中，必须实现 model.super.new(self, conf, store, name)
--]]
function model:new(conf, store, name)
	-- 指定名称
    self._source = "svr.sys.log"
    
    -- 传导值进入父类
    model.super.new(self, conf, store, name)

	-- 位于在缓存中维护的KEY值
    self._cache_prefix = self.format("%s.app<%s> => ", conf.project_name, self._name)
    
    -- 当前临时操作数据的仓储
    self._model.current_repo = r_log(conf, store)
end

-----------------------------------------------------------------------------------------------------------------

--[[
---> 写入一条日志
--]]
function model:write_log(level, fmt, ...)
    local today = ngx.today()
    
    local id = l_uuid()
    local mdl = {
            id = id,
            uri = ngx.var.uri,
            host = ngx.var.host,
            level = level,
            content = self.read_format(fmt, ...),
            from = self._name,
            project = self._conf.project_name,
            create_date = today,
            gid = tonumber(self.sub(today, 9, 10))
        }

    local ok, res_id = self._model.current_repo:save(mdl, false)
    if not ok then
        self._log.err("%s", self.utils.json.encode({
            repo_err = ok,
            err = mdl
        }))
    end

    return ok, id
end

--[[
---> 删除一条日志
--]]
function model:remove_log(id)
    local attr = {
            id = id
        }

    return self._model.current_repo:delete(attr)
end

--[[
---> 刷新一条日志信息
--]]
function model:refresh_log(id, content)
    local mdl = {
            {"content", content, "+"}
        }

    local attr = {
            id = id
        }

    return self._model.current_repo:update(mdl, attr)
end

--[[
---> 查询单条日志
--]]
function model:get_log(id)
    -- 查询缓存或数据库中是否包含指定信息
    local cache_key = self.format("%s%s -> %s", self._cache_prefix, self._source, id)
    local timeout = 0
    
    return self._store.cache.using:get_or_load(cache_key, function() 
        return self._model.current_repo:find_one({
                id = id
            })
    end, timeout)
end

--[[
---> 查询所有的日志
--]]
function model:query_logs()
	-- 查询缓存或数据库中是否包含指定信息
    local cache_key = self.format("%s%s -> %s", self._cache_prefix, self._source, "*")
  	local timeout = 0
	
  	return self._store.cache.using:get_or_load(cache_key, function() 
        return self._model.current_repo:find_all({})
  	end, timeout)
end

-----------------------------------------------------------------------------------------------------------------

return model