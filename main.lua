function love.load()
    local __func__ = "love.load()"

    love.window.setTitle("Love2D Snake")

    state = nil
    speed = 0.1
    lastMoveTime = 0
    score = 0
    collistion = false
    
    windowWidth, windowHeight = love.graphics.getDimensions()
    log(__func__, "windowWidth", windowWidth)
    log(__func__, "windowHeight", windowHeight)

    boardSize = {
        x = 40,
        y = 30,
    }
    cellSize = {
        x = windowWidth / boardSize.x,
        y = windowHeight / boardSize.y
    }
    log(__func__, "cellSize.x", cellSize.x)
    log(__func__, "cellSize.y", cellSize.y)

    snake = {
        direction = nil,
        x = math.random(cellSize.x),
        y = math.random(cellSize.y),
        tail = {}
    }
    food = {
        x = math.random(cellSize.x),
        y = math.random(cellSize.y)
    }
end

function love.keypressed(key)
    local __func__ = string.format("love.keypressed(%s)", key)

    if key == "escape" then
        love.event.quit()
    elseif key == "p" and state == "running" then
        state = (state == "paused") and "running" or "paused"
    elseif key == "space" and state == nil then
        state = "running"
    elseif key == "f11" then
        if love.window.getFullscreen() == false then
            love.window.setFullscreen(true)
            windowWidth, windowHeight = love.graphics.getDimensions()
            cellSize = {
                x = windowWidth / boardSize.x,
                y = windowHeight / boardSize.y
            }
        else
            love.window.setFullscreen(false)
            windowWidth, windowHeight = love.graphics.getDimensions()
            cellSize = {
                x = windowWidth / boardSize.x,
                y = windowHeight / boardSize.y
            }
        end
    end

    if state == "running" then
        if snake.direction ~= "down" and (key == "up" or key == "w") then
            snake.direction = "up"
        elseif snake.direction ~= "up" and (key == "down" or key == "s") then
            snake.direction = "down"
        elseif snake.direction ~= "right" and (key == "left" or key == "a") then
            snake.direction = "left"
        elseif snake.direction ~= "left" and (key == "right" or key == "d") then
            snake.direction = "right"
        end
    end
end

function love.update(dt)
    local __func__ = string.format("love.update(%s)", dt)

    if(state == "running") then
        lastMoveTime = lastMoveTime + dt

        while lastMoveTime >= speed do
            -- Movement
            if snake.direction == "up" then
                snake.y = snake.y - 1
            elseif snake.direction == "down" then
                snake.y = snake.y + 1
            elseif snake.direction == "left" then
                snake.x = snake.x - 1
            elseif snake.direction == "right" then
                snake.x = snake.x + 1
            end

            -- Food
            if snake.x == food.x and snake.y == food.y then
                score = score + 1

                food.x = math.random(boardSize.x)
                food.y = math.random(boardSize.y)

                -- increase difficulty
                checkDifficulty(score, speed)

                if snake.direction == "up" then
                    table.insert(snake.tail, {x = snake.x, y = snake.y + 1})
                elseif snake.direction == "down" then
                    table.insert(snake.tail, {x = snake.x, y = snake.y - 1})
                elseif snake.direction == "left" then
                    table.insert(snake.tail, {x = snake.x + 1, y = snake.y})
                elseif snake.direction == "right" then
                    table.insert(snake.tail, {x = snake.x - 1, y = snake.y})
                end
            end

            -- Snake tail logic
            -- Move existing tails
            for i = #snake.tail, 2, -1 do
                snake.tail[i].x, snake.tail[i].y = snake.tail[i - 1].x, snake.tail[i - 1].y
            end

            -- Insert or update the first tail segment
            if #snake.tail == 0 then
                table.insert(snake.tail, {
                    x = snake.x + (snake.direction == "left" and 1 or snake.direction == "right" and -1 or 0),
                    y = snake.y + (snake.direction == "up" and 1 or snake.direction == "down" and -1 or 0)
                })
            else
                snake.tail[1] = {
                    x = snake.x + (snake.direction == "left" and 1 or snake.direction == "right" and -1 or 0),
                    y = snake.y + (snake.direction == "up" and 1 or snake.direction == "down" and -1 or 0)
                }
            end
            

            -- Collision
            for i, segment in ipairs(snake.tail) do
                if i ~= 1 and segment.x == snake.x and segment.y == snake.y then -- fail
                    state = "gameover"
                end
            end

            -- Prevent snake from escaping the board
            snake.x = checkBoundry(snake.x, boardSize.x)
            snake.y = checkBoundry(snake.y, boardSize.y)
        
            lastMoveTime = 0
        end
    end
end

function love.draw()
    local __func__ = "love.draw()"

    if state == "running" then
        
        -- Draw grid
        love.graphics.setColor(255, 0, 0, 0.06)
        for row = 1, boardSize.y do
            for col = 1, boardSize.x do
                local x = (col - 1) * cellSize.x
                local y = (row - 1) * cellSize.y
                love.graphics.rectangle("line", x, y, cellSize.x, cellSize.y)
            end
        end
        love.graphics.reset()
        

        -- Draw apple
        love.graphics.setColor(255, 0, 0)
        love.graphics.rectangle("fill", (food.x - 1) * cellSize.x, (food.y - 1) * cellSize.y, cellSize.x, cellSize.y)
        love.graphics.reset()

        -- Draw snake
        love.graphics.setColor(255, 255, 0)
        love.graphics.rectangle("fill", (snake.x - 1) * cellSize.x, (snake.y - 1) * cellSize.y, cellSize.x, cellSize.y)
        love.graphics.reset()

        -- Draw snake tail
        love.graphics.setColor(51, 51, 0)
        for _, e in ipairs(snake.tail) do
            love.graphics.rectangle("line", (e.x -1) * cellSize.x, (e.y - 1) * cellSize.y, cellSize.x, cellSize.y)
        end
        love.graphics.reset()

        -- Draw score
        love.graphics.setColor(255, 255, 0)
        love.graphics.printf(string.format("Score: %s", score), 0, 0, windowWidth, "center")
        love.graphics.reset()

    elseif state == "gameover" then
        love.graphics.setColor(255, 255, 0)
        love.graphics.printf(string.format("Score: %s", score), 0, 0, windowWidth, "center")
        love.graphics.reset()

        love.graphics.printf("Game over!", 0, windowHeight / 2, windowWidth, "center")

    elseif state == "paused" then
        love.graphics.printf("Press [P] to unpause", 0, windowHeight / 2, windowWidth, "center")

    elseif state == nil then
        love.graphics.printf("Press [SPACE] to begin the game", 0, windowHeight / 2, windowWidth, "center")
        love.graphics.printf("Controls: Press [P] to pause, [ESC] to quit", 0, windowHeight - 200, windowWidth, "center")
    end
end

-- This checks whether or not the snake has escaped the board
function checkBoundry(coord, size)
    if coord > size then
        return 1
    elseif coord <= 0 then
        return size
    else
        return coord
    end
end

-- This increases speed of the game
function checkDifficulty(score, currentSpeed)
    local __func__ = string.format("checkDifficulty(%s, %s)", score, currentSpeed)

    local baseSpeed = 0.1
    local scoreThreshold = 10

    local newSpeed = baseSpeed - math.floor(score / scoreThreshold) * 0.01
    if newSpeed < currentSpeed and newSpeed > 0 then
        log(__func__, "newSpeed", newSpeed)
        speed = newSpeed
    end
end

-- simple logging
function log(__func__, key, value)
    print(string.format("%s: %s = %s", __func__, key, value))
end