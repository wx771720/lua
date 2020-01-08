---事件派发类
---@class EventDispatcher:ObjectEx by wx771720@outlook.com 2019-08-07 15:17:02
---@field _typeCallbacksMap table<string, Callback[]> 事件类型 - 回调列表
---@field _typePromisesMap table<string, Promise[]> 事件类型 - 等待列表
local EventDispatcher = xx.Class("EventDispatcher")

---@see EventDispatcher
xx.EventDispatcher = EventDispatcher

function EventDispatcher:onDynamicChanged(key, newValue, oldValue)
    self(GIdentifiers.e_changed, key, newValue, oldValue)
end

---构造函数
function EventDispatcher:ctor()
    self._typeCallbacksMap = {}
    self._typePromisesMap = {}
end

---添加事件回调
---@type fun(type:string, handler:Handler, caller:any, ...:any[]):EventDispatcher
---@param type string 事件类型
---@param handler Handler 回调函数，return: boolean（是否立即停止执行后续回调）, boolean（是否停止冒泡）
---@param caller any|nil 回调方法所属的对象，匿名函数或者静态函数可不传入
---@return EventDispatcher self
function EventDispatcher:addEventListener(type, handler, caller, ...)
    local callback
    local callbacks
    if self._typeCallbacksMap[type] then
        callbacks = self._typeCallbacksMap[type]
        local index = xx.Callback.getIndex(callbacks, handler, caller)
        if index < 0 then
            callback = xx.Callback(handler, caller, ...)
        else
            callback = callbacks[index]
            callback.cache = xx.arrayPush({}, ...)
            xx.arrayRemoveAt(callbacks, index)
        end
    else
        callbacks = {}
        self._typeCallbacksMap[type] = callbacks
        callback = xx.Callback(handler, caller, ...)
    end
    callback["callOnce"] = false
    xx.arrayPush(callbacks, callback)
    return self
end
---添加事件回调
---@type fun(type:string, handler:Handler, caller:any, ...:any[]):EventDispatcher
---@param type string 事件类型
---@param handler Handler 回调函数，return: boolean（是否立即停止执行后续回调）, boolean（是否停止冒泡）
---@param caller any|nil 回调方法所属的对象，匿名函数或者静态函数可不传入
---@return EventDispatcher self
function EventDispatcher:once(type, handler, caller, ...)
    local callback
    local callbacks
    if self._typeCallbacksMap[type] then
        callbacks = self._typeCallbacksMap[type]
        local index = xx.Callback.getIndex(callbacks, handler, caller)
        if index < 0 then
            callback = xx.Callback(handler, caller, ...)
        else
            callback = callbacks[index]
            callback.cache = xx.arrayPush({}, ...)
            xx.arrayRemoveAt(callbacks, index)
        end
    else
        callbacks = {}
        self._typeCallbacksMap[type] = callbacks
        callback = xx.Callback(handler, caller, ...)
    end
    callback["callOnce"] = true
    xx.arrayPush(callbacks, callback)
    return self
end
---删除事件回调
---@type fun(type:string, handler:Handler, caller:any):EventDispatcher
---@param type string|nil 事件类型，默认 nil 表示移除所有 handler 和 caller 回调
---@param handler Handler|nil 回调函数，默认 nil 表示移除所有包含 handler 回调
---@param caller any|nil 回调方法所属的对象，匿名函数或者静态函数可不传入，默认 nil 表示移除所有包含 caller 的回调
---@return EventDispatcher self
function EventDispatcher:removeEventListener(type, handler, caller)
    if not type and not handler and not caller then
        xx.tableClear(self._typeCallbacksMap)
    elseif not type then
        if not handler then
            for loopType, callbacks in pairs(self._typeCallbacksMap) do
                for i = xx.arrayCount(callbacks), 1, -1 do
                    if callbacks[i].caller == caller then
                        xx.arrayRemoveAt(callbacks, i)
                    end
                end
                if 0 == xx.arrayCount(callbacks) then
                    self._typeCallbacksMap[loopType] = nil
                end
            end
        elseif not caller then
            for loopType, callbacks in pairs(self._typeCallbacksMap) do
                for i = xx.arrayCount(callbacks), 1, -1 do
                    if callbacks[i].handler == handler then
                        xx.arrayRemoveAt(callbacks, i)
                    end
                end
                if 0 == xx.arrayCount(callbacks) then
                    self._typeCallbacksMap[loopType] = nil
                end
            end
        else
            for loopType, callbacks in pairs(self._typeCallbacksMap) do
                local index = xx.Callback.getIndex(callbacks, handler, caller)
                if index > 0 then
                    if 1 == xx.arrayCount(callbacks) then
                        self._typeCallbacksMap[loopType] = nil
                    else
                        xx.arrayRemoveAt(callbacks, index)
                    end
                end
            end
        end
    elseif self._typeCallbacksMap[type] then
        if not handler and not caller then
            self._typeCallbacksMap[type] = nil
        else
            local callbacks = self._typeCallbacksMap[type]
            if not handler then
                for i = xx.arrayCount(callbacks), 1, -1 do
                    if callbacks[i].caller == caller then
                        xx.arrayRemoveAt(callbacks, i)
                    end
                end
                if 0 == xx.arrayCount(callbacks) then
                    self._typeCallbacksMap[type] = nil
                end
            elseif not caller then
                for i = xx.arrayCount(callbacks), 1, -1 do
                    if callbacks[i].handler == handler then
                        xx.arrayRemoveAt(callbacks, i)
                    end
                end
                if 0 == xx.arrayCount(callbacks) then
                    self._typeCallbacksMap[type] = nil
                end
            else
                local index = xx.Callback.getIndex(callbacks, handler, caller)
                if index > 0 then
                    if 1 == xx.arrayCount(callbacks) then
                        self._typeCallbacksMap[type] = nil
                    else
                        xx.arrayRemoveAt(callbacks, index)
                    end
                end
            end
        end
    end
    return self
end
---是否有事件回调
---@type fun(type:string|nil,handler:Handler|nil,caller:any|nil):boolean
---@param type string|nil 事件类型，默认 nil 表示移除所有 handler 和 caller 回调
---@param handler Handler|nil 回调函数，默认 nil 表示移除所有包含 handler 回调
---@param caller any|nil 回调方法所属的对象，匿名函数或者静态函数可不传入，默认 nil 表示移除所有包含 caller 的回调
---@return boolean 如果找到事件回调返回 true，否则返回 false
function EventDispatcher:hasEventListener(type, handler, caller)
    if not type and not handler and not caller then
        return xx.tableCount(self._typeCallbacksMap) > 0
    end
    if not type then
        if not handler then
            for _, callbacks in pairs(self._typeCallbacksMap) do
                for i = xx.arrayCount(callbacks), 1, -1 do
                    if callbacks[i].caller == caller then
                        return true
                    end
                end
            end
        elseif not caller then
            for _, callbacks in pairs(self._typeCallbacksMap) do
                for i = xx.arrayCount(callbacks), 1, -1 do
                    if callbacks[i].handler == handler then
                        return true
                    end
                end
            end
        else
            for _, callbacks in pairs(self._typeCallbacksMap) do
                local index = xx.Callback.getIndex(callbacks, handler, caller)
                if index > 0 then
                    return true
                end
            end
        end
    elseif self._typeCallbacksMap[type] then
        if not handler and not caller then
            return true
        else
            local callbacks = self._typeCallbacksMap[type]
            if not handler then
                for i = xx.arrayCount(callbacks), 1, -1 do
                    if callbacks[i].caller == caller then
                        return true
                    end
                end
            elseif not caller then
                for i = xx.arrayCount(callbacks), 1, -1 do
                    if callbacks[i].handler == handler then
                        return true
                    end
                end
            else
                return xx.Callback.getIndex(callbacks, handler, caller) > 0
            end
        end
    end
    return false
end

---等待事件触发
---@type fun(type:string):Promise
---@param type string 事件类型
---@return Promise 异步对象
function EventDispatcher:wait(type)
    local promise = xx.Promise()
    if self._typePromisesMap[type] then
        xx.arrayPush(self._typePromisesMap[type], promise)
    else
        self._typePromisesMap[type] = {promise}
    end
    return promise
end
---取消等待事件
---@type fun(type:string|nil):EventDispatcher
---@param type string|nil 事件类型，null 表示取消所有等待事件
---@return EventDispatcher self
function EventDispatcher:removeWait(type)
    if not type then
        for type, promises in pairs(self._typePromisesMap) do
            self._typePromisesMap[type] = nil
            for _, promise in ipairs(promises) do
                promise:cancel()
            end
        end
    elseif self._typePromisesMap[type] then
        local promises = self._typePromisesMap[type]
        self._typePromisesMap[type] = nil
        for _, promise in ipairs(promises) do
            promise:cancel()
        end
    end
    return self
end
---判断是否有等待指定事件
---@type fun(type:string|nil):boolean
---@param type string|nil 等待事件，nil 表示是否有等待任意事件
---@return boolean 如果有等待指定事件返回 true，否则返回 false
function EventDispatcher:hasWait(type)
    if not type then
        return xx.tableCount(self._typePromisesMap) > 0
    end
    return self._typePromisesMap[type] and true or false
end

---派发事件
---@type fun(type:string, ...:any)
---@param type string 事件类型
---@vararg any
function EventDispatcher:call(type, ...)
    self:callEvent(xx.Event(self, type, xx.arrayPush({}, ...)))
end
---派发事件（需要支持冒泡）
---@param evt Event 事件对象
function EventDispatcher:callEvent(evt)
    if self._typePromisesMap[evt.type] then
        local promises = self._typePromisesMap[evt.type]
        self._typePromisesMap[evt.type] = nil
        for i = xx.arrayCount(promises), 1, -1 do
            promises[i]:resolve(unpack(evt.args))
        end
    end
    if self._typeCallbacksMap[evt.type] then
        evt.currentTarget = self

        local callbacks = xx.arraySlice(self._typeCallbacksMap[evt.type])
        for _, callback in ipairs(callbacks) do
            if self:hasEventListener(evt.type, callback.handler, callback.caller) then
                if callback["callOnce"] then
                    self:removeEventListener(evt.type, callback.handler, callback.caller)
                end
                callback(evt)
                if evt.isStopImmediate then
                    break
                end
            end
        end
    end
end
