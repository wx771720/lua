local Tween = require("Tween")

---缓动模块
---@class MTween:Module by wx771720@outlook.com 2019-10-25 15:37:39
---@field _isPaused boolean 是否已暂停定时器模块
---@field _tweenList Tween[] 缓动器列表
---@field _uidTweenMap table<string,Tween> uid - 缓动器
---@field _targetUIDsMap table<any,string[]> 对象 - 缓动器 uid 列表
local MTween = xx.Class("xx.MTween", xx.Module)
---构造函数
function MTween:ctor()
    self._isPaused = false
    self._tweenList = {}
    self._uidTweenMap = {}
    self._targetUIDsMap = {}

    self._noticeHandlerMap[GIdentifiers.nb_timer] = self.onAppTimer
    self._noticeHandlerMap[GIdentifiers.nb_pause] = self.onAppPause
    self._noticeHandlerMap[GIdentifiers.nb_resume] = self.onAppResume
    self._noticeHandlerMap[GIdentifiers.ni_tween_new] = self.onNew
    self._noticeHandlerMap[GIdentifiers.ni_tween_stop] = self.onStop
end

---帧循环
---@type fun(result:NoticeResult,interval:number)
---@param result NoticeResult 直接返回结果
---@param interval number 帧间隔（单位：毫秒）
function MTween:onAppTimer(result, interval)
    -- 已暂停 | 无效帧
    if self._isPaused or interval >= 1000 then
        return
    end

    local uids
    for index = xx.arrayCount(self._tweenList), 1, -1 do
        local tween = self._tweenList[index]
        -- 有停止部分缓动对象
        if xx.arrayCount(tween.stopList) > 0 then
            for _, stop in ipairs(tween.stopList) do
                tween.trigger = tween.trigger or stop.trigger
                local map = tween.endValueMap[stop.target]
                -- 清除缓存
                xx.arrayRemove(tween.targets, stop.target)
                tween.curValueMap[stop.target] = nil
                tween.endValueMap[stop.target] = nil

                uids = self._targetUIDsMap[stop.target]
                if 1 == xx.arrayCount(uids) then
                    self._targetUIDsMap[stop.target] = nil
                else
                    xx.arrayRemove(uids, tween.uid)
                end
                -- 设置为结束值
                if stop.toEnd then
                    for k, v in pairs(map) do
                        stop.target[k] = v
                    end
                end
            end
            xx.arrayContains(tween.stopList)
            -- 缓动器已停止
            tween.isStopped = tween.isStopped or 0 == xx.arrayCount(tween.targets)
        end

        repeat
            -- 已停止
            if tween.isStopped then
                -- 清除缓存 + 设置为结束值
                xx.arrayRemoveAt(self._tweenList, index)
                self._uidTweenMap[tween.uid] = nil
                for _, target in ipairs(tween.targets) do
                    uids = self._targetUIDsMap[target]
                    if 1 == xx.arrayCount(uids) then
                        self._targetUIDsMap[target] = nil
                    else
                        xx.arrayRemove(uids, tween.uid)
                    end
                    if tween.toEnd then
                        local map = tween.endValueMap[target]
                        for k, v in pairs(map) do
                            target[k] = v
                        end
                    end
                end
                -- 触发回调
                if tween.trigger then
                    tween:resolve()
                else
                    tween:cancel()
                end
                break
            end
            -- 已暂停
            if tween.isPaused then
                break
            end
            -- 更新
            local time = interval * tween.rate
            if time < 0 then
                break
            end
            while self._uidTweenMap[tween.uid] and time > 0 and not tween.isCompleted do
                time = tween.stepList[tween.stepIndex]:update(time)
            end
            -- 已结束
            if tween.isCompleted then
                -- 清除缓存
                xx.arrayRemoveAt(self._tweenList, index)
                self._uidTweenMap[tween.uid] = nil
                for _, target in ipairs(tween.targets) do
                    uids = self._targetUIDsMap[target]
                    if 1 == xx.arrayCount(target) then
                        self._targetUIDsMap[target] = nil
                    else
                        xx.arrayRemove(uids, tween.uid)
                    end
                end
                -- 触发回调
                tween:resolve()
            end
        until true
    end
end

---@param result NoticeResult 直接返回结果
function MTween:onAppPause(result)
    self._isPaused = true
end

---@param result NoticeResult 直接返回结果
function MTween:onAppResume(result)
    self._isPaused = false
end

---@param result NoticeResult 直接返回结果
---@vararg any
function MTween:onNew(result, ...)
    local tween = Tween(...)
    xx.arrayPush(self._tweenList, tween)
    self._uidTweenMap[tween.uid] = tween
    for _, target in ipairs(tween.targets) do
        if self._targetUIDsMap[target] then
            xx.arrayPush(self._targetUIDsMap[target], tween.uid)
        else
            self._targetUIDsMap[target] = {tween.uid}
        end
    end
    result.data = tween
end

---停止对象缓动
---@param result NoticeResult 直接返回结果
---@param target any 对象
---@param trigger boolean 是否在停止时触发回调
---@param toEnd boolean 是否在停止时设置属性为结束值
function MTween:onStop(result, target, trigger, toEnd)
    if self._targetUIDsMap[target] then
        local uids = self._targetUIDsMap[target]
        for _, uid in ipairs(uids) do
            self._uidTweenMap[uid]:stop(trigger, toEnd, target)
        end
    end
end

---缓动对象列表
---@type fun(...:any):Tween
---@vararg any
---@return Tween
function xx.tween(...)
    return xx.notify(GIdentifiers.ni_tween_new, ...)
end

---停止对象缓动
---@type fun(target:any,trigger:boolean|nil,toEnd:boolean|nil)
---@param target any 缓动对象
---@param trigger boolean 是否在停止时触发回调，默认 false
---@param toEnd boolean 是否在停止时设置属性为结束值，默认 false
function xx.tweenStop(target, trigger, toEnd)
    xx.notify(GIdentifiers.ni_tween_stop, target, trigger, toEnd)
end

xx.getInstance("xx.MTween")
