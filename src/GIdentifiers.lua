---GID 类（由工具自动生成，请勿手动修改）
---@class GIdentifiers author wx771720[outlook.com]
GIdentifiers = GIdentifiers or {}
-- -----------------------------------------------------------------------------
-- src/events.gid
-- -----------------------------------------------------------------------------
---已改变事件
---@param name string 改变的属性、字段等名字
---@param newValue any 改变后的值
---@param oldValue any 改变前的值
GIdentifiers.e_changed = "e_changed"
---完成事件
---@param ... any[] 携带的数据
GIdentifiers.e_complete = "e_complete"
---根节点改变事件
---@param oldRoot Node 之前的根节点
GIdentifiers.e_root_changed = "e_root_changed"
---将要添加到父节点事件
---@param child Node 添加的子节点
GIdentifiers.e_add = "e_add"
---已添加子节点事件
---@param child Node 添加的子节点
GIdentifiers.e_added = "e_added"
---将要移除子节点事件
---@param child Node 移除的子节点
GIdentifiers.e_remove = "e_remove"
---已移除子节点事件
---@param child Node 移除的子节点
GIdentifiers.e_removed = "e_removed"
---指针移入事件
---@param screenX float 屏幕 x 坐标
---@param screenY float 屏幕 y 坐标
---@param screenY PointerEventData 事件原始对象
GIdentifiers.e_enter = "e_enter"
---指针移出事件
---@param screenX float 屏幕 x 坐标
---@param screenY float 屏幕 y 坐标
---@param screenY PointerEventData 事件原始对象
GIdentifiers.e_exit = "e_exit"
---指针按下事件
---@param screenX float 屏幕 x 坐标
---@param screenY float 屏幕 y 坐标
---@param screenY PointerEventData 事件原始对象
GIdentifiers.e_down = "e_down"
---指针释放事件
---@param screenX float 屏幕 x 坐标
---@param screenY float 屏幕 y 坐标
---@param screenY PointerEventData 事件原始对象
GIdentifiers.e_up = "e_up"
---指针点击事件
---@param screenX float 屏幕 x 坐标
---@param screenY float 屏幕 y 坐标
---@param screenY PointerEventData 事件原始对象
GIdentifiers.e_click = "e_click"
---指针开始拖拽事件
---@param screenX float 屏幕 x 坐标
---@param screenY float 屏幕 y 坐标
---@param screenY PointerEventData 事件原始对象
GIdentifiers.e_drag_begin = "e_drag_begin"
---指针拖拽移动事件
---@param screenX float 屏幕 x 坐标
---@param screenY float 屏幕 y 坐标
---@param screenY PointerEventData 事件原始对象
GIdentifiers.e_drag_move = "e_drag_move"
---指针拖拽结束事件
---@param screenX float 屏幕 x 坐标
---@param screenY float 屏幕 y 坐标
---@param screenY PointerEventData 事件原始对象
GIdentifiers.e_drag_end = "e_drag_end"
---<summary>
---粒子结束时事件
---</summary>
GIdentifiers.e_particle_complete = "e_particle_complete"
-- -----------------------------------------------------------------------------
-- src/module/load/load.gid
-- -----------------------------------------------------------------------------
---<summary>
---按 url 资源名字类型加载资源（字符串、字节数组）
---</summary>
---<para name="url">string 资源地址</para>
---<para name="type">string 资源类型，null 表示按 url 类型加载</para>
---<para name="tryCount">int 加载超时后的重试次数，小于 0 表示无限次数，等于 0 表示不重试</para>
---<para name="tryDelay">int 加载超时后重试间隔时长（单位：毫秒）</para>
---<para name="timeout">int 加载超时时长（单位：毫秒）</para>
---<para name="onRetry">Callback 重试时回调</para>
---<para name="onComplete">Callback 加载完成后回调，参数：string|byte[]|null</para>
---<returns>string 加载 id</returns>
GIdentifiers.ni_load = "ni_load"
---<summary>
---停止加载
---</summary>
---<para name="id">string 加载 id</para>
GIdentifiers.ni_load_stop = "ni_load_stop"
---加载类型：二进制
GIdentifiers.load_type_binary = "binary"
---加载类型：字符串
GIdentifiers.load_type_string = "string"
---加载类型：Texture
GIdentifiers.load_type_texture = "texture"
---加载类型：Sprite
GIdentifiers.load_type_sprite = "sprite"
---加载类型：AudioClip
GIdentifiers.load_type_audioclip = "audioclip"
---加载类型：AssetBundle
GIdentifiers.load_type_assetbundle = "assetbundle"
-- -----------------------------------------------------------------------------
-- src/module/timer/timer.gid
-- -----------------------------------------------------------------------------
---新建定时器
---@param duration number 回调执行间隔（单位：毫秒）
---@param count number 小于等于 0 表示无限次数
---@param onOnce Callback 指定间隔后执行回调，参数：number（实际经过的时长，单位：毫秒），number（当前是第几次执行）
---@param onComplete Callbac 指定次数执行完成后回调
---@return string 定时器 id
GIdentifiers.ni_timer_new = "ni_timer_new"
---暂停定时器
---@param id string 新建定时器时返回的 id
GIdentifiers.ni_timer_pause = "ni_timer_pause"
---继续定时器
---@param id string 新建定时器时返回的 id
GIdentifiers.ni_timer_resume = "ni_timer_resume"
---停止定时器
---@param id string 新建定时器时返回的 id
---@param trigger boolean 是否触发完成回调，默认 false
GIdentifiers.ni_timer_stop = "ni_timer_stop"
---修改定时器速率
---@param id string 新建定时器时返回的 id
---@param rate number 定时器速率，默认 1 表示恢复正常速率
GIdentifiers.ni_timer_rate = "ni_timer_rate"
-- -----------------------------------------------------------------------------
-- src/module/tween/tween.gid
-- -----------------------------------------------------------------------------
------创建缓动器
------@param targets ... 缓动目标列表
------@return Tween
GIdentifiers.ni_tween_new = "ni_tween_new"
------停止缓动对象
------@param target any 缓动目标
------@param trigger bool 是否在停止时触发回调，默认 false
------@param toEnd bool 是否在停止时设置属性为结束值，默认 false
GIdentifiers.ni_tween_stop = "ni_tween_stop"
-- -----------------------------------------------------------------------------
-- src/notices.gid
-- -----------------------------------------------------------------------------
---启动通知
GIdentifiers.nb_lauch = "nb_lauch"
---初始化通知
GIdentifiers.nb_initialize = "nb_initialize"
---定时通知
---@param interval double 一帧耗时（单位：毫秒）
GIdentifiers.nb_timer = "nb_timer"
---暂时通知
GIdentifiers.nb_pause = "nb_pause"
---继续通知
GIdentifiers.nb_resume = "nb_resume"

