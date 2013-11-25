------------------------------------------------------------------
-----------------   includes and basic setup   -------------------
------------------------------------------------------------------
local Cos   = math.cos
local Sin   = math.sin
local Sqr   = math.sqrt
local clearedEnemies = false
local widget = require( "widget" )
local StickLib   = require("lib_analog_stick")
local physics = require("physics")
physics.start()
physics.setGravity( 0, 0 ) 

system.activate("multitouch")

--no more status bar
display.setStatusBar( display.HiddenStatusBar )

local gameLayer    = display.newGroup()
local bulletsLayer = display.newGroup()
local enemyLayer = display.newGroup()
--local objectLayer = display.newGroup()



------------------------------------------------------------------
----------------------   setting up music   ----------------------
------------------------------------------------------------------
local bgMusic = audio.loadStream("musicTrack.mp3")
local deathSound = audio.loadStream("died.wav")
local bgMusicChannel = audio.play( bgMusic, { channel=1, loops=-1, fadein=5000 }  ) 
--audio.setVolume( 0.5 )

------------------------------------------------------------------
-------------------------   screen dims   ------------------------
------------------------------------------------------------------


local centerX = display.contentCenterX
local centerY = display.contentCenterY

local toRemove = {}

local gameOverPic = display.newImage( "gameOver.png", centerX , centerY -150, true )
gameOverPic.isVisible = false

local W = display.contentWidth
local H = display.contentHeight
local gameIsActive = true
local fireBullet= false

-----------------------------------------------------------------
--------------------------   INFO BAR   -------------------------
-----------------------------------------------------------------


--score
local scorePic = display.newImage( "scorePic.png", centerX -30 , H-40 , true )
local score = 0
local scoreText = display.newText( score, centerX + 30 , H -40 , native.systemFont, 50 )
scoreText:setFillColor( 1, 0, 0 )



--lives
local heartCount = display.newImage( "plusSign.png", 3/4*W -30 , H-40 , true )
local lives = 3
local livesText = display.newText( lives, 3/4*W+30 , H -40 , native.systemFont, 50 )
livesText:setFillColor( 1, 0, 0 )


--states how many bombs are left
local bombs=3
local myText = display.newText( bombs, W/2 -190 , H -40 , native.systemFont, 50 )
myText:setFillColor( 1, 0, 0 )


local boomNoise = audio.loadSound("bombNoise.wav")
local function nukeEm( event )

    if ( "ended" == event.phase and bombs >= 1) then
        print( "Button was pressed and released." )
        audio.play( boomNoise )
        bombs= bombs - 1
        myText.text= bombs
        clearedEnemies=true
    end
end

local nukeThem = widget.newButton
{
    width = 60,
    height = 60,
    defaultFile = "radioActive.png",
    --overFile = "buttonOver.png", change
    onEvent = nukeEm
}
nukeThem.x= centerX/2
nukeThem.y= H-40



local function resetGame( event )

    gameIsActive=true
    print "calling "
    lives=3
    livesText.text = lives
    gameOverPic.isVisible = false
    

end
local chooseYes = widget.newButton
{
    width = centerX,
    height = centerY - 100,
    defaultFile = "yesPic.png",
    onEvent = resetGame
    
    
}

chooseYes.x= centerX
chooseYes.y= H-200
chooseYes.isVisible = false




------------------------------------------------------------------
--------------------   collision detection   ---------------------
------------------------------------------------------------------

local function onCollision(self, event)
    -- Bullet hit enemy
    


    if(event.phase == "began") then

        if self.name == "bullet" and event.other.name == "enemy" and gameIsActive then
            -- Increase score
            score = score + 1
            scoreText.text = score
            -- Play Sound
            --audio.play(plasmaShot)

            --delete later
            table.insert(toRemove, event.other)

        -- Player collision - GAME OVER
        elseif self.name == "ship" and event.other.name == "enemy" then
            audio.play(deathSound)
            print "Ouch!!!!"
            clearedEnemies= true
            
            if (lives == 0) then
                print "gameOver"
                gameIsActive = false
                gameOverPic.isVisible = true
                chooseYes.isVisible = true
            else
                
                
                
            
                local translateObject = function()
                    self.x = centerX
                    self.y = centerY
                    lives = lives - 1
                    livesText.text = lives
                end
            timer.performWithDelay(1,translateObject,1)
            end
        elseif self.name == "ship" and event.other.name == "heart" then
        	print "Hurryay got health!"
            lives =lives + 1
            livesText.text = lives
            table.insert(toRemove, event.other)
        elseif self.name == "enemy" and event.other.name == "heart" then
            table.insert(toRemove, event.other)
        elseif self.name == "asteroid" and event.other.name == "enemy" then
            table.insert(toRemove, event.other)
        elseif self.name == "ship" and event.other.name == "asteroid" then
            audio.play(deathSound)
            print "Ouch!!!!"
            clearedEnemies= true
            
            if (lives == 0) then
                print "gameOver"
                gameIsActive = false
                gameOverPic.isVisible = true
                chooseYes.isVisible = true
            else
                
                
                
            
                local translateObject = function()
                    self.x = centerX
                    self.y = centerY
                    lives = lives - 1
                    livesText.text = lives
                end
            timer.performWithDelay(1,translateObject,1)
            
     
        end
    end

    end
end


------------------------------------------------------- objects

local bg = display.newImage( "space.png", centerX, centerY, true )
gameLayer:insert(bg)




gameLayer:insert(bulletsLayer)
gameLayer:insert(enemyLayer)
-----------------------------------------------------------------
-----------------------   DEFINING ENEMIES   --------------------
-----------------------------------------------------------------


local asteroid = display.newImage( "asteroid.png", W -200 , 200, true )
gameLayer:insert(asteroid)
physics.addBody(asteroid, "dynamic", {bounce = .3})
asteroid.name= "asteroid"

transition.to( asteroid, { rotation = asteroid.rotation-360, time=200000, onComplete=spinImage } )

local enemy1 = display.newImage( "enemy2.png", centerX , 200, true )
physics.addBody(enemy1, "dynamic", {bounce = .3})
enemy1.name = "enemy"
enemyLayer:insert(enemy1)

local enemy2 = display.newImage( "enemyAng3.png", 300 , 200, true )
physics.addBody( enemy2, "dynamic", { density=3.0, friction=0.5, bounce=0.3 } )
enemy2.name = "enemy"
enemyLayer:insert(enemy2)


-----------------------------------------------------------------
---------------------   setting up ship   -----------------------
-----------------------------------------------------------------



local ship = display.newImage( "ship.png",   centerX , centerY, true )
--physics.addBody( ship, "kinematic", { density=3.0, friction=0.5, bounce=0.3 } )
physics.addBody(ship, "kinematic", {bounce = 0})

ship.name = "ship"
ship.shootThem = true
gameLayer:insert(ship)

ship.collision = onCollision
ship:addEventListener( "collision", ship )




-----------------------------------------------------------------
-----------------------   RUNTIME EVENTS   ----------------------
-----------------------------------------------------------------

local counter=0

local function gameLoop(event)

    

    counter = counter + 1
    for i = 1, #toRemove do
            toRemove[i].parent:remove(toRemove[i])
            toRemove[i] = nil
    end
    if(clearedEnemies == true) then
        for i=enemyLayer.numChildren,1,-1 do
            enemyLayer[i].parent:remove(enemyLayer[i]);
        end
        clearedEnemies = false
    end

    if (gameIsActive == true  ) then
       

        chooseYes.isVisible = false
    -- add enemy randomy
    -- change or add condition to counter------------------------------ for counting down
    if counter% 50 == math.random(0, 50) then
        -- Randomly position it on the top of the screen
        local enemy = display.newImage("enemy3Happy.png")
        enemy.x = ship.x + math.random(-500 , 500)
        enemy.y = ship.y + Sqr(500*500 - enemy.x*enemy.x)

        physics.addBody(enemy, "dynamic", {bounce = 0})
        enemy.name = "enemy"
        enemyLayer:insert(enemy)
        transition.to(enemy, {time = 2000, y = ship.y , x= ship.x , transition=easing.inQuad }) 
        
    end

    --spawn hearts
    if counter% 1800 == 30 then
        xLoc = math.random(0, W)
        yLoc= math.random(0 , H)
        local heart = display.newImage( "heart.png" , xLoc, yLoc , true )
        physics.addBody(heart, "dynamic", {bounce = .3})
        heart.name = "heart"
        gameLayer:insert(heart)
        
    end

    
    -- Spawn a bullet
        if rightStick:getFire() == true then
            local bullet = display.newImage("bullet.png")
            bullet.x = ship.x
            bullet.y = ship.y
            --creating
            physics.addBody(bullet, "dynamic", {bounce = 0})
            bullet.name = "bullet"
            -- add collision detection
            bullet.collision = onCollision
            bullet:addEventListener("collision", bullet)
            bulletsLayer:insert(bullet)
            bullet.rotation = rightStick:getAngle()
            --print  (rightStick:getAngle())
            local xS = rightStick:getXX()
            local yS = rightStick:getYY()
            local distance = Sqr(xS*xS + yS*yS)
            local newX= ship.x + xS/distance*2000
            local newY= ship.y + yS/distance *2000

            -- handling destruction and moving
            transition.to(bullet, {time = 1000, y = newY , x = newX,
                onComplete = function(self) self.parent:remove(self); self = nil; end
            })
            

        end


else
    
end


end

Runtime:addEventListener("enterFrame", gameLoop)


-----------------------------------------------------------------
---------------------   CREATE ANALOG STICK   -------------------
-----------------------------------------------------------------

--left stick
leftStick = StickLib.NewStick( 
        {
        x             = 70,
        y             = H - 70,
        thumbSize     = 60,
        borderSize    = 50, 
        snapBackSpeed = .55, 
        } )

local function leftStickEvent( event )
        
        -- MOVE THE SHIP
        leftStick:move(ship, 10.0, true)
 
        -- SHOW STICK INFO
		--Text.text = "ANGLE = "..leftStick:getAngle().."   PERCENT = "..math.ceil(leftStick:getPercent()*100).."%"        
end
 
Runtime:addEventListener( "enterFrame", leftStickEvent )

-- right stick
rightStick = StickLib.NewStick( 
        {
        --plasmaShotSound = plasmaShot, 
        x             = W-70,
        y             = H-70,
        thumbSize     = 60,
        borderSize    = 50, 
        snapBackSpeed = .55, 
        } )

local function rightStickEvent( event )
        
        -- MOVE THE SHIP
        rightStick:shoot(ship, 7.0, true)
 
        -- SHOW STICK INFO
	--Text.text =" Loc.x: ".. ship.x.. "  ANGLE = "..rightStick:getAngle()..  "PERCENT= " ..math.ceil(rightStick:getPercent()*100).."%"        
		
end

Runtime:addEventListener( "enterFrame", rightStickEvent )










