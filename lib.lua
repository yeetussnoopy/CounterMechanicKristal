local lib = {}

function lib:init()
    print("Loaded counter library")
    Utils.hook(Encounter, "update", function(orig, self)

    orig(self)
    local activeTP = Kristal.getLibConfig("counter", "activateTP")
    local party = Kristal.getLibConfig("counter", "wholeParty")
    local costTP = Kristal.getLibConfig("counter", "costTP")
    if Game.battle.state == "DEFENDING" and Game.tension > activeTP and Input.pressed("menu") then    
        Game:removeTension(costTP)
        Game.battle:shakeCamera(10)
        Assets.playSound("taunt", 0.5, Utils.random(0.9, 1.1))
        for _,enemy in ipairs(Game.battle:getActiveEnemies()) do
            enemy:statusMessage("damage", 0)
            enemy:setSprite("hurt")
            enemy:statusMessage("msg", "counter")
        end

        Assets.playSound("criticalswing", 2, Utils.random(0.9, 1.1))
        for _,bullet in ipairs(Game.stage:getObjects(Bullet)) do
            bullet.damage = 0
            Game.stage.timer:tween(0.5, bullet, {alpha = 0}, "linear", function()
            bullet:remove()
            end)
        end

        local function taunt(chara)
        local charax1, charay1 = chara:getRelativePos(chara.width/2, chara.height/2)
        local effect = Sprite("effects/taunteffect", charax1, charay1)
        effect:play(0.02, false, onUnlock)
                        effect:setOrigin(0.5, 0.5)
                        effect.layer = chara.layer-1
                        Game.battle:addChild(effect)
        chara:setAnimation("battle/attack")
        Game.battle.timer:after(1, function()
        effect:remove()
        chara:setAnimation("battle/idle")
        end)
        end
        
if party then        
        for _,chara in ipairs(Game.battle.party) do
            taunt(chara)
        end
else
    chara = Game.battle.party[1]
    taunt(chara) 
    end

    Game.battle.timer:after(1, function()
    for _,enemy in ipairs(Game.battle:getActiveEnemies()) do
        enemy:setAnimation("idle")
    end
    Game.battle:setState("ACTIONSELECT")
    end)
    end
    end)
  
end

return lib

