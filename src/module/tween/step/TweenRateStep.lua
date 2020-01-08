---缓动设置速率步骤
---@class TweenRateStep:ObjectEx by wx771720@outlook.com 2019-10-26 18:58:46
---@field _tween Tween 缓动器
---@field _isTo boolean 属性值是否为最终值
---@field _rate number 速率
local TweenRateStep = xx.Class("xx.TweenRateStep")
---构造函数
function TweenRateStep:ctor(tween, isTo, rate)
    self._tween = tween
    self._isTo = isTo
    self._rate = rate or 1
end

---更新
---type fun(interval:number):number
---@param interval number 帧间隔（单位：毫秒）
---@return number 剩余时长（单位：毫秒）
function TweenRateStep:update(interval)
    self._tween.rate = self._isTo and self._rate or self._tween.rate + self._rate

    self._tween.stepIndex = self._tween.stepIndex + 1
    return interval
end

return TweenRateStep
