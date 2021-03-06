--
--[[
---> 主服务文件
--]]
--
-----------------------------------------------------------------------------------------------------------------
--[[
---> 统一函数指针
--]]
local s_find = string.find
local s_format = string.format

local n_log = ngx.log
local n_err = ngx.ERR
local n_info = ngx.INFO
local n_debug = ngx.DEBUG

--[[
---> 统一引用导入APP-LIBS
--]]
-----> 基础库引用
local lor = require("lor.index")
local router = require("app.router")
local u_string = require("app.utils.string")

-----> 插件库引用
local middleware_er4xx = require("app.middleware.Er4xx")
local middleware_er5xx = require("app.middleware.Er5xx")

-----------------------------------------------------------------------------------------------------------------

--[[
---> 当前对象
--]]
local _M = {}

--[[
---> 实例构造器
--]]
function _M:new(conf, store, views_path)
	local instance = {}
	instance.views_path = u_string.rtrim(views_path or conf.view_conf.views, "/")
    instance.conf = conf
    instance.store = store

    instance.app = lor()

    setmetatable(instance, { __index = self })
    instance:build_app()
    return instance
end

--[[
---> 生产APP
--]]
function _M:build_app()
    local conf = self.conf
    local store = self.store
    local app = self.app

	---> 配置文件
	local view_conf = conf.view_conf

	-------------------------------------------------------------------------------------------------------------
	--[[
	---> 基本的APP配置
	--]]
	---> 配置：模板内容项
	app:conf("view enable", true)  -- 开启模板
	app:conf("view engine", view_conf.engine)  -- 模板引擎，当前lor只支持lua-resty-template，所以这个值暂时固定为"tmpl"
	app:conf("view ext", view_conf.ext)  -- 模板文件后缀，可自定义
	app:conf("views", self.views_path)

	---> 插件引用：
	app:use(function(req, res, next)
	    -- 插件，在处理业务route之前的插件，可作编码解析、过滤等操作
	    next()
	end)

	---> 业务路由处理：
	local crumbs = u_string.split(self.views_path, "/")
	conf.view_conf.mode = crumbs[#crumbs]
    app:use(router(app, conf, store)())

	--[[
	---> 公共部分的插件引用
	--]]
	---> 404 error
	-- app:erroruse(middleware_er4xx())

	---> 错误处理插件，可根据需要定义多个
	app:erroruse(middleware_er5xx())
end

--[[
---> 获取APP
--]]
function _M:get_app()
    return self.app
end

-----------------------------------------------------------------------------------------------------------------

return _M