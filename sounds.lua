local sounds = {
    pivot_attach = love.audio.newSource("assets/sounds/pivot_attach.wav", "static"),
    slingshot_attach = love.audio.newSource("assets/sounds/slingshot_attach.wav", "static"),
    jump = love.audio.newSource("assets/sounds/jump.wav", "static"),
    SR20DET = love.audio.newSource("assets/sounds/SR20DET.wav", "static"),
    platform_fall = love.audio.newSource("assets/sounds/platform_fall.wav", "static"),
}

sounds.pivot_attach:setVolume(0.5)
sounds.slingshot_attach:setVolume(0.5)
sounds.jump:setVolume(0.5)
sounds.SR20DET:setVolume(0.1)
sounds.platform_fall:setVolume(1)



return sounds