---信号类
---@class Signal:ObjectEx by wx771720@outlook.com 2019-08-07 15:08:49
---@field target any|nil 关联的对象
---
---@field _callbacks Callback[] 回调列表
---@field _promises Promise[] 等待列表
local Signal = xx.Class("xx.Signal")

---@see Signal
xx.Signal = Signal

---构造方法
---@param target any|nil 关联的对象
function Signal:ctor(target)
    self.target = target
    self._callbacks = {}
    self._promises = {}
end

---添加回调
---@type fun(handler:Handler, caller:any, ...:any):Signal
---@param handler handler 回调函数
---@param caller any|nil 回调方法所属的对象，匿名函数或者静态函数可不指定
---@vararg any
---@return Signal self
function Signal:addListener(handler, caller, ...)
    local callback
    local index = xx.Callback.getIndex(self._callbacks, handler, caller)
    if index < 0 then
        callback = xx.Callback(handler, caller, ...)
    else
        callback = self._callbacks[index]
        callback.cache = xx.arrayPush({}, ...)
        xx.arrayRemoveAt(self._callbacks, index)
    end
    callback["callOnce"] = false
    xx.arrayPush(self._callbacks, callback)
    return self
end

---添加回调
---@type fun(handler:Handler, caller:any, ...:any):Signal
---@param handler Handler 回调函数
---@param caller any|nil 回调方法所属的对象，匿名函数或者静态函数可不指定
---@vararg any
---@return Signal self
function Signal:once(handler, caller, ...)
    local callback
    local index = xx.Callback.getIndex(self._callbacks, handler, caller)
    if index < 0 then
        callback = xx.Callback(handler, caller, ...)
    else
        callback = self._callbacks[index]
        callback.cache = xx.arrayPush({}, ...)
        xx.arrayRemoveAt(self._callbacks, index)
    end
    callback["callOnce"] = true
    xx.arrayPush(self._callbacks, callback)
    return self
end

---移除回调
---@type fun(handler:Handler|nil,caller:any|nil):Signal
---@param handler Handler|nil 回调函数
---@param caller any|nil 回调方法所属的对象，匿名函数或者静态函数可不指定
---@return Signal self
function Signal:removeListener(handler, caller)
    if not handler and not caller then
        xx.arrayClear(self._callbacks)
    elseif not handler then
        for i = xx.arrayCount(self._callbacks), 1, -1 do
            if self._callbacks[i].caller == caller then
                xx.arrayRemoveAt(self._callbacks, i)
            end
        end
    elseif not caller then
        for i = xx.arrayCount(self._callbacks), 1, -1 do
            if self._callbacks[i].handler == handler then
                xx.arrayRemoveAt(self._callbacks, i)
            end
        end
    else
        local index = xx.Callback.getIndex(self._callbacks, handler, caller)
        if index > 0 then
            xx.arrayRemoveAt(self._callbacks, index)
        end
    end
    return self
end

---判断是否有指定回调函数的回调
---@type fun(handler:Handler|nil,caller:any|nil):boolean
---@param handler Handler|nil 回调函数，null 表示判断是否有监听
---@param caller any|nil 回调方法所属的对象，匿名函数或者静态函数可不指定
---@return boolean 如果找到返回 true，否则返回 false
function Signal:hasListener(handler, caller)
    if not handler and not caller then
        return xx.arrayCount(self._callbacks) > 0
    elseif not handler then
        for i = xx.arrayCount(self._callbacks), 1, -1 do
            if self._callbacks[i].caller == caller then
                return true
            end
        end
    elseif not caller then
        for i = xx.arrayCount(self._callbacks), 1, -1 do
            if self._callbacks[i].handler == handler then
                return true
            end
        end
    else
        return xx.Callback.getIndex(self._callbacks, handler, caller) > 0
    end
    return false
end

---等待信号触发
---@type fun():Promise
---@return Promise 异步对象
function Signal:wait()
    local promise = xx.Promise()
    xx.arrayPush(self._promises, promise)
    return promise
end

---取消等待信号
---@type fun()
function Signal:removeWait()
    for i = xx.arrayCount(self._promises), 1, -1 do
        local promise = self._promises[i]
        self._promises[i] = nil
        promise:cancel()
    end
end

---触发信号
---@type fun(...:any):Signal
---@vararg any
---@return Signal self
function Signal:call(...)
    for i = xx.arrayCount(self._promises), 1, -1 do
        local promise = self._promises[i]
        self._promises[i] = nil
        promise:resolve(...)
    end

    local evt = xx.Event(self, nil, xx.arrayPush({}, ...))
    local copy = xx.arraySlice(self._callbacks)
    for _, callback in ipairs(copy) do
        if self:hasListener(callback.handler, callback.caller) then
            if callback["callOnce"] then
                xx.arrayRemove(self._callbacks, callback)
            end
            callback(evt)
            if evt.isStopImmediate then
                break
            end
        end
    end
    return self
end
