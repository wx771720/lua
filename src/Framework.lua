---模块与状态机类
---@class Framework:EventDispatcher by wx771720@outlook.com 2019-08-09 10:08:44
---@field public isRegistered boolean 模块是否已注册
---@field public priority number 模块优先级，数值越大的优先执行
---@field private _context table<string, any> 上下文
---@field public isConstructed boolean 状态机是否已构造
---@field public isFocused boolean 状态机是否已进入
---@field public isActivated boolean 状态机是否已激活
---@field public parent Framework 父级状态机
---@field public curState Framework 当前子状态机
---@field public numStates number 子状态机数量
---@field private _stateUIDs string[] 子状态机 uid 列表
---@field private _uidStateMap table<string, Framework> uid - 子状态机
---@field private _uidAliasMap table<string, string> uid - 别名
---@field private _aliasUIDMap table<string, string> 别名 - uid
local Framework = xx.Class("xx.Framework", xx.EventDispatcher)

---@see Framework
xx.Framework = Framework

---构造函数
function Framework:ctor()
    self.isRegistered = false
    self.priority = 0

    self._context = {}
    self.isConstructed = false
    self.isFocused = false
    self.isActivated = false
    self.parent = nil
    self.curState = nil
    self.numStates = 0
    self._stateUIDs = {}
    self._uidStateMap = {}
    self._uidAliasMap = {}
    self._aliasUIDMap = {}
end

function Framework:ctored()
    self:addEventListener(GIdentifiers.e_changed, self.onPriorityChanged, self)
end
-- -----------------------------------------------------------------------------
-- 模块
-- -----------------------------------------------------------------------------
---uid - module
---@type table<string, Framework>
Framework.uidModuleMap = {}

---notice  - uid list（按 priority 降序）
---@type table<string, string[]>
Framework.noticeUIDsMap = {}

---uid - notice list
---@type table<string, string[]>
Framework.uidNoticesMap = {}

---priority 改变监听
---@type fun(name:string)
function Framework:onPriorityChanged(name)
    if self.isRegistered and "priority" == name then
        Framework.sort(self)
    end
end

---注册模块
---@type fun(module:Framework, ...:string)
---@param module Framework 模块
---@vararg string
function Framework.register(module, ...)
    if module.isRegistered then
        Framework.addNotices(module, ...)
    else
        Framework.uidModuleMap[module.uid] = module
        module.isRegistered = true
        Framework.addNotices(module, ...)
        if xx.isFunction(module.onRegister) then
            module:onRegister()
        end
    end
end

---注销模块
---@type fun(module:Framework)
---@param module Framework 模块
function Framework.unregister(module)
    if module.isRegistered then
        Framework.removeNotices(module)
        Framework.uidModuleMap[module.uid] = nil
        module.isRegistered = false
        if xx.isFunction(module.onUnregister) then
            module:onUnregister()
        end
    end
end

---添加监听
---@type fun(...:string)
---@param module Framework 模块
---@vararg string
function Framework.addNotices(module, ...)
    local args = {...}
    local argCount = xx.arrayCount(args)
    if module.isRegistered and argCount > 0 then
        if not Framework.uidNoticesMap[module.uid] then
            Framework.uidNoticesMap[module.uid] = {}
        end

        for i = 1, argCount do
            local notice = args[i]
            if xx.isString(notice) then
                if not module:hasNotice(notice) then
                    xx.arrayPush(Framework.uidNoticesMap[module.uid], notice)

                    if Framework.noticeUIDsMap[notice] then
                        xx.arrayPush(Framework.noticeUIDsMap[notice], module.uid)
                    else
                        Framework.noticeUIDsMap[notice] = {module.uid}
                    end
                end
            end
        end

        Framework.sort(module)
    end
end

---移除监听
---@type fun(...:string)
---@param module Framework 模块
---@vararg string
function Framework.removeNotices(module, ...)
    if module.isRegistered and Framework.uidNoticesMap[module.uid] then
        local args = {...}
        local count = xx.arrayCount(args)
        local notices = Framework.uidNoticesMap[module.uid]
        if 0 == count then
            for _, notice in ipairs(notices) do
                local uids = Framework.noticeUIDsMap[notice]
                if 1 == xx.arrayCount(uids) then
                    Framework.noticeUIDsMap[notice] = nil
                else
                    xx.arrayRemove(uids, module.uid)
                end
            end
            Framework.uidNoticesMap[module.uid] = nil
        else
            for i = 1, count do
                local notice = args[i]
                if xx.isString(notice) then
                    if module:hasNotice(notice) then
                        local uids = Framework.noticeUIDsMap[notice]
                        if 1 == xx.arrayCount(uids) then
                            Framework.noticeUIDsMap[notice] = nil
                        else
                            xx.arrayRemove(uids, module.uid)
                        end

                        xx.arrayRemove(notices, notice)
                    end
                end
            end
            if 0 == xx.arrayCount(notices) then
                Framework.uidNoticesMap[module.uid] = nil
            end
        end
    end
end

---派发通知
---@type fun(notice:string, ...:any):any
---@param notice strig 通知
---@vararg any
---@return any 直接返回的数据
function Framework.notify(notice, ...)
    local result = xx.NoticeResult()
    if Framework.noticeUIDsMap[notice] then
        local uids = xx.arraySlice(Framework.noticeUIDsMap[notice])
        for _, uid in ipairs(uids) do
            if Framework.uidModuleMap[uid] then
                local module = Framework.uidModuleMap[uid]
                if module:hasNotice(notice) and xx.isFunction(module.onNotice) then
                    module:onNotice(notice, result, ...)
                    if result.stop then
                        break
                    end
                end
            end
        end
    end
    return result.data
end
---@see Framework#notify
xx.notify = Framework.notify

---派发异步通知
---@type fun(notice:string,...:any):Promise,any
---@param notice string 通知
---@vararg any
---@return Promise,any 异步对象，返回数据
function Framework.notifyAsync(notice, ...)
    local promise = xx.Promise()
    if Framework.noticeUIDsMap[notice] then
        local index = 1
        local result = xx.NoticeResult()
        local uids = xx.arraySlice(Framework.noticeUIDsMap[notice])
        local executor
        executor = function(...)
            -- 已结束
            if index > xx.arrayCount(uids) or result.stop then
                promise:resolve(...)
                return
            end
            -- 执行
            local module = Framework.uidModuleMap[uids]
            if module and module:hasNotice(notice) and xx.isFunction(module.onNotice) then
                local callback =
                    xx.Callback(
                    function(...)
                        index = index + 1
                        executor(...)
                    end
                )
                module:onNotice(notice, result, unpack(xx.arrayPush({...}, callback)))
                return
            end
            index = index + 1
            executor(...)
        end
        executor(...)
    else
        promise:resolve()
    end
    return promise
end
---@see Framework#notify
xx.notifyAsync = Framework.notifyAsync

---排序模块
function Framework.sort(module)
    local notices = Framework.uidNoticesMap[module.uid]
    for _, notice in ipairs(notices) do
        local uids = Framework.noticeUIDsMap[notice]
        table.sort(
            uids,
            function(uid1, uid2)
                return Framework.uidModuleMap[uid2].priority < Framework.uidModuleMap[uid1].priority
            end
        )
    end
end

---判断是否监听了指定通知
---@type fun(notice:string|nil):boolean
---@param notice string|nil 通知，null 表示判断模块是否监听了任意通知
---@return boolean 如果有监听指定通知则返回 true，否则返回 false
function Framework:hasNotice(notice)
    if not notice then
        return nil ~= Framework.uidNoticesMap[self.uid]
    end
    return Framework.uidNoticesMap[self.uid] and xx.arrayContains(Framework.uidNoticesMap[self.uid], notice)
end

---结束模块当前任务
---@type fun(args:any[],...:any)
---@param args any[] 启动当前任务时传入的参数列表（需要封装成表）
---@vararg any
function Framework:finishModule(args, ...)
    ---@type Callback
    local callback = xx.getCallback(unpack(args))
    if callback then
        callback(...)
    end
    ---@type Signal
    local signal = xx.getSignal(unpack(args))
    if signal then
        signal(...)
    end
    ---@type Promise
    local promise = xx.getPromise(unpack(args))
    if promise then
        promise:resolve(...)
    end
end
-- -----------------------------------------------------------------------------
-- 状态机
-- -----------------------------------------------------------------------------
---派发事件（需要支持冒泡）
---@param evt Event 事件对象
function Framework:callEvent(evt)
    xx.EventDispatcher.callEvent(self, evt)
    if not evt.isStopBubble and self.parent then
        self.parent:callEvent(evt)
    end
end

---获取上下文中的数据
---@type fun(key:string):any
---@param key string 数据键
---@return any 返回缓存的数据
function Framework:getContext(key)
    if self.parent then
        return self.parent:getContext(key)
    end

    if not self._context then
        return
    end
    return self._context[key]
end

---缓存数据到上下文中
---@type fun(key:string, value:any)
---@param key string 数据键
---@param value any 需要缓存的数据
function Framework:setContext(key, value)
    if self.parent then
        self.parent:setContext(key, value)
    else
        if not self._context then
            self._context = {}
        end

        self._context[key] = value
    end
end

---清除上下文中指定数据键的数据
---@type fun(key:string)
---@param key string 数据键
function Framework:clearContext(key)
    if self.parent then
        self.parent:clearContext(key)
    elseif self._context then
        if key then
            self._context[key] = nil
        else
            xx.tableClear(self._context)
        end
    end
end

---添加子状态机
---@type fun(state:Framework, alias:string|nil, to:boolean|nil)
---@param state Framework 子状态机
---@param alias string|nil 别名
---@param to boolean|nil 是否跳转到该子状态机
function Framework:addState(state, alias, to)
    --判断是否添加的自身或者父级状态机
    local parent = self
    repeat
        if parent == state then
            return
        end
        parent = parent.parent
    until not parent
    --已是子状态机
    if self == state.parent then
        --更新别名
        if self._uidAliasMap[state.uid] and self._uidAliasMap[state.uid] ~= alias then
            self._aliasUIDMap[self._uidAliasMap[state.uid]] = nil
            self._uidAliasMap[state.uid] = nil
        end
        if alias then
            self._uidAliasMap[state.uid] = alias
            self._aliasUIDMap[alias] = state.uid
        end
        --更新顺序
        if self._stateUIDs[xx.arrayCount(self._stateUIDs)] ~= state.uid then
            xx.arrayRemove(self._stateUIDs, state.uid)
            xx.arrayPush(self._stateUIDs, state.uid)
        end
    else
        --从旧的父状态机中移除
        state:removeFromParent()
        --添加子状态机
        xx.arrayPush(self._stateUIDs, state.uid)
        self._uidStateMap[state.uid] = state
        if alias then
            self._uidAliasMap[state.uid] = alias
            self._aliasUIDMap[alias] = state.uid
        end
        state.parent = self
        state:addEventListener(GIdentifiers.e_complete, self._onChildCompleteHandler, self)

        self.numStates = self.numStates + 1
    end
    --跳转状态机
    if to then
        self:toState(state.uid)
    end
end

---移除子状态机
---@type fun(uidOrAlias:string|Framework)
---@param uidOrAlias string|Framework 子状态机对象，或者 uid、别名
function Framework:removeState(uidOrAlias)
    local state = nil
    if xx.isString(uidOrAlias) then
        if self._uidStateMap[uidOrAlias] then
            state = self._uidStateMap[uidOrAlias]
        elseif self._aliasUIDMap[uidOrAlias] then
            state = self._uidStateMap[self._aliasUIDMap[uidOrAlias]]
        end
    elseif xx.instanceOf(uidOrAlias, Framework) and self == uidOrAlias.parent then
        state = uidOrAlias
    end

    if state then
        state:removeEventListener(GIdentifiers.e_complete, self._onChildCompleteHandler, self)
        state.parent = nil
        xx.arrayRemove(self._stateUIDs, state.uid)
        self._uidStateMap[state.uid] = nil
        if self._uidAliasMap[state.uid] then
            self._aliasUIDMap[self._uidAliasMap[state.uid]] = nil
            self._uidAliasMap[state.uid] = nil
        end
        if self.curState == state then
            self.curState = nil
            state:defocus()
        end

        self.numStates = self.numStates - 1
    end
end

---从父状态机中移除
---@type fun()
function Framework:removeFromParent()
    if self.parent then
        self.parent:removeState(self)
    end
end

---跳转子状态
---@type fun(uidOrAlias:string|Framework)
---@param uidOrAlias string|Framework 子状态机对象，或者 uid、别名
function Framework:toState(uidOrAlias)
    local state = nil
    if xx.isString(uidOrAlias) then
        if self._uidStateMap[uidOrAlias] then
            state = self._uidStateMap[uidOrAlias]
        elseif self._aliasUIDMap[uidOrAlias] then
            state = self._uidStateMap[self._aliasUIDMap[uidOrAlias]]
        end
    elseif xx.instanceOf(uidOrAlias, Framework) and self == uidOrAlias.parent then
        state = uidOrAlias
    end

    local oldState = self.curState
    if oldState == state then
        return
    end
    self.curState = state

    if oldState then
        oldState:defocus()
    end
    if self.curState then
        if self.isActivated then
            self.curState:activate()
        elseif self.isFocused then
            self.curState:focus()
        elseif self.isConstructed then
            self.curState:construct()
        end
    end
end

---获取子状态机对应的别名
---@type fun(uid:string|Framework):string
---@param uid string|Framework 子状态机对象或者 uid
---@return string|nil 如果找到则返回别名，否则返回 nil
function Framework:getAlias(uid)
    if xx.isString(uid) then
        return self._uidAliasMap[uid]
    end
    if xx.instanceOf(uid, Framework) then
        return self._uidAliasMap[uid.uid]
    end
end

---获取子状态机对象
---@type fun(uidOrAlias:string):Framework
---@param uidOrAlias string uid 或者别名
---@return Framework|nil 如果找到则返回子状态机对象，否则返回 nil
function Framework:getState(uidOrAlias)
    if self._uidStateMap[uidOrAlias] then
        return self._uidStateMap[uidOrAlias]
    elseif self._aliasUIDMap[uidOrAlias] then
        return self._uidStateMap[self._aliasUIDMap[uidOrAlias]]
    end
end

---构造
---@type fun()
function Framework:construct()
    if not self.isConstructed then
        self.isConstructed = true
        if xx.isFunction(self.onConstruct) then
            self:onConstruct()
        end
        if self.isConstructed and self.curState then
            self.curState:construct()
        end
    end
end
---进入
---@type fun()
function Framework:focus()
    self:construct()
    if self.isConstructed and not self.isFocused then
        self.isFocused = true
        if xx.isFunction(self.onFocus) then
            self:onFocus()
        end
        if self.isFocused and self.curState then
            self.curState:focus()
        end
    end
end
---激活
---@type fun()
function Framework:activate()
    self:focus()
    if self.isFocused and not self.isActivated then
        self.isActivated = true
        if xx.isFunction(self.onActivate) then
            self:onActivate()
        end
        if self.isActivated and self.curState then
            self.curState:activate()
        end
    end
end
---失效
---@type fun()
function Framework:deactivate()
    if self.isActivated then
        if self.curState then
            self.curState:deactivate()
        end
        self.isActivated = false
        if xx.isFunction(self.onDeactivate) then
            self:onDeactivate()
        end
    end
end
---离开
---@type fun()
function Framework:defocus()
    self:deactivate()
    if self.isFocused then
        if self.curState then
            self.curState:defocus()
        end
        self.isFocused = false
        if xx.isFunction(self.onDefocus) then
            self:onDefocus()
        end
    end
end
---析构
---@type fun()
function Framework:destruct()
    self:defocus()
    if self.isConstructed then
        if self.curState then
            self.curState:destruct()
        end
        self.isConstructed = false

        for _, state in pairs(self._uidStateMap) do
            state:removeEventListener(GIdentifiers.e_complete, self._onChildCompleteHandler, self)
            state:destruct()
        end
        self.curState = nil
        self.numStates = 0
        xx.tableClear(self._context)
        xx.tableClear(self._stateUIDs)
        xx.tableClear(self._uidStateMap)
        xx.tableClear(self._uidAliasMap)
        xx.tableClear(self._aliasUIDMap)
        if xx.isFunction(self.onDestruct) then
            self:onDestruct()
        end
    end
end

---结束当前状态机
---@type fun(...:any)
---@vararg any
function Framework:finishState(...)
    self(GIdentifiers.e_complete, ...)
end

---子状态机结束回调
---@type fun(evt:Event)
---@param evt Event 事件对象
function Framework:_onChildCompleteHandler(evt)
    evt:stopImmediate()

    if self.curState ~= evt.currentTarget then
        return
    end
    self:toState()
    self:onChildComplete(evt.currentTarget, unpack(evt.args))
end

---子状态机结束实现
---@type fun(state:Framework,...:any)
---@param state Framework 子状态机对象
---@vararg any
function Framework:onChildComplete(state, ...)
    local index = xx.arrayIndexOf(self._stateUIDs, state.uid) + 1
    if index > xx.arrayCount(self._stateUIDs) then
        self:finishState(...)
    else
        self:toState(self._stateUIDs[index])
    end
end
