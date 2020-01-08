---回调类
---@class Callback:ObjectEx by wx771720@outlook.com 2019-08-07 14:43:55
---@field handler Handler 回调方法
---@field caller any|nil 回调方法所属的对象，匿名函数或者静态函数可不指定
---@field cache any[]
local Callback = xx.Class("xx.Callback")

---@see Callback
xx.Callback = Callback

---构造函数
---@param handler Handler 回调方法
---@param caller any|nil 回调方法所属的对象，匿名函数或者静态函数可不指定
---@vararg any
function Callback:ctor(handler, caller, ...)
    self.handler = handler
    self.caller = caller
    self.cache = xx.arrayPush({}, ...)
end

---比较函数
---@param target Callback 需要比较的回调对象
---@return boolean 如果相同返回 true，否则返回 false
function Callback:equalTo(target)
    return self.handler == target.handler and self.caller == target.caller
end

---比较函数
---@param handler Handler 回调方法
---@param caller any|nil 回调方法所属的对象，匿名函数或者静态函数可不指定
---@return boolean 如果相同返回 true，否则返回 false
function Callback:equalBy(handler, caller)
    return self.handler == handler and self.caller == caller
end

---触发回调
---@type fun(...:any):any
---@vararg any
---@return any 透传回调方法的返回
function Callback:call(...)
    local args = {...}
    if xx.arrayCount(self.cache) > 0 or xx.arrayCount(args) > 0 then
        if self.caller then
            return self.handler(self.caller, unpack(xx.arrayPush(xx.arraySlice(self.cache), ...)))
        else
            return self.handler(unpack(xx.arrayPush(xx.arraySlice(self.cache), ...)))
        end
    else
        if self.caller then
            return self.handler(self.caller)
        else
            return self.handler()
        end
    end
end

---在指定回调对象列表中查找指定的回调方法及所属对象的索引
---@type fun(list:Callback[], handler:Handler, caller:any|nil):number
---@param list Callback[] 回调对象列表
---@param handler Handler 回调方法
---@param caller any|nil 回调方法所属的对象
---@return number 如果找到返回对应索引（从 1 开始），否则返回 -1
function Callback.getIndex(list, handler, caller)
    for index = 1, xx.arrayCount(list) do
        if list[index] and list[index]:equalBy(handler, caller) then
            return index
        end
    end
    return -1
end
