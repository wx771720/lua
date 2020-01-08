---缓动步骤
---@class TweenStep:ObjectEx by wx771720@outlook.com 2019-10-28 15:22:39
---@field _tween Tween 缓动器
---@field _isTo boolean 属性值是否为最终值
---@field _properties table<string,any> 键值对
---@field _time number 缓动时长（单位：毫秒）
---@field _playback boolean 是否回播
---@field _ease Ease 缓动函数
---@field _onPlayback Callback 回播时回调
---@field _onUpdate Callback 更新时回调
---
---@field _timePassed number 已经过的时长（单位：毫秒）
---@field _beginMap table<any,table<string,any>> 对象 - 起始键值对
---@field _changeMap table<any,table<string,any>> 对象 - 变化键值对
local TweenStep = xx.Class("xx.TweenStep")
---构造函数
function TweenStep:ctor(tween, isTo, properties, time, playback, ease, onPlayback, onUpdate)
    self._tween = tween
    self._isTo = isTo
    self._properties = properties
    self._time = time or 1000
    if xx.isBoolean(playback) then
        self._playback = playback
    else
        self._playback = false
    end
    self._ease = ease or xx.easeLinear
    self._onPlayback = onPlayback
    self._onUpdate = onUpdate

    self._timePassed = 0
end

---更新
---type fun(interval:number):number
---@param interval number 帧间隔（单位：毫秒）
---@return number 剩余时长（单位：毫秒）
function TweenStep:update(interval)
    -- 缓存起始值
    if not self._beginMap then
        self._beginMap = {}
        self._changeMap = {}
        for _, target in ipairs(self._tween.targets) do
            local beginMap = {}
            local changeMap = {}
            for k, v in pairs(self._properties) do
                beginMap[k] = self._tween.curValueMap[target][k]
                -- 贝塞尔缓动
                if xx.isTable(v) then
                    changeMap[k] = {0}
                    for i = 1, xx.arrayCount(v) do
                        xx.arrayPush(changeMap[k], self._isTo and v[i] - beginMap[k] or v[i])
                    end
                else -- 普通缓动
                    changeMap[k] = self._isTo and v - beginMap[k] or v
                end
            end
            self._beginMap[target] = beginMap
            self._changeMap[target] = changeMap
        end
    end
    -- 更新时长
    local halfTime = self._time / 2
    local isPlayback = self._playback and self._timePassed < halfTime and self._timePassed + interval >= halfTime
    self._timePassed = self._timePassed + interval

    local value
    local time = self._timePassed > self._time and self._time or self._timePassed
    if self._playback then
        time = (time < halfTime and time or self._time - time) * 2
    end
    -- 更新值
    for _, target in ipairs(self._tween.targets) do
        local beginMap = self._beginMap[target]
        local changeMap = self._changeMap[target]
        for k, beginV in pairs(beginMap) do
            local change = changeMap[k]
            if xx.isTable(change) then
                value = beginV + xx.bezier(self._ease(time, 0, 1, self._time), unpack(change))
            else
                value = self._ease(time, beginV, change, self._time)
            end
            self._tween.curValueMap[target][k] = value
            target[k] = value
            if self._onUpdate then
                self._onUpdate(target, k, value)
            end
        end
    end
    if isPlayback and self._onPlayback then
        self._onPlayback()
    end
    -- 结束
    if self._timePassed >= self._time then
        interval = self._timePassed - self._time
        self._timePassed = 0
        self._beginMap = nil
        self._changeMap = nil

        self._tween.stepIndex = self._tween.stepIndex + 1
    else
        interval = 0
    end
    return interval
end

return TweenStep
