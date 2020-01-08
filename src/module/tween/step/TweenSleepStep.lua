---缓动睡眠步骤
---@class TweenSleepStep:ObjectEx by wx771720@outlook.com 2019-10-28 14:27:08
---@field _tween Tween 缓动器
---@field _time number 睡眠时长（单位：毫秒）
---
---@field _timePassed number 已经过时长
local TweenSleepStep = xx.Class("xx.TweenSleepStep")
---构造函数
function TweenSleepStep:ctor(tween, time)
    self._tween = tween
    self._time = time or 1000

    self._timePassed = 0
end

---更新
---type fun(interval:number):number
---@param interval number 帧间隔（单位：毫秒）
---@return number 剩余时长（单位：毫秒）
function TweenSleepStep:update(interval)
    self._timePassed = self._timePassed + interval
    if self._timePassed >= self._time then
        interval = self._timePassed - self._time

        self._timePassed = 0
        self._tween.stepIndex = self._tween.stepIndex + 1
    else
        interval = 0
    end
    return interval
end

return TweenSleepStep
