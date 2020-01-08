---缓动回调步骤
---@class TweenCallbackStep:ObjectEx by wx771720@outlook.com 2019-12-09 15:51:21
---@field _tween Tween 缓动器
---@field _callback Callback 结束时回调
local TweenCallbackStep = xx.Class("TweenCallbackStep")
---构造函数
function TweenCallbackStep:ctor(tween, onComplete)
    self._tween = tween
    self._callback = onComplete
end

---更新
---type fun(interval:number):number
---@param interval number 帧间隔（单位：毫秒）
---@return number 剩余时长（单位：毫秒）
function TweenCallbackStep:update(interval)
    self._tween.stepIndex = self._tween.stepIndex + 1
    if self._callback then
        self._callback()
    end
    return interval
end

return TweenCallbackStep
