-- [[ RENZVEX SERVER FINDER UI - MOBILE FRIENDLY (FIXED) ]]
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local PlaceId = game.PlaceId
local LocalPlayer = Players.LocalPlayer

-- Hapus UI lama jika ada
if CoreGui:FindFirstChild("RenzvexServerFinder") then
    CoreGui.RenzvexServerFinder:Destroy()
end

-- Bikin ScreenGui utama
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RenzvexServerFinder"
ScreenGui.Parent = CoreGui
ScreenGui.IgnoreGuiInset = true

-- Frame Utama (Window List Server)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 240)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -120)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- Top Bar
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 35)
TopBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 8)
TopCorner.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.Font = Enum.Font.SourceSansBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Text = "Renzvex Server Finder "
Title.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 2)
CloseBtn.BackgroundTransparency = 1
CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
CloseBtn.TextSize = 16
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.Text = "X"
CloseBtn.Parent = TopBar

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Container List Server (ScrollingFrame)
local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Size = UDim2.new(1, -20, 1, -50)
ScrollingFrame.Position = UDim2.new(0, 10, 0, 45)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.BorderSizePixel = 0
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollingFrame.ScrollBarThickness = 4
ScrollingFrame.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.Parent = ScrollingFrame

-- Fungsi Fetch Server Alternatif yang Lebih Stabil
local function LoadServers()
    -- Bersihkan list lama
    for _, child in ipairs(ScrollingFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end

    local success, result = pcall(function()
        local url = "https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        return HttpService:JSONDecode(game:HttpGet(url))
    end)

    if success and result and result.data then
        local count = 0
        for _, server in ipairs(result.data) do
            if server.id ~= game.JobId and server.playing < server.maxPlayers then
                count = count + 1
                
                -- Baris Server
                local ServerCard = Instance.new("Frame")
                ServerCard.Size = UDim2.new(1, -5, 0, 35)
                ServerCard.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                ServerCard.BorderSizePixel = 0
                ServerCard.Parent = ScrollingFrame

                local CardCorner = Instance.new("UICorner")
                CardCorner.CornerRadius = UDim.new(0, 6)
                CardCorner.Parent = ServerCard

                local InfoLabel = Instance.new("TextLabel")
                InfoLabel.Size = UDim2.new(0.65, 0, 1, 0)
                InfoLabel.Position = UDim2.new(0, 8, 0, 0)
                InfoLabel.BackgroundTransparency = 1
                InfoLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
                InfoLabel.TextSize = 12
                InfoLabel.Font = Enum.Font.SourceSans
                InfoLabel.TextXAlignment = Enum.TextXAlignment.Left
                InfoLabel.Text = "Pemain: " .. server.playing .. "/" .. server.maxPlayers
                InfoLabel.Parent = ServerCard

                local JoinButton = Instance.new("TextButton")
                JoinButton.Size = UDim2.new(0, 75, 0, 25)
                JoinButton.Position = UDim2.new(1, -80, 0.5, -12.5)
                JoinButton.BackgroundColor3 = Color3.fromRGB(0, 170, 100)
                JoinButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                JoinButton.TextSize = 12
                JoinButton.Font = Enum.Font.SourceSansBold
                JoinButton.Text = "JOIN"
                JoinButton.Parent = ServerCard

                local BtnCorner = Instance.new("UICorner")
                BtnCorner.CornerRadius = UDim.new(0, 4)
                BtnCorner.Parent = JoinButton

                JoinButton.MouseButton1Click:Connect(function()
                    JoinButton.Text = "Connecting..."
                    TeleportService:TeleportToPlaceInstance(PlaceId, server.id, LocalPlayer)
                end)
            end
        }
        ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, count * 40)
        
        if count == 0 then
            local EmptyText = Instance.new("TextLabel")
            EmptyText.Size = UDim2.new(1, 0, 0, 30)
            EmptyText.BackgroundTransparency = 1
            EmptyText.TextColor3 = Color3.fromRGB(200, 80, 80)
            EmptyText.TextSize = 12
            EmptyText.Font = Enum.Font.SourceSans
            EmptyText.Text = "Tidak ada server kosong ditemukan."
            EmptyText.Parent = ScrollingFrame
        end
    else
        local ErrText = Instance.new("TextLabel")
        ErrText.Size = UDim2.new(1, 0, 0, 30)
        ErrText.BackgroundTransparency = 1
        ErrText.TextColor3 = Color3.fromRGB(255, 80, 80)
        ErrText.TextSize = 12
        ErrText.Font = Enum.Font.SourceSans
        ErrText.Text = "Gagal memuat API Server (Rate Limited)."
        ErrText.Parent = ScrollingFrame
    end
end

-- Jalankan fungsi load server
LoadServers()
