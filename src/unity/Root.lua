---unity 显示对象根代理
---@class Root:Sprite by wx771720@outlook.com 2019-10-12 16:38:20
---@field _rootGO GameObject 实际根节点
---@field _layerMap table<number,Sprite>
---@field _childLayerMap table<Sprite,number>
local Root = xx.Class("xx.Root", xx.Sprite)

---@see Root
xx.Root = Root

---构造函数
---@param cvs GameObject 实际使用根节点下的画布节点
---@param go GameObject 实际根节点
function Root:ctor(cvs, go)
    self._rootGO = go
    self._layerMap = {}
    self._childLayerMap = {}
end

function Root:getFromHolder(name)
    return self._rootGO:GetFromHolder(name)
end

---添加代理到指定层
---@param child Sprite
---@param layer number
function Root:layerAdd(child, layer)
    if not self._layerMap[layer] then
        self._layerMap[layer] = xx.Sprite(xx.Util.GetLayerCVS(layer))
    end
    if self._childLayerMap[child] and self._childLayerMap[child] ~= layer then
        self:layerRemove(child)
    end
    self._childLayerMap[child] = layer
    self._layerMap[layer]:addChild(child)
end

---移除代理
---@param child Sprite
function Root:layerRemove(child)
    if not self._childLayerMap[child] then
        return
    end
    self._layerMap[self._childLayerMap[child]]:removeChild(child)
    self._childLayerMap[child] = nil
end

---将代理在所在层置顶
---@param child Sprite
function Root:layerTop(child)
    if not self._childLayerMap[child] then
        return
    end
    self._layerMap[self._childLayerMap[child]]:addChild(child)
end

---将代理在所在层置底
---@param child Sprite
function Root:layerBottom(child)
    if not self._childLayerMap[child] then
        return
    end
    self._layerMap[self._childLayerMap[child]]:addChildAt(child, 0)
end
