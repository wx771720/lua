---节点
---@class Node:EventDispatcher by wx771720@outlook.com 2019-09-29 16:42:21
---@field _children Node[] 子节点列表
---@field root Node 根节点
---@field parent Node 父节点
---@field numChildren number 子节点数量
local Node = xx.Class("xx.Node", xx.EventDispatcher)

---@see Node
xx.Node = Node

---构造函数
function Node:ctor()
    self._children = {}
    self.root = self
    self.numChildren = 0
end

---派发事件（需要支持冒泡）
---@param evt Event 事件对象
function Node:callEvent(evt)
    xx.EventDispatcher.callEvent(self, evt)
    if not evt.isStopBubble and self.parent then
        self.parent:callEvent(evt)
    end
end

---添加子节点
---@type fun(child:Node):Node|nil
---@param child Node 子节点
---@return Node|nil 返回添加成功的子节点
function Node:addChild(child)
    return self:addChildAt(child, self.numChildren + 1)
end

---添加子节点到指定索引
---@type fun(child:Node,index:number):Node|nil
---@param child Node 子节点
---@param index number 索引
---@return Node|nil 返回添加成功的子节点
function Node:addChildAt(child, index)
    if child then
        -- 判断是否添加的自身或者父节点
        local parent = self
        repeat
            if parent == child then
                return
            end
            parent = parent.parent
        until not parent
        -- 已是子节点
        if self == child.parent then
            index = index <= 0 and 1 or (index > self.numChildren and self.numChildren or index)
            -- 更新顺序
            if self._children[index] ~= child then
                xx.arrayRemove(self._children, child)
                xx.arrayInsert(self._children, child, index)
            end
        else --新增子节点
            child(GIdentifiers.e_add, child)
            child:removeFromParent()
            self.numChildren = self.numChildren + 1
            index = index <= 0 and 1 or (index > self.numChildren and self.numChildren or index)
            xx.arrayInsert(self._children, child, index)
            child.parent = self
            child:_setRoot(self.root)
            child(GIdentifiers.e_added, child)
        end
        return child
    end
end

---移除子节点
---@type fun(child:Node):Node|nil
---@param child Node 子节点
---@return Node|nil 返回删除成功的子节点
function Node:removeChild(child)
    return child and self:removeChildAt(xx.arrayIndexOf(self._children, child))
end

---移除指定索引的子节点
---@type fun(index:number):Node|nil
---@param index number 索引
---@return Node|nil 返回删除成功的子节点
function Node:removeChildAt(index)
    if index >= 1 and index <= self.numChildren then
        local child = self._children[index]
        child(GIdentifiers.e_remove, child)
        self.numChildren = self.numChildren - 1
        xx.arrayRemoveAt(self._children, index)
        child:_setRoot(child)
        child.parent = nil
        child(GIdentifiers.e_removed, child)
        return child
    end
end

---移除多个子节点
---@type fun(beginIndex:number,endIndex:number)
---@param beginIndex number 起始索引（支持负索引），默认 1
---@param endIndex number 结束索引（支持负索引，移除的子节点包含该索引），默认 -1 表示最后一个子节点
function Node:removeChildren(beginIndex, endIndex)
    beginIndex = beginIndex and (beginIndex < 0 and self.numChildren + beginIndex + 1 or beginIndex) or 1
    endIndex = endIndex and (endIndex < 0 and self.numChildren + endIndex + 1 or endIndex) or self.numChildren
    for i = endIndex > self.numChildren and self.numChildren or endIndex, beginIndex < 1 and 1 or beginIndex, -1 do
        self:removeChildAt(i)
    end
end

---修改子节点索引
---@type fun(child:Node,index:number):Node|nil
---@param child Node 子节点
---@param index number 索引
---@return Node|nil 返回修改成功的子节点
function Node:setChildIndex(child, index)
    if index >= 1 and index <= self.numChildren and child and self == child.parent and self._children[index] ~= child then
        xx.arrayRemove(self._children, child)
        xx.arrayInsert(self._children, child, index)
        return child
    end
end

---获取子节点索引
---@type fun(child:Node):number
---@param child Node 子节点
---@return number 如果找到子节点则返回对应索引，否则返回 -1
function Node:getChildIndex(child)
    return child and self == child.parent and xx.arrayIndexOf(self._children, child) or -1
end

---获取指定索引的子节点
---@type fun(index:number):Node|nil
---@param index number 索引
---@return Node|nil 返回指定索引的子节点，如果索引超出范围则返回 nil
function Node:getChildAt(index)
    if index and index >= 1 and index <= self.numChildren then
        return self._children[index]
    end
end

---从父节点移除
---@type fun()
function Node:removeFromParent()
    if self.parent then
        self.parent:removeChild(self)
    end
end

---设置根节点
---@type fun(root:Node)
---@param root Node 根节点
function Node:_setRoot(root)
    if self.root ~= root then
        local oldRoot = self.root
        self.root = root
        self(GIdentifiers.e_root_changed, oldRoot)
        for _, child in ipairs(self._children) do
            child:_setRoot(root)
        end
    end
end
