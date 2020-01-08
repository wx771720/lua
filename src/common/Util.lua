-- -----------------------------------------------------------------------------
-- 常用全局工具
-- 全局工具
-- by wx771720@outlook.com 2019-08-07 15:38:28
-- -----------------------------------------------------------------------------
---计算指定的贝塞尔值
---@type fun(percent:number,...:number):number
---@param percent number 百分比
---@vararg number
---@return number 返回贝塞尔对应值
function xx.bezier(percent, ...)
    local values = {...}
    local count = xx.arrayCount(values) - 1
    while count > 0 do
        for i = 1, count do
            values[i] = values[i] + (values[i + 1] - values[i]) * percent
        end
        count = count - 1
    end
    return 0 == count and values[1] or 0
end
-- -----------------------------------------------------------------------------
-- 参数
-- -----------------------------------------------------------------------------
---从参数列表中获取回调参数
---@type fun(...:any):Callback
---@vararg any
---@return Callback|nil 如果找到则返回 Callback 对象，否则返回 nil
function xx.getCallback(...)
    local args = {...}
    local count = xx.arrayCount(args)
    if count > 0 then
        if xx.instanceOf(args[count], xx.Callback) then
            return args[count]
        end
    end
end

----从参数列表中获取异步对象参数
---@type fun(...:any):Promise
---@vararg any
---@return Promise 如果找到则返回 Promise 对象，否则返回 nil
function xx.getPromise(...)
    local args = {...}
    local count = xx.arrayCount(args)
    if count > 0 then
        if xx.instanceOf(args[count], xx.Promise) then
            return args[count]
        end
    end
end

---从参数列表中获取信号参数
---@type fun(...:any):Signal
---@vararg any
---@return Signal|nil 如果找到则返回 Signal 对象，否则返回 nil
function xx.getSignal(...)
    local args = {...}
    local count = xx.arrayCount(args)
    if count > 0 then
        if xx.instanceOf(args[count], xx.Signal) then
            return args[count]
        end
    end
end

-- ---判断指定对象是否可执行（Callback, Signal, Promise）
-- ---@type fun(csp:Callback|Signal|Promise):boolean
-- ---@param csp Callback|Signal|Promise 回调或者信号或者异步对象
-- function xx.canExecute(csp)
--     return xx.instanceOf(csp, xx.Callback) or xx.instanceOf(csp, xx.Signal) or xx.instanceOf(csp, xx.Promise)
-- end

-- ---执行回调或者信号、异步
-- ---@type fun(csp:Callback|Signal|Promise,...:any):any
-- ---@param csp Callback|Signal|Promise 回调或者信号或者异步对象
-- ---@vararg any
-- ---@return any 返回的数据
-- function xx.execute(csp, ...)
--     if not csp then
--         return
--     elseif xx.instanceOf(csp, xx.Callback) then
--         return csp(...)
--     elseif xx.instanceOf(csp, xx.Signal) then
--         csp(...)
--     elseif xx.instanceOf(csp, xx.Promise) then
--         csp:resolve(...)
--     end
-- end
-- -----------------------------------------------------------------------------
-- 单例
-- -----------------------------------------------------------------------------
---@type table<string, any> 类名 - 实例
local __singleton = {}

---添加一个类的实例作为其单例使用
---@type fun(instance:any):any
---@param instance any 对象
---@return any instance
function xx.addInstance(instance)
    if instance and instance.__class and instance.__class.__className then
        __singleton[instance.__class.__className] = instance
    end
    return instance
end

---移除一个类的单例实例
---@type fun(name:string):any
---@param name string 类名
---@return any 如果存在指定实例则返回，否则返回 nil
function xx.delInstance(name)
    local instance = __singleton[name]
    __singleton[name] = nil
    return instance
end

---获取一个类的单例实例
---@type fun(name:string):any
---@param name string 类名
---@return any 如果存在指定类名则返回对应单例对象，否则返回 nil
function xx.getInstance(name)
    if name then
        if __singleton[name] then
            return __singleton[name]
        end

        local class = xx.Class.getClass(name)
        if class then
            local instance = class()
            __singleton[name] = instance
            return instance
        end
    end
end
