local sounds = {
    pivot_attach = love.audio.newSource("assets/sounds/pivot_attach.wav", "static"),
    slingshot_attach = love.audio.newSource("assets/sounds/slingshot_attach.wav", "static"),
    jump = love.audio.newSource("assets/sounds/jump.wav", "static"),
    SR20DET = love.audio.newSource("assets/sounds/SR20DET.wav", "static"),
    platform_fall = love.audio.newSource("assets/sounds/platform_fall.wav", "static"),
    slash = love.audio.newSource("assets/sounds/slash.wav", "static"),
    star_caught = love.audio.newSource("assets/sounds/star_caught.wav", "static"),
    star_not_caught = love.audio.newSource("assets/sounds/star_not_caught.wav", "static")
}

sounds.pivot_attach:setVolume(0.5)
sounds.slingshot_attach:setVolume(0.5)
sounds.jump:setVolume(0.5)
sounds.SR20DET:setVolume(0.1)
sounds.platform_fall:setVolume(1)
sounds.slash:setVolume(0.6)
sounds.star_caught:setVolume(0.7)
sounds.star_not_caught:setVolume(0.8)

return sounds