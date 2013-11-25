module (..., package.seeall)

 
local Pi    = math.pi
local Sqr   = math.sqrt
local Rad   = math.rad
local Sin   = math.sin
local Cos   = math.cos
local Ceil  = math.ceil
local Atan2 = math.atan2
local plasmaShot = audio.loadSound("plasmaPistol.wav")
local W = display.contentWidth
local H = display.contentHeight
 
----------------------------------------------------------------
-- FUNCTION: CREATE 
----------------------------------------------------------------
function NewStick( Props )
 
        local Group         = display.newGroup()
        --local plasmaShotSound = Props.plasmaShot
        Group.x             = Props.x
        Group.y             = Props.y
        Group.xx             = Props.x
        Group.yy             = Props.y
        Group.Timer                     = nil
        Group.angle                     = 0
        Group.distance          = 0
        Group.percent           = 0
        Group.fire              = false
        Group.maxDist           = Props.borderSize
        Group.snapBackSpeed = Props.snapBackSpeed ~= nil and Props.snapBackSpeed or .7
 

        Group.Border = display.newImage( "joyStickOuter.png", 0 , 0, true )
        Group:insert(Group.Border)
 

        Group.Thumb = display.newImage( "joyStickInner.png", 0 , 0, true )

        Group.Thumb.x0 = 0
        Group.Thumb.y0 = 0
        Group:insert(Group.Thumb)
 
        ---------------------------------------------
        -- METHOD: DELETE STICK
        ---------------------------------------------
        function Group:delete()
                self.Border    = nil
                self.Thumb     = nil
                if self.Timer ~= nil then timer.cancel(self.Timer); self.Timer = nil end
                self:removeSelf()
        end
        
        ---------------------------------------------
        -- METHOD: MOVE AN OBJECT
        ---------------------------------------------
        function Group:move(Obj, maxSpeed, rotate)
                --if rotate == true then Obj.rotation = self.angle end
                
                Obj.x = Obj.x + Cos( Rad(self.angle-90) ) * (maxSpeed * self.percent) 
                Obj.y = Obj.y + Sin( Rad(self.angle-90) ) * (maxSpeed * self.percent)
                if (Obj.x < 0) then
                    Obj.x = 0
                end
                if (Obj.x > W) then
                    Obj.x = W
                end
                if (Obj.y < 0) then
                    Obj.y = 0
                end
                if (Obj.y > H) then
                    Obj.y = H
                end
        end

        local counter=0
        function Group:shoot(Obj, maxSpeed, rotate )
            if rotate == true then Obj.rotation = self.angle end
            if self.percent > 0 then
                counter= counter +1
                if counter % 8 == 1 then
                    audio.play( plasmaShot )
                    self.fire= true
                    return

                end
            end
            self.fire = false
            
 
        end
        
        ---------------------------------------------
        -- GETTER METHODS
        ---------------------------------------------
        function Group:getDistance() return self.distance    end
        function Group:getFire()     return self.fire        end
        function Group:getPercent () return self.percent     end
        function Group:getAngle   () return Ceil(self.angle) end
        function Group:getXX () return self.xx     end
        function Group:getYY   () return self.yy end
 
        ---------------------------------------------
        -- HANDLER: ON DRAG
        ---------------------------------------------
        Group.onDrag = function ( event )
 
                local T     = event.target -- THUMB
                local S     = T.parent     -- STICK
                local phase = event.phase
                local ex,ey = S:contentToLocal(event.x, event.y)
                      ex = ex - T.x0
                      ey = ey - T.y0
                    
 
                if "began" == phase then
                        if S.Timer ~= nil then timer.cancel(S.Timer); S.Timer = nil end
                        display.getCurrentStage():setFocus( T , event.id )
                        T.isFocus = true
                        -- STORE INITIAL POSITION
                        T.x0 = ex - T.x
                        T.y0 = ey - T.y
                        
 
                elseif T.isFocus then
                    S.xx= ex
                    S.yy= ey
                    --print (ex)
                    --print (ey)
                        if "moved" == phase then
                                -----------
                                S.distance    = Sqr (ex*ex + ey*ey)
                                if S.distance > S.maxDist then S.distance = S.maxDist end
                                S.angle       = ( (Atan2( ex-0,ey-0 )*180 / Pi) - 180 ) * -1
                                S.percent     = S.distance / S.maxDist
                                -----------
                                T.x       = Cos( Rad(S.angle-90) ) * (S.maxDist * S.percent) 
                                T.y       = Sin( Rad(S.angle-90) ) * (S.maxDist * S.percent) 
                        
                        elseif "ended"== phase or "cancelled" == phase then
                                T.x0      = 0
                                T.y0      = 0
                                T.isFocus = false
                                display.getCurrentStage():setFocus( nil )
 
                                S.Timer = timer.performWithDelay( 33, S.onRelease, 0 )
                                S.Timer.MyStick = S
                        end
                end
 
                -- STOP FURTHER PROPAGATION OF TOUCH EVENT!
                return true
 
        end
 
        ---------------------------------------------
        -- HANDLER: ON DRAG RELEASE
        ---------------------------------------------
        Group.onRelease = function( event )
 
                local S = event.source.MyStick
                local T = S.Thumb
 
                local dist = S.distance > S.maxDist and S.maxDist or S.distance
                          dist = dist * S.snapBackSpeed
 
                T.x = Cos( Rad(S.angle-90) ) * dist 
                T.y = Sin( Rad(S.angle-90) ) * dist 
 
                local ex = T.x
                local ey = T.y
                S.xx= ex
                S.yy= ey
                -----------
                S.distance = Sqr (ex*ex + ey*ey)
                if S.distance > S.maxDist then S.distance = S.maxDist end
                S.angle    = ( (Atan2( ex-0,ey-0 )*180 / Pi) - 180 ) * -1
                S.percent  = S.distance / S.maxDist
                -----------
                if S.distance < .5 then
                        S.distance = 0
                        S.percent  = 0
                        T.x            = 0
                        T.y            = 0
                        timer.cancel(S.Timer); S.Timer = nil
                end
 
        end
 
        Group.Thumb:addEventListener( "touch", Group.onDrag )
 
        return Group
 
end