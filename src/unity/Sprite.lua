---unity 显示对象代理
---@class Sprite:Node by wx771720@outlook.com 2019-09-29 18:31:27
---@field _csTypeHandlerMap table<string,Handler> Unity 组件事件类型 - 回调函数
---
---@field _propertyHandler table 属性改变回调
---@field gameObject GameObject Unity 游戏对象
---@field pivotX number x 轴心比例
---@field pivotY number y 轴心比例
---@field x number x 坐标
---@field y number y 坐标
---@field z number z 坐标
---@field width number 宽度
---@field height number 高度
---@field scaleX number x 轴缩放
---@field scaleY number y 轴缩放
---@field scaleZ number z 轴缩放
---@field rotationX number x 轴旋转度数
---@field rotationY number y 轴旋转度数
---@field rotationZ number z 轴旋转度数
---@field alpha number 透明度
---@field visible boolean 是否可见
---@field tint Color 着色
---@field touchable boolean 是否可交互
---
---@field source UnityEngine.Sprite 图片纹理
---@field fillAmount number 填充值，范围[0-1]
---@field fillClockwise boolean 是否顺时针
---@field fillCenter boolean 九宫格是否填充中间
---@field preserveAspect boolean 是否保持宽高比
---
---@field text string 文本
---@field fontColor Color 文本颜色
---@field fontSize number 字号
---@field font UnityEngine.Font 字体
---@field alignByGeometry number 是否对齐几何线
---@field resizeTextForBestFit boolean 是否缩放到合适的字号
---@field resizeTextMinSize number 最小的缩放字号
---@field resizeTextMaxSize number 最大的缩放字号
---@field lineSpacing number 行高倍数
local Sprite = xx.Class("xx.Sprite", xx.Node)

---@see Sprite
xx.Sprite = Sprite

Sprite.property_pivot_x = "pivotX"
Sprite.property_pivot_y = "pivotY"
Sprite.property_x = "x"
Sprite.property_y = "y"
Sprite.property_z = "z"
Sprite.property_width = "width"
Sprite.property_height = "height"
Sprite.property_scale_x = "scaleX"
Sprite.property_scale_y = "scaleY"
Sprite.property_scale_z = "scaleZ"
Sprite.property_rotation_x = "rotationX"
Sprite.property_rotation_y = "rotationY"
Sprite.property_rotation_z = "rotationZ"
Sprite.property_alpha = "alpha"
Sprite.property_visible = "visible"
Sprite.property_tint = "tint"
Sprite.property_touchable = "touchable"

Sprite.property_source = "source"
Sprite.property_fill_amount = "fillAmount"
Sprite.property_fill_clockwise = "fillClockwise"
Sprite.property_fill_center = "fillCenter"
Sprite.property_preserve_aspect = "preserveAspect"

Sprite.property_text = "text"
Sprite.property_font_color = "fontColor"
Sprite.property_font_size = "fontSize"
Sprite.property_font = "font"
Sprite.property_align_by_geometry = "alignByGeometry"
Sprite.property_resize_text_for_best_fit = "resizeTextForBestFit"
Sprite.property_resize_text_min_size = "resizeTextMinSize"
Sprite.property_resize_text_max_size = "resizeTextMaxSize"
Sprite.property_line_spacing = "lineSpacing"

function Sprite:onDynamicChanged(key, newValue, oldValue)
    if self._propertyHandler[key] then
        self._propertyHandler[key](self.gameObject, newValue)
    end
    xx.Node.onDynamicChanged(self, key, newValue, oldValue)
end

---构造函数
---@param gameObject GameObject|nil
function Sprite:ctor(gameObject)
    self.gameObject = gameObject or UnityEngine.GameObject(self.uid, typeof("UnityEngine.RectTransform"))

    self._csTypeHandlerMap = {}

    self._propertyHandler = {}
    self._propertyHandler[Sprite.property_pivot_x] = self.gameObject.SetPivotX
    self._propertyHandler[Sprite.property_pivot_y] = self.gameObject.SetPivotY
    self._propertyHandler[Sprite.property_x] = self.gameObject.SetX
    self._propertyHandler[Sprite.property_y] = self.gameObject.SetY
    self._propertyHandler[Sprite.property_z] = self.gameObject.SetZ
    self._propertyHandler[Sprite.property_width] = self.gameObject.SetWidth
    self._propertyHandler[Sprite.property_height] = self.gameObject.SetHeight
    self._propertyHandler[Sprite.property_scale_x] = self.gameObject.SetScaleX
    self._propertyHandler[Sprite.property_scale_y] = self.gameObject.SetScaleY
    self._propertyHandler[Sprite.property_scale_z] = self.gameObject.SetScaleZ
    self._propertyHandler[Sprite.property_rotation_x] = self.gameObject.SetRotationX
    self._propertyHandler[Sprite.property_rotation_y] = self.gameObject.SetRotationY
    self._propertyHandler[Sprite.property_rotation_z] = self.gameObject.SetRotationZ
    self._propertyHandler[Sprite.property_alpha] = self.gameObject.SetAlpha
    self._propertyHandler[Sprite.property_visible] = self.gameObject.SetVisible
    self._propertyHandler[Sprite.property_tint] = self.gameObject.SetColor

    self._propertyHandler[Sprite.property_touchable] = self.gameObject.SetTouchable

    self._propertyHandler[Sprite.property_source] = self.gameObject.SetSprite
    self._propertyHandler[Sprite.property_fill_amount] = self.gameObject.SetFillAmount
    self._propertyHandler[Sprite.property_fill_clockwise] = self.gameObject.SetFillClockwise
    self._propertyHandler[Sprite.property_fill_center] = self.gameObject.SetFillCenter
    self._propertyHandler[Sprite.property_preserve_aspect] = self.gameObject.SetPreserveAspect

    self._propertyHandler[Sprite.property_text] = self.gameObject.SetText
    self._propertyHandler[Sprite.property_font_color] = self.gameObject.SetFontColor
    self._propertyHandler[Sprite.property_font_size] = self.gameObject.SetFontSize
    self._propertyHandler[Sprite.property_font] = self.gameObject.SetFont
    self._propertyHandler[Sprite.property_align_by_geometry] = self.gameObject.SetAlignByGeometry
    self._propertyHandler[Sprite.property_resize_text_for_best_fit] = self.gameObject.SetResizeTextForBestFit
    self._propertyHandler[Sprite.property_resize_text_min_size] = self.gameObject.SetResizeTextMinSize
    self._propertyHandler[Sprite.property_resize_text_max_size] = self.gameObject.SetResizeTextMaxSize
    self._propertyHandler[Sprite.property_line_spacing] = self.gameObject.SetLineSpacing

    xx.Class.setter(self, Sprite.property_pivot_x, self.gameObject:GetPivotX())
    xx.Class.setter(self, Sprite.property_pivot_y, self.gameObject:GetPivotY())
    xx.Class.setter(self, Sprite.property_x, self.gameObject:GetX())
    xx.Class.setter(self, Sprite.property_y, self.gameObject:GetY())
    xx.Class.setter(self, Sprite.property_z, self.gameObject:GetZ())
    xx.Class.setter(self, Sprite.property_width, self.gameObject:GetWidth())
    xx.Class.setter(self, Sprite.property_height, self.gameObject:GetHeight())
    xx.Class.setter(self, Sprite.property_scale_x, self.gameObject:GetScaleX())
    xx.Class.setter(self, Sprite.property_scale_y, self.gameObject:GetScaleY())
    xx.Class.setter(self, Sprite.property_scale_z, self.gameObject:GetScaleZ())
    xx.Class.setter(self, Sprite.property_rotation_x, self.gameObject:GetRotationX())
    xx.Class.setter(self, Sprite.property_rotation_y, self.gameObject:GetRotationY())
    xx.Class.setter(self, Sprite.property_rotation_z, self.gameObject:GetRotationZ())
    xx.Class.setter(self, Sprite.property_alpha, self.gameObject:GetAlpha())
    xx.Class.setter(self, Sprite.property_visible, self.gameObject:GetVisible())
    xx.Class.setter(self, Sprite.property_tint, self.gameObject:GetColor())

    if self:isImage() then
        xx.Class.setter(self, Sprite.property_touchable, self.gameObject:GetTouchable())

        xx.Class.setter(self, Sprite.property_source, self.gameObject:GetSprite())
        xx.Class.setter(self, Sprite.property_fill_amount, self.gameObject:GetFillAmount())
        xx.Class.setter(self, Sprite.property_fill_clockwise, self.gameObject:GetFillClockwise())
        xx.Class.setter(self, Sprite.property_fill_center, self.gameObject:GetFillCenter())
        xx.Class.setter(self, Sprite.property_preserve_aspect, self.gameObject:GetPreserveAspect())
    end

    if self:isText() then
        xx.Class.setter(self, Sprite.property_touchable, self.gameObject:GetTouchable())

        xx.Class.setter(self, Sprite.property_text, self.gameObject:GetText())
        xx.Class.setter(self, Sprite.property_font_color, self.gameObject:GetFontColor())
        xx.Class.setter(self, Sprite.property_font_size, self.gameObject:GetFontSize())
        xx.Class.setter(self, Sprite.property_font, self.gameObject:GetFont())
        xx.Class.setter(self, Sprite.property_align_by_geometry, self.gameObject:GetAlignByGeometry())
        xx.Class.setter(self, Sprite.property_resize_text_for_best_fit, self.gameObject:GetResizeTextForBestFit())
        xx.Class.setter(self, Sprite.property_resize_text_min_size, self.gameObject:GetResizeTextMinSize())
        xx.Class.setter(self, Sprite.property_resize_text_max_size, self.gameObject:GetResizeTextMaxSize())
        xx.Class.setter(self, Sprite.property_line_spacing, self.gameObject:GetLineSpacing())
    end
end

---添加事件回调
---@type fun(type:string, handler:Handler, caller:any, ...:any[]):EventDispatcher
---@param type string 事件类型
---@param handler Handler 回调函数，return: boolean（是否立即停止执行后续回调）, boolean（是否停止冒泡）
---@param caller any|nil 回调方法所属的对象，匿名函数或者静态函数可不传入
---@return EventDispatcher self
function Sprite:addEventListener(type, handler, caller, ...)
    xx.EventDispatcher.addEventListener(self, type, handler, caller, ...)
    self:checkCSEvents()
    return self
end
---添加事件回调
---@type fun(type:string, handler:Handler, caller:any, ...:any[]):EventDispatcher
---@param type string 事件类型
---@param handler Handler 回调函数，return: boolean（是否立即停止执行后续回调）, boolean（是否停止冒泡）
---@param caller any|nil 回调方法所属的对象，匿名函数或者静态函数可不传入
---@return EventDispatcher self
function Sprite:once(type, handler, caller, ...)
    xx.EventDispatcher.once(self, type, handler, caller, ...)
    self:checkCSEvents()
    return self
end
---删除事件回调
---@type fun(type:string, handler:Handler, caller:any):EventDispatcher
---@param type string|nil 事件类型，默认 nil 表示移除所有 handler 和 caller 回调
---@param handler Handler|nil 回调函数，默认 nil 表示移除所有包含 handler 回调
---@param caller any|nil 回调方法所属的对象，匿名函数或者静态函数可不传入，默认 nil 表示移除所有包含 caller 的回调
---@return EventDispatcher self
function Sprite:removeEventListener(type, handler, caller)
    xx.EventDispatcher.removeEventListener(self, type, handler, caller)
    self:checkCSEvents()
    return self
end

---等待事件触发
---@type fun(type:string):Promise
---@param type string 事件类型
---@return Promise 异步对象
function Sprite:wait(type)
    local promise = xx.EventDispatcher.wait(self, type)
    self:checkCSEvents()
    return promise
end
---取消等待事件
---@type fun(type:string|nil):EventDispatcher
---@param type string|nil 事件类型，null 表示取消所有等待事件
---@return EventDispatcher self
function Sprite:removeWait(type)
    xx.EventDispatcher.removeWait(self, type)
    self:checkCSEvents()
    return self
end
function Sprite:checkCSEvents()
    for type, csHandler in pairs(self._csTypeHandlerMap) do
        if not self:hasEventListener(type) and not self:hasWait(type) then
            self.gameObject:RemoveEventListener(type, csHandler)
            self._csTypeHandlerMap[type] = nil
        end
    end
    for type, _ in pairs(self._typeCallbacksMap) do
        if not self._csTypeHandlerMap[type] then
            self._csTypeHandlerMap[type] = xx.Handler(self._onCSHandler, self)
            self.gameObject:AddEventListener(type, self._csTypeHandlerMap[type])
        end
    end
    for type, _ in pairs(self._typePromisesMap) do
        if not self._csTypeHandlerMap[type] then
            self._csTypeHandlerMap[type] = xx.Handler(self._onCSHandler, self)
            self.gameObject:AddEventListener(type, self._csTypeHandlerMap[type])
        end
    end
end
---派发事件
---@type fun(csEvent:CSEvent)
---@param csEvent CSEvent 事件类型
function Sprite:_onCSHandler(csEvent)
    local type = csEvent.Type
    if csEvent.Args and csEvent.Args.Length > 0 then
        local args = {}
        for i = 0, csEvent.Args.Length - 1 do
            xx.arrayPush(args, csEvent.Args[i])
        end
        self(type, unpack(args))
    else
        self(type)
    end
    self:checkCSEvents()
end

---添加子节点到指定索引
---@type fun(child:Sprite,index:number):Sprite|nil
---@param child Sprite 子节点
---@param index number 索引
---@return Sprite|nil 返回添加成功的子节点
function Sprite:addChildAt(child, index)
    child = xx.Node.addChildAt(self, child, index)
    if xx.instanceOf(child, Sprite) then
        child.gameObject.transform:SetParent(self.gameObject.transform, false)
        self:_refreshIndex()
    end
    return child
end

---移除指定索引的子节点
---@type fun(index:number):Sprite|nil
---@param index number 索引
---@return Sprite|nil 返回删除成功的子节点
function Sprite:removeChildAt(index)
    ---@type Sprite
    local child = xx.Node.removeChildAt(self, index)
    if xx.instanceOf(child, Sprite) then
        child.gameObject.transform:SetParent(nil, false)
        return child
    end
end

---修改子节点索引
---@type fun(child:Sprite,index:number):Sprite|nil
---@param child Sprite 子节点
---@param index number 索引
---@return Sprite|nil 返回修改成功的子节点
function Sprite:setChildIndex(child, index)
    child = xx.Node.setChildIndex(self, child, index)
    if xx.instanceOf(child, Sprite) then
        self:_refreshIndex()
        return child
    end
end

---刷新 unity 子对象层级
---@type fun()
function Sprite:_refreshIndex()
    ---@type Sprite
    local child
    local siblingIndex = 0
    for i = 1, self.numChildren do
        child = self._children[i]
        child.gameObject.transform:SetSiblingIndex(i - 1)
    end
end
-- -----------------------------------------------------------------------------
-- Holder
-- -----------------------------------------------------------------------------
function Sprite:getFromHolder(name)
    return self.gameObject:GetFromHolder(name)
end
-- -----------------------------------------------------------------------------
-- Layout
-- -----------------------------------------------------------------------------
function Sprite:anchorSet(minX, minY, maxX, maxY, pivotX, pivotY, x, y)
    self.gameObject:AnchorSet(minX, minY, maxX, maxY, pivotX, pivotY, x, y)
end
function Sprite:anchorTop(y)
    self.gameObject:AnchorTop(y or 0)
end
function Sprite:anchorMiddle(y)
    self.gameObject:AnchorMiddle(y or 0)
end
function Sprite:anchorBottom(y)
    self.gameObject:AnchorBottom(y or 0)
end
function Sprite:anchorLeft(x)
    self.gameObject:AnchorLeft(x or 0)
end
function Sprite:anchorCenter(x)
    self.gameObject:AnchorCenter(x or 0)
end
function Sprite:anchorRight(x)
    self.gameObject:AnchorRight(x or 0)
end
function Sprite:anchorTopLeft(x, y)
    self.gameObject:AnchorTopLeft(x or 0, y or 0)
end
function Sprite:anchorTopCenter(x, y)
    self.gameObject:AnchorTopCenter(x or 0, y or 0)
end
function Sprite:anchorTopRight(x, y)
    self.gameObject:AnchorTopRight(x or 0, y or 0)
end
function Sprite:anchorMiddleLeft(x, y)
    self.gameObject:AnchorMiddleLeft(x or 0, y or 0)
end
function Sprite:anchorMiddleCenter(x, y)
    self.gameObject:AnchorMiddleCenter(x or 0, y or 0)
end
function Sprite:anchorMiddleRight(x, y)
    self.gameObject:AnchorMiddleRight(x or 0, y or 0)
end
function Sprite:anchorBottomLeft(x, y)
    self.gameObject:AnchorBottomLeft(x or 0, y or 0)
end
function Sprite:anchorBottomCenter(x, y)
    self.gameObject:AnchorBottomCenter(x or 0, y or 0)
end
function Sprite:anchorBottomRight(x, y)
    self.gameObject:AnchorBottomRight(x or 0, y or 0)
end

function Sprite:stretchHorizontal(left, right)
    self.gameObject:StretchHorizontal(left or 0, right or 0)
end
function Sprite:stretchVertical(top, bottom)
    self.gameObject:StretchVertical(top or 0, bottom or 0)
end
function Sprite:stretchBoth(left, right, top, bottom)
    self.gameObject:StretchBoth(left or 0, right or 0, top or 0, bottom or 0)
end

function Sprite:worldToLocal(worldX, worldY, worldZ)
    return self.gameObject:WorldToLocal(worldX, worldY, worldZ)
end
function Sprite:localToWorld(localX, localY, localZ)
    return self.gameObject:LocalToWorld(localX, localY, localZ)
end
function Sprite:screenToLocal(screenX, screenY)
    return self.gameObject:ScreenToLocal(screenX, screenY)
end
function Sprite:localToScreen(screenX, screenY)
    return self.gameObject:LocalToScreen(screenX, screenY)
end
-- -----------------------------------------------------------------------------
-- Image
-- -----------------------------------------------------------------------------
function Sprite:toImage()
    self.gameObject:ToImage()
    xx.Class.setter(self, Sprite.property_touchable, self.gameObject:GetTouchable())

    xx.Class.setter(self, Sprite.property_source, self.gameObject:GetSprite())
    xx.Class.setter(self, Sprite.property_fill_amount, self.gameObject:GetFillAmount())
    xx.Class.setter(self, Sprite.property_fill_clockwise, self.gameObject:GetFillClockwise())
    xx.Class.setter(self, Sprite.property_fill_center, self.gameObject:GetFillCenter())
    xx.Class.setter(self, Sprite.property_preserve_aspect, self.gameObject:GetPreserveAspect())
end
function Sprite:isImage()
    return self.gameObject:IsImage()
end
function Sprite:setNativeSize()
    self.gameObject:SetNativeSize()
end
function Sprite:setTypeSimple()
    self.gameObject:SetTypeSimple()
end
function Sprite:setTypeSliced()
    self.gameObject:SetTypeSliced()
end
function Sprite:setTypeTiled()
    self.gameObject:SetTypeTiled()
end
function Sprite:setTypeFilled()
    self.gameObject:SetTypeFilled()
end
function Sprite:setFillHorizontal()
    self.gameObject:SetFillHorizontal()
end
function Sprite:setFillVertical()
    self.gameObject:SetFillVertical()
end
function Sprite:setFillRadia90()
    self.gameObject:SetFillRadia90()
end
function Sprite:setFillRadia180()
    self.gameObject:SetFillRadia180()
end
function Sprite:setFillRadia360()
    self.gameObject:SetFillRadia360()
end
function Sprite:setOriginHorizontalLeft()
    self.gameObject:SetOriginHorizontalLeft()
end
function Sprite:setOriginHorizontalRight()
    self.gameObject:SetOriginHorizontalRight()
end
function Sprite:setOriginVerticalBottom()
    self.gameObject:SetOriginVerticalBottom()
end
function Sprite:setOriginVerticalTop()
    self.gameObject:SetOriginVerticalTop()
end
function Sprite:setOriginRadia90BottomLeft()
    self.gameObject:SetOriginRadia90BottomLeft()
end
function Sprite:setOriginRadia90TopLeft()
    self.gameObject:SetOriginRadia90TopLeft()
end
function Sprite:setOriginRadia90TopRight()
    self.gameObject:SetOriginRadia90TopRight()
end
function Sprite:setOriginRadia90BottomRight()
    self.gameObject:SetOriginRadia90BottomRight()
end
function Sprite:setOriginRadia180Bottom()
    self.gameObject:SetOriginRadia180Bottom()
end
function Sprite:setOriginRadia180Left()
    self.gameObject:SetOriginRadia180Left()
end
function Sprite:setOriginRadia180Top()
    self.gameObject:SetOriginRadia180Top()
end
function Sprite:setOriginRadia180Right()
    self.gameObject:SetOriginRadia180Right()
end
function Sprite:setOriginRadia360Bottom()
    self.gameObject:SetOriginRadia360Bottom()
end
function Sprite:setOriginRadia360Right()
    self.gameObject:SetOriginRadia360Right()
end
function Sprite:setOriginRadia360Top()
    self.gameObject:SetOriginRadia360Top()
end
function Sprite:setOriginRadia360Left()
    self.gameObject:SetOriginRadia360Left()
end
-- -----------------------------------------------------------------------------
-- Text
-- -----------------------------------------------------------------------------
function Sprite:toText()
    self.gameObject:ToText()
    xx.Class.setter(self, Sprite.property_touchable, self.gameObject:GetTouchable())

    xx.Class.setter(self, Sprite.property_text, self.gameObject:GetText())
    xx.Class.setter(self, Sprite.property_font_color, self.gameObject:GetFontColor())
    xx.Class.setter(self, Sprite.property_font_size, self.gameObject:GetFontSize())
    xx.Class.setter(self, Sprite.property_font, self.gameObject:GetFont())
    xx.Class.setter(self, Sprite.property_align_by_geometry, self.gameObject:GetAlignByGeometry())
    xx.Class.setter(self, Sprite.property_resize_text_for_best_fit, self.gameObject:GetResizeTextForBestFit())
    xx.Class.setter(self, Sprite.property_resize_text_min_size, self.gameObject:GetResizeTextMinSize())
    xx.Class.setter(self, Sprite.property_resize_text_max_size, self.gameObject:GetResizeTextMaxSize())
    xx.Class.setter(self, Sprite.property_line_spacing, self.gameObject:GetLineSpacing())
end
function Sprite:isText()
    return self.gameObject:IsText()
end
function Sprite:setStyleNormal()
    self.gameObject:SetStyleNormal()
end
function Sprite:setStyleBold()
    self.gameObject:SetStyleBold()
end
function Sprite:setStyleItalic()
    self.gameObject:SetStyleItalic()
end
function Sprite:setStyleBoldAndItalic()
    self.gameObject:SetStyleBoldAndItalic()
end
function Sprite:setHorizontalWrap()
    self.gameObject:SetHorizontalWrap()
end
function Sprite:setHorizontalOverflow()
    self.gameObject:SetHorizontalOverflow()
end
function Sprite:setVerticalTruncate()
    self.gameObject:SetVerticalTruncate()
end
function Sprite:setVerticalOverflow()
    self.gameObject:SetVerticalOverflow()
end
function Sprite:setResizeText(resizeTextForBestFit, resizeTextMinSize, resizeTextMaxSize)
    self.gameObject:SetResizeText(resizeTextForBestFit, resizeTextMinSize, resizeTextMaxSize)
end
function Sprite:setAlignUpperLeft()
    self.gameObject:SetAlignUpperLeft()
end
function Sprite:setAlignUpperCenter()
    self.gameObject:SetAlignUpperCenter()
end
function Sprite:setAlignUpperRight()
    self.gameObject:SetAlignUpperRight()
end
function Sprite:setAlignMiddleLeft()
    self.gameObject:SetAlignMiddleLeft()
end
function Sprite:setAlignMiddleCenter()
    self.gameObject:SetAlignMiddleCenter()
end
function Sprite:setAlignMiddleRight()
    self.gameObject:SetAlignMiddleRight()
end
function Sprite:setAlignLowerLeft()
    self.gameObject:SetAlignLowerLeft()
end
function Sprite:setAlignLowerCenter()
    self.gameObject:SetAlignLowerCenter()
end
function Sprite:setAlignLowerRight()
    self.gameObject:SetAlignLowerRight()
end
function Sprite:setAutoSizeHorizontal(autoSize)
    self.gameObject:SetAutoSizeHorizontal(autoSize)
end
function Sprite:setAutoSizeVertical(autoSize)
    self.gameObject:SetAutoSizeVertical(autoSize)
end
function Sprite:setAutoSize(horizontal, vertical)
    self.gameObject:SetAutoSize(horizontal, vertical)
end
-- -----------------------------------------------------------------------------
-- Animation
-- -----------------------------------------------------------------------------
function Sprite:setBool(name, value)
    self.gameObject:SetBool(name, value)
end
function Sprite:setInteger(name, value)
    self.gameObject:SetInteger(name, value)
end
function Sprite:setFloat(name, value)
    self.gameObject:SetFloat(name, value)
end
function Sprite:setTrigger(name)
    self.gameObject:SetTrigger(name)
end
function Sprite:playAnimator(name)
    self.gameObject:PlayAnimator(name)
end
function Sprite:playAnimator(name)
    self.gameObject:PlayAnimator(name)
end
function Sprite:stopAnimator()
    self.gameObject:StopAnimator()
end
function Sprite:updateAnimator(deltaTimeMS)
    self.gameObject:UpdateAnimator(deltaTimeMS)
end
-- -----------------------------------------------------------------------------
-- 粒子
-- -----------------------------------------------------------------------------
function Sprite:playParticleSystem(withChildren)
    self.gameObject:PlayParticleSystem(true == withChildren)
end
function Sprite:pauseParticleSystem(withChildren)
    self.gameObject:PauseParticleSystem(true == withChildren)
end
function Sprite:stopParticleSystem(withChildren)
    self.gameObject:StopParticleSystem(true == withChildren)
end
