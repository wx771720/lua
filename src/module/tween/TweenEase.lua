---缓动函数
---@alias Ease fun(time:number,begin:number,change:number,duration:number):number

---线性
function xx.easeLinear(time, begin, change, duration)
    return begin + change * time / duration
end

---平方根-以较慢速度开始运动，然后在执行时加快运动速度
function xx.CircularIn(time, begin, change, duration)
    time = time / duration
    return -change * (math.sqrt(1 - time * time) - 1) + begin
end
---平方根-以较快速度开始运动，然后在执行时减慢运动速度
function xx.CircularOut(time, begin, change, duration)
    time = time / duration - 1
    return change * math.sqrt(1 - time * time) + begin
end
---平方根-缓慢地开始运动，进行加速运动，再进行减速
function xx.CircularInOut(time, begin, change, duration)
    time = 2 * time / duration
    if time < 1 then
        return -change / 2 * (math.sqrt(1 - time * time) - 1) + begin
    end
    time = time - 2
    return change / 2 * (math.sqrt(1 - time * time) + 1) + begin
end

---二次-以零速率开始运动，然后在执行时加快运动速度
function xx.QuadraticIn(time, begin, change, duration)
    time = time / duration
    return change * time * time + begin
end
---二次-以较快速度开始运动，然后在执行时减慢运动速度，直至速率为零
function xx.QuadraticOut(time, begin, change, duration)
    time = time / duration
    return -change * time * (time - 2) + begin
end
---二次-开始运动时速率为零，先对运动进行加速，再减速直到速率为零
function xx.QuadraticInOut(time, begin, change, duration)
    time = 2 * time / duration
    if time < 1 then
        return change / 2 * time * time + begin
    end
    time = time - 1
    return -change / 2 * (time * (time - 2) - 1) + begin
end

---三次-以零速率开始运动，然后在执行时加快运动速度
function xx.CubicIn(time, begin, change, duration)
    time = time / duration
    return change * time * time * time + begin
end
---三次-以较快速度开始运动，然后在执行时减慢运动速度，直至速率为零
function xx.CubicOut(time, begin, change, duration)
    time = time / duration - 1
    return change * (time * time * time + 1) + begin
end
---三次-开始运动时速率为零，先对运动进行加速，再减速直到速率为零
function xx.CubicInOut(time, begin, change, duration)
    time = 2 * time / duration
    if time < 1 then
        return change / 2 * time * time * time + begin
    end
    time = time - 2
    return change / 2 * (time * time * time + 2) + begin
end

---四次-以零速率开始运动，然后在执行时加快运动速度
function xx.QuarticIn(time, begin, change, duration)
    time = time / duration
    return change * time * time * time * time + begin
end
---四次-以较快的速度开始运动，然后减慢运行速度，直至速率为零
function xx.QuarticOut(time, begin, change, duration)
    time = time / duration - 1
    return -change * (time * time * time * time - 1) + begin
end
---四次-开始运动时速率为零，先对运动进行加速，再减速直到速率为零
function xx.QuarticInOut(time, begin, change, duration)
    time = 2 * time / duration
    if time < 1 then
        return change / 2 * time * time * time * time + begin
    end
    time = time - 2
    return -change / 2 * (time * time * time * time - 2) + begin
end

---五次-以零速率开始运动，然后在执行时加快运动速度
function xx.QuinticIn(time, begin, change, duration)
    time = time / duration
    return change * time * time * time * time * time + begin
end
---五次-以较快速度开始运动，然后在执行时减慢运动速度，直至速率为零
function xx.QuinticOut(time, begin, change, duration)
    time = time / duration - 1
    return change * (time * time * time * time * time + 1) + begin
end
---五次-开始运动时速率为零，先对运动进行加速，再减速直到速率为零
function xx.QuinticInOut(time, begin, change, duration)
    time = 2 * time / duration
    if time < 1 then
        return change / 2 * time * time * time * time * time + begin
    end
    time = time - 2
    return change / 2 * (time * time * time * time * time + 2) + begin
end

---幂-以较慢速度开始运动，然后在执行时加快运动速度
function xx.ExponentialIn(time, begin, change, duration)
    if 0 == time then
        return begin
    end
    return change * (2 ^ (10 * (time / duration - 1))) + begin
end
---幂-以较快速度开始运动，然后在执行时减慢运动速度
function xx.ExponentialOut(time, begin, change, duration)
    if time == duration then
        return begin + change
    end
    return change * (1 - (2 ^ (-10 * time / duration))) + begin
end
---幂-缓慢地开始运动，进行加速运动，再进行减速
function xx.ExponentialInOut(time, begin, change, duration)
    if 0 == time then
        return begin
    end
    if time == duration then
        return begin + change
    end
    time = 2 * time / duration
    if time < 1 then
        return change / 2 * (2 ^ (10 * (time - 1))) + begin
    end
    time = time - 1
    return change / 2 * (2 - (2 ^ (-10 * time))) + begin
end

---三角函数-以零速率开始运动，然后在执行时加快运动速度
function xx.SineIn(time, begin, change, duration)
    return -change * math.cos(time / duration * (math.pi / 2)) + change + begin
end
---三角函数-以较快速度开始运动，然后在执行时减慢运动速度，直至速率为零
function xx.SineOut(time, begin, change, duration)
    return change * math.sin(time / duration * (math.pi / 2)) + begin
end
---三角函数-开始运动时速率为零，先对运动进行加速，再减速直到速率为零
function xx.SineInOut(time, begin, change, duration)
    return -change / 2 * (math.cos(math.pi * time / duration) - 1) + begin
end

---碰撞反弹-以较慢速度开始回弹运动，然后在执行时加快运动速度
function xx.BounceIn(time, begin, change, duration)
    return change - xx.BounceOut(duration - time, 0, change, duration) + begin
end
---碰撞反弹-以较快速度开始回弹运动，然后在执行时减慢运动速度
function xx.BounceOut(time, begin, change, duration)
    time = time / duration
    if time < (1 / 2.75) then
        return change * (7.5625 * time * time) + begin
    elseif time < (2 / 2.75) then
        time = time - (1.5 / 2.75)
        return change * (7.5625 * time * time + 0.75) + begin
    elseif time < (2.5 / 2.75) then
        time = time - (2.25 / 2.75)
        return change * (7.5625 * time * time + 0.9375) + begin
    end
    time = time - (2.625 / 2.75)
    return change * (7.5625 * time * time + 0.984375) + begin
end
---碰撞反弹-缓慢地开始跳动，进行加速运动，再进行减速
function xx.BounceInOut(time, begin, change, duration)
    if time < duration / 2 then
        return xx.BounceIn(time * 2, 0, change, duration) * 0.5 + begin
    end
    return xx.BounceOut(time * 2 - duration, 0, change, duration) * 0.5 + change * 0.5 + begin
end

local BACK = 1.70158
---过冲-开始时朝后运动，然后反向朝目标移动
function xx.BackIn(time, begin, change, duration)
    time = time / duration
    return change * time * time * ((BACK + 1) * time - BACK) + begin
end
---过冲-开始运动时是朝目标移动，稍微过冲，再倒转方向回来朝着目标
function xx.BackOut(time, begin, change, duration)
    time = time / duration - 1
    return change * (time * time * ((BACK + 1) * time + BACK) + 1) + begin
end
---过冲-开始运动时是朝后跟踪，再倒转方向并朝目标移动，稍微过冲目标，然后再次倒转方向，回来朝目标移动
function xx.BackInOut(time, begin, change, duration)
    local s = BACK
    time = 2 * time / duration
    if time < 1 then
        s = s * 1.525
        return change / 2 * (time * time * ((s + 1) * time - s)) + begin
    end
    time = time - 2
    s = s * 1.525
    return change / 2 * (time * time * ((s + 1) * time + s) + 2) + begin
end

---弹簧-以较慢速度开始运动，然后在执行时加快运动速度
function xx.ElasticIn(time, begin, change, duration)
    if 0 == time then
        return begin
    end
    time = time / duration
    if 1 == time then
        return begin + change
    end

    local p = duration * 0.3
    local s = p / 4

    time = time - 1
    return -(change * (2 ^ (10 * time)) * math.sin((time * duration - s) * (2 * math.pi) / p)) + begin
end
---弹簧-以较快速度开始运动，然后在执行时减慢运动速度
function xx.ElasticOut(time, begin, change, duration)
    if 0 == time then
        return begin
    end
    time = time / duration
    if 1 == time then
        return begin + change
    end

    local p = duration * 0.3
    local s = p / 4

    return change * (2 ^ (-10 * time)) * math.sin((time * duration - s) * (2 * math.pi) / p) + change + begin
end
---弹簧-缓慢地开始运动，进行加速运动，再进行减速
function xx.ElasticInOut(time, begin, change, duration)
    if 0 == time then
        return begin
    end
    time = 2 * time / duration
    if 2 == time then
        return begin + change
    end

    local p = duration * (0.3 * 1.5)
    local s = p / 4
    if time < 1 then
        time = time - 1
        return -0.5 * (change * (2 ^ (10 * time)) * math.sin((time * duration - s) * (2 * math.pi) / p)) + begin
    end
    time = time - 1
    return change * (2 ^ (-10 * time)) * math.sin((time * duration - s) * (2 * math.pi) / p) * 0.5 + change + begin
end
