---缓动设置属性步骤
---@class TweenSetStep:ObjectEx by wx771720@outlook.com 2019-10-28 14:31:09
---@field _tween Tween 缓动器
---@field _isTo boolean 属性值是否为最终值
---@field _properties table<string,any> 键值对
local TweenSetStep = xx.Class("xx.TweenSetStep")
---构造函数
function TweenSetStep:ctor(tween, isTo, properties)
    self._tween = tween
    self._isTo = isTo
    self._properties = properties
end

---更新
---type fun(interval:number):number
---@param interval number 帧间隔（单位：毫秒）
---@return number 剩余时长（单位：毫秒）
function TweenSetStep:update(interval)
    for _, target in ipairs(self._tween.targets) do
        for k, v in pairs(self._properties) do
            if not self._isTo then
                v = v + self._tween.curValueMap[target][k]
            end
            self._tween.curValueMap[target][k] = v
            target[k] = v
        end
    end
    self._tween.stepIndex = self._tween.stepIndex + 1
    return interval
end

return TweenSetStep
