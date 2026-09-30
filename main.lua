function checkCollision(a, b)
    return a.x < b.x + b.w and
           a.x + a.w > b.x and
           a.y < b.y + b.h and
           a.y + a.h > b.y
end

function loadLevel(n)
    if n == 1 or n > 3 then
        obstacleSpeed = 0
        obstacle.y = 350
        obstacle.h = 150
    elseif n == 2 then
        obstacleSpeed = 150
        obstacle.y = 350
        obstacle.h = 150
    elseif n == 3 then
        obstacleSpeed = 250
        obstacle.y = 350
        obstacle.h = 150
    end
    obstacleVisible = true
    obstacleTimer = 0
end

function love.conf(t)
    t.window.title = "PLATFORM 1"
end

function love.load()
    love.window.setMode(800, 600)
    love.window.setTitle("PLATFORM 1")

    font = love.graphics.newFont("JetBrainsMono.ttf", 64)
    fontStar = love.graphics.newFont("JetBrainsMono.ttf", 18)

    player = {
    x = 100,
    y = 435,
    w = 40,
    h = 60,
    speedX = 0,
    speedY = 0,
    inFloor = false
}
    floorX = 0
    floorY = 500
    floorWidth = 800
    floorHeight = 100
    obstacle = {
    x = 400,
    y = 350,
    w = 100,
    h = 150,
}
    star = {
    x = 450,
    y = 280,
    w = 30,
    h = 30,
    collected = false
}

    gravity = 1100
    jump = -600
    speedWalk = 300
    obstacleSpeed = 0
    platformNumber = 1
    obstacleTimer = 0
    obstacleVisible = true
end

function love.update(dt)
    oldY = player.y

    player.speedY = player.speedY + gravity * dt
    player.y = player.y + player.speedY * dt

    if player.y + player.h > floorY then
        player.y = floorY - player.h
        player.speedY = 0
        player.inFloor = true
    else
        player.inFloor = false
    end

    if obstacleSpeed ~= 0 then

    obstacle.y = obstacle.y + obstacleSpeed * dt
    obstacle.h = obstacle.h - obstacleSpeed * dt

    if obstacle.y < 300 then
    obstacle.y = 300
    obstacle.h = floorY - 300
    obstacleSpeed = -obstacleSpeed
end

    if obstacle.y >= floorY then
    obstacle.y = floorY
    obstacle.h = 0
    obstacleSpeed = 0
    obstacleVisible = false
    obstacleTimer = 0
end
end

    if player.y + player.h >= obstacle.y - 5 and
       player.y + player.h <= obstacle.y + 20 and
       player.x + player.w > obstacle.x and
       player.x < obstacle.x + obstacle.w then
        player.y = obstacle.y - player.h
        player.speedY = 0
        player.inFloor = true
end

    if not obstacleVisible then
    obstacleTimer = obstacleTimer + dt
    if obstacleTimer >= 2 then
        obstacleVisible = true
        obstacleSpeed = -150
    end
end

    if checkCollision(player, obstacle) and obstacleVisible and oldY + player.h <= obstacle.y and platformNumber > 0 then
    player.y = obstacle.y - player.h
    player.speedY = 0
    player.inFloor = true
end

    oldX = player.x

    if love.keyboard.isDown("left") or love.keyboard.isDown("a") then
    player.x = player.x - speedWalk * dt
    end

    if love.keyboard.isDown("right") or love.keyboard.isDown("d") then
        player.x = player.x + speedWalk * dt
    end

    if checkCollision(player, obstacle) and obstacleVisible and oldX + player.w <= obstacle.x and platformNumber > 0 then
    player.x = obstacle.x - player.w
end

    if checkCollision(player, obstacle) and obstacleVisible and oldX >= obstacle.x + obstacle.w and platformNumber > 0  then
    player.x = obstacle.x + obstacle.w
end

    local oldLocalX = 100

    if player.x + player.w > 800 and not star.collected then
    player.x = 800 - player.w
end

    if player.x > 800 and star.collected then
        player.x = oldLocalX 
        platformNumber = platformNumber + 1
        star.collected = false
        loadLevel(platformNumber)
        obstacle.y = floorY - obstacle.h
        obstacleVisible = true
        obstacleTimer = 0
    end

    if player.x < 0 then
        player.x = 750
        platformNumber = platformNumber - 1
        star.collected = false
        loadLevel(platformNumber)
        obstacle.y = 350
        obstacle.h = 150
        obstacleVisible = true
        obstacleTimer = 0
    end

    if not star.collected and checkCollision(player, star) then
    star.collected = true
end
end

function love.keypressed(key)
    if (key == "space" or key == "up" or key == "w") and player.inFloor then
        player.speedY = jump
    end
end

function love.draw()

    love.graphics.clear(0.4, 0.4, 0.4)

    love.graphics.setFont(font)

    love.graphics.setColor(1, 0, 0, 0.8)
    love.graphics.print(string.format("PLATFORM %d", platformNumber), 250, 60)

    love.graphics.setColor(0, 0, 0)

    local px = player.x + player.w / 2
    local py = player.y
    
    love.graphics.circle("fill", px, py + 12, 12) -- head
    love.graphics.setLineWidth(3)
    love.graphics.line(px, py + 24, px, py + 42) -- body
    love.graphics.line(px - 15, py + 30, px + 15, py + 30) -- arms
    love.graphics.line(px, py + 42, player.x, py + player.h) -- left leg
    love.graphics.line(px, py + 42, player.x + player.w, py + player.h) -- right leg

    if platformNumber > 0 and obstacleVisible then
    love.graphics.rectangle("fill", obstacle.x, obstacle.y, obstacle.w, obstacle.h)
    end

    if platformNumber > 0 and not star.collected then
    love.graphics.setColor(1, 0.84, 0)
    
    love.graphics.polygon("fill",
    star.x + star.w/2, star.y,
    star.x + star.w,   star.y + star.h/2,
    star.x + star.w/2, star.y + star.h,
    star.x,            star.y + star.h/2
)
    end

    if platformNumber > 0 and star.collected then
        love.graphics.setFont(fontStar)
        love.graphics.setColor(1, 0.84, 0)
        love.graphics.print("Star Collected!", 50, 50)
    end

    if platformNumber < 1 then
        love.graphics.setFont(fontStar)
        love.graphics.setColor(1, 0, 0)
        love.graphics.print("WHERE ARE YOU GOING?", 150, 200)
    end

    if platformNumber < 1 and star.collected then
        love.graphics.setFont(fontStar)
        love.graphics.setColor(1, 0.84, 0)
        love.graphics.print("Invisible Star Collected!", 50, 50)
    end

    love.graphics.setColor(0, 0, 0)

    love.graphics.rectangle("fill", floorX, floorY, floorWidth, floorHeight)

end