该项目为 lua 封装库，所有的功能都在 xx 域空间内，常用的功能有：  
    1 核心部分：  
        1.1 xx.newUID() 获取一个运行时唯一字符串标识  
        1.2 xx.Class 定义类：local NewClass = xx.Class("NewClass"[, BaseClass])  
            1.2.1 Class.getter 获取实例属性值（直接返回缓存的值，不会调用类方法 getter）  
            1.2.2 Class.setter 设置实例属性值（直接缓存属性的值，不会调用类方法 setter）  
            1.2.3 Class.isClass 判断指定对象是否是类型  
            1.2.4 Class.isInstance 判断指定对象是否是实例  
            1.2.5 Class.getClass 通过类名获取类型  
            1.2.6 Class.instanceOf 判断指定对象是否是指定类型的实例，等价于 xx.instanceOf  
            1.2.7 可重载的方法  
                1.2.7.1 getter 获取实例属性时调用该方法，如：local name = instance.name = "xx"  
                1.2.7.2 setter 设置实例属性时调用该方法，如：instance.name = "xx"  
                1.2.7.3 call 将实例当作方法调用时调用该方法，如：instance("xx")  
                1.2.7.4 add 两个实例相加时调用该方法，相当于重载加号（+），如：instance1 + instance2  
                1.2.7.5 sub 两个实例相减时调用该方法，相当于重载减号（-），如：instance1 - instance2  
                1.2.7.6 equalTo 两个实例相比较时调用该方法，相当于重载等于（==），如：instance1 == instance2  
                1.2.7.7 lessThan 两个实例相比较时调用该方法，相当于重载小于（<），如：instance1 < instance2  
                1.2.7.8 lessEqual 两个实例相比较时调用该方法，相当于重载小于等于（<>=），如：instance1 <= instance2  
                1.2.7.9 toString 在 print 实例时调用该方法转换为字符串打印，如：print(instance)  
                1.2.7.10 ctor 实例构造时调用，先调用父类该方法（该方法执行时无法访问子类重载的方法，或者子类的属性）  
                1.2.7.11 ctored 实例构造完成时调用，先调用子类该方法（该方法执行时可以正常访问所有属性和方法）  
        1.3 xx.ObjectEx 基类，由 Class 创建的所有类都默认继承 xx.ObjectEx  
            1.3.1 uid 所有的实例对象都有一个唯一的字符串标识  
            1.3.2 onDynamicChanged 在属性发生改变时调用该方法(该方法执行时属性值已更新)，会依次传入：属性名，新的值，旧的值  
        1.4 类型判断封装（详细说明请查看代码注释 src/core/Extensions.lua）  
            xx.isNil  
            xx.isBoolean  
            xx.isNumber  
            xx.isString  
            xx.isFunction  
            xx.isTable  
            xx.isUserdata  
            xx.isThread  
        1.5 表的封装（详细说明请查看代码注释 src/core/Extensions.lua）  
            xx.tableClear  
            xx.tableClone  
            xx.tableMerge  
            xx.tableCount  
            xx.tableKeys  
            xx.tableValues  
        1.6 数组的封装（详细说明请查看代码注释 src/core/Extensions.lua）  
            xx.arrayClear  
            xx.arrayCount  
            xx.arrayInsert  
            xx.arrayInsertASC  
            xx.arrayRemove  
            xx.arrayRemoveAt  
            xx.arrayPush  
            xx.arrayPop  
            xx.arrayUnshift  
            xx.arrayIndexOf  
            xx.arrayLastIndexOf  
            xx.arrayContains  
            xx.arraySlice  
            xx.arrayMerge  
    2 工具类部分  
        2.1 xx.JSON  
            2.1.1 xx.JSON.toString 将任意非 nil 数据转换成 json 格式的字符串  
            2.1.2 xx.JSON.toJSON 将 json 格式的字符串转换成 table 对象  
        2.2 单例  
            2.2.1 xx.addInstance 将实例作为单例缓存起来，可使用实例类名访问  
            2.2.2 xx.delInstance 删除已缓存的类名对应的实例  
            2.2.3 xx.getInstance 通过类名获取已缓存的实例，如果未缓存，会自动构建一个实例并缓存起来  
    3 Protobuf  
        3.1 xx.Bit 二进制转换  
            3.1.1 xx.Bit.intBits 将数值按整数转换为指定位数的二进制格式  
            3.1.2 xx.Bit.decimalBits 将数值按浮点数转换为指定位数的二进制格式（只支持 32 和 64 位）  
            3.1.3 xx.Bit.number 将二进制格式数组按整数转换为数值(统一 64 位 int)  
            3.1.4 xx.Bit.decimal 将二进制格式数组按浮点数转换为数值(float, double)  
            3.1.5 xx.Bit.int 将 lua number 按整数格式以指定位数转换为数值(int)  
            3.1.6 xx.Bit.uint 将 lua number 按整数格式以指定位数转换为数值(uint)  
            3.1.7 xx.Bit.bitsNOT 将二进制格式数组按位取反  
            3.1.8 xx.Bit.bitsAND 将二进制格式数组按位与  
            3.1.9 xx.Bit.bitsOR 将二进制格式数组按位或  
            3.1.10 xx.Bit.bitsXOR 将二进制格式数组按位异或  
            3.1.11 xx.Bit.bitsRotate 将二进制格式数组循环位移  
            3.1.12 xx.Bit.bitsShift 将二进制格式数组逻辑位移  
            3.1.13 xx.Bit.bitsAShift 将二进制格式数组算术位移  
            3.1.14 xx.Bit.bnot 将 lua number 按位取反  
            3.1.14 xx.Bit.band 将 lua number 按位与  
            3.1.14 xx.Bit.bor 将 lua number 按位或  
            3.1.14 xx.Bit.bxor 将 lua number 按位异或  
            3.1.14 xx.Bit.rotate 将 lua number 循环位移  
            3.1.14 xx.Bit.shift 将 lua number 逻辑位移  
            3.1.14 xx.Bit.ashift 将 lua number 算术位移  
        3.2 xx.Protobuf 编码解码  
            3.2.1 xx.Protobuf.parse 解析 proto 配置文件  
            3.2.2 xx.Protobuf.decode 解码  
            3.2.3 xx.Protobuf.encode 编码  
    4 Promise  
        4.1 xx.Promise:resolve 完成异步  
        4.2 xx.Promise:reject 拒绝异步  
        4.3 xx.Promise:cancel 取消异步（吃掉错误）  
        4.4 xx.Promise:next 结束后回调  
            4.4.1 onResolve 以返回数据作为完成数据，error 报错为拒绝原因  
            4.4.2 onReject 以返回数据作为完成数据，error 报错为拒绝原因  
        4.5 xx.Promise:catch 等价于 next(nil,onReject)  
        4.6 xx.Promise:finally 无论完成还是拒绝都会回调（忽略回调的返回数据和 error）  
        4.7 xx.Promise.all 指定异步对象全部变成完成态，或者其中一个变成拒绝态时结束  
        4.8 xx.Promise.race 指定异步对象其中一个变成完成态或者拒绝态时结束  
        4.9 xx.Promise.asyncLoop 帧循环驱动异步（需要在帧循环中调用该方法）  
        4.10 xx.Promise.async 在新协程中调用指定方法，以返回数据作为完成数据，error 报错为拒绝原因【等价于 xx.async】  
        4.11 xx.Promise.await 等待异步完成，返回数据最后一个参数为 boolean 值，true 表示 resolved，false 表示 rejected（不能在主线程中调用）【等价于 xx.await】  
        4.12 async 全局方法，等价于 xx.Promise.async（可使用 lua 特性：async {function(...) xxx end, caller, ...}）  
        4.13 await 全局方法，等价于 xx.Promise.await（可使用 lua 特性：await {promise}）  
    5 Callback 回调方法的封装  
        5.1 xx.Callback(function(...) xxx end, caller, ...) 封装回调方法，经常用于类方法或者需要缓存参数时  
        5.2 xx.Callback:call(...) 直接将实例当作方法调用即可触发回调，如：callback(...)  
    6 Signal 信号（简单版事件派发器，不用指定事件类型，一个信号实例即代表一个事件类型，比如点击信号、登录成功信号等）  
        6.1 xx.Signal:addListener 添加监听  
        6.2 xx.Signal:once 添加监听，在触发后移除  
        6.3 xx.Signal:removeListener 移除监听  
        6.4 xx.Signal:hasListener 判断是否有指定监听  
        6.5 xx.Signal:wait 返回一个 Promise，可用于等待信号触发  
        6.6 xx.Signal:removeWait 取消所有 Promise  
        6.7 xx.Signal:call 直接将实例当作方法调用即可触发信号，如：singal(...)  
    7 EventDispatcher 事件派发器的封装  
        7.1 xx.EventDispatcher:addEventListener 添加事件类型监听  
        7.2 xx.EventDispatcher:once 添加事件类型监听，事件派发后移除  
        7.3 xx.EventDispatcher:removeEventListener 移除事件类型监听  
        7.4 xx.EventDispatcher:hasEventListener 判断是否有指定事件类型的监听  
        7.5 xx.EventDispatcher:wait 返回一个事件类型对应的 Promise，可用于等待事件类型派发  
        7.6 xx.EventDispatcher:removeWait 取消事件类型对应的所有 Promise  
        7.7 xx.EventDispatcher:hasWait 判断是否有指定事件类型的 Promise  
        7.8 xx.EventDispatcher:call 直接将实例当作方法调用即可派发事件类型，如：eventDispatcher(eventType, ...)  
    8 Node:EventDispatcher 树形结构的节点，继承自事件派发器，实现事件冒泡  
        8.1 xx.Node.root 树形结构根节点  
        8.2 xx.Node.parent 父节点  
        8.3 xx.Node.numChildren 子节点数量  
        8.4 xx.Node:addChild 添加子节点  
        8.5 xx.Node:addChildAt 添加子节点到指定索引  
        8.6 xx.Node:removeChild 移除子节点  
        8.7 xx.Node:removeChildAt 移除指定索引的子节点  
        8.8 xx.Node:removeChildren 移除多个子节点  
        8.9 xx.Node:setChildIndex 修改子节点索引  
        8.10 xx.Node:getChildIndex 获取子节点索引  
        8.11 xx.Node:getChildAt 获取指定索引的子节点  
        8.12 xx.Node:removeFromParent 从父节点移除  
    9 Framework 项目框架类，实现了模块与状态机  
        9.1 模块（用法可参考 src/module/timer/Mtimer.lua）  
            9.1.1 xx.Framework.priority 设置模块优先级  
            9.1.2 xx.Framework.register 注册模块  
            9.1.3 xx.Framework.unregister 注销模块  
            9.1.4 xx.Framework.addNotices 添加通知监听  
            9.1.5 xx.Framework.removeNotices 移除通知监听  
            9.1.6 xx.Framework.notify 派发通知【等价于 xx.notify】  
            9.1.7 xx.Framework.notifyAsync 派发异步通知，按模块优先级顺序执行异步接口【等价于 xx.notifyAsync】（异步接口必须在异步结束时调用 self:finishModule）  
            9.1.8 xx.Framework:finishModule 异步接口需要调用该方法结束当前异步，需要透传接口参数  
            9.1.9 xx.Framework:onNotice 通知监听回调，需要根据传入的通知类型区分接口调用  
        9.2 状态机  
            9.2.1 xx.Framework.parent 父状态  
            9.2.2 xx.Framework:getContext 获取状态机中缓存的数据  
            9.2.3 xx.Framework:setContext 缓存数据到状态机中  
            9.2.4 xx.Framework:clearContext 清除状态机中所有缓存的数据  
            9.2.5 xx.Framework:addState 添加子状态  
            9.2.6 xx.Framework:removeState 移除子状态  
            9.2.7 xx.Framework:removeFromParent 从父状态移除  
            9.2.8 xx.Framework:toState 跳转子状态  
            9.2.9 xx.Framework:getAlias 根据子状态 uid 获取别名  
            9.2.10 xx.Framework:getState 根据子状态 uid 或者别名获取子状态实例  
            9.2.11 xx.Framework:construct 构造状态  
            9.2.12 xx.Framework:focus 进入状态（切换到当前状态）  
            9.2.13 xx.Framework:activate 激活状态（从后台转到前台）  
            9.2.14 xx.Framework:deactivate 失效状态（从前台转到后台）  
            9.2.15 xx.Framework:defocus 离开状态（切换到兄弟状态）  
            9.2.16 xx.Framework:destruct 析构状态  
            9.2.17 xx.Framework:finishState 结束状态  
            9.2.18 xx.Framework:onChildComplete 有子状态结束时回调  
            9.2.19 xx.Framework:onConstruct 构造时回调  
            9.2.20 xx.Framework:onFocus 进入时回调（从兄弟状态跳转到当前状态时）  
            9.2.21 xx.Framework:onActivate 激活时回调  
            9.2.22 xx.Framework:onDeactivate 失效时回调  
            9.2.23 xx.Framework:onDefocus 离开时回调（从当前状态跳转到兄弟状态时）  
            9.2.24 xx.Framework:onDestruct 析构时回调  
