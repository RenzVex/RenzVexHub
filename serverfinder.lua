-- [[ RENZVEX SERVER FINDER UI - MOBILE FRIENDLY ]]
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

local PlaceId = game.PlaceId
local JobId = game.JobId

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
MainFrame.Active = true
MainFrame.Draggable = true -- Biar bisa digeser-geser di layar HP
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- Judul Atas
local TitleBar = Instance.new("TextLabel")
TitleBar.Size = UDim2.new(1, 0, 0, 35)
TitleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
TitleBar.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleBar.TextSize = 14
TitleBar.Font = Enum.Font.SourceSansBold
TitleBar.Text = "  Renzvex Server Finder 🗂️"
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = TitleBar

-- Tombol Close (X)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 35, 0, 35)
CloseBtn.Position = UDim2.new(1, -35, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
CloseBtn.TextSize = 16
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.Text = "X"
CloseBtn.Parent = MainFrame

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- ScrollingFrame buat daftar list server di bawahnya
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -16, 1, -50)
ScrollFrame.Position = UDim2.new(0, 8, 0, 42)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel = 0
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 6)
UIListLayout.Parent = ScrollFrame

-- Fungsi untuk ambil data server dan nampilin ke tombol list
local function LoadServers()
    -- Bersihkan list lama
    for _, v in pairs(ScrollFrame:GetChildren()) do
        if v:IsA("Frame") then v:Destroy() end
    end
    
    local success, result = pcall(function()
        local url = "https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=50"
        return HttpService:JSONDecode(game:HttpGet(url))
    end)
    
    if success and result and result.data then
        local count = 0
        for _, server in ipairs(result.data) do
            if type(server) == "table" and server.id ~= JobId then
                local maxP = server.maxPlayers or 20
                local playingP = server.playing or 0
                
                if playingP < maxP then
                    count = count + 1
                    
                    -- Baris item server
                    local ServerRow = Instance.new("Frame")
                    ServerRow.Size = UDim2.new(1, 0, 0, 32)
                    ServerRow.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                    ServerRow.Parent = ScrollFrame
                    
                    local RowCorner = Instance.new("UICorner")
                    RowCorner.CornerRadius = UDim.new(0, 4)
                    RowCorner.Parent = ServerRow
                    
                    -- Label Info Pemain
                    local InfoLabel = Instance.new("TextLabel")
                    InfoLabel.Size = UDim2.new(0.65, 0, 1, 0)
                    InfoLabel.Position = UDim2.new(0, 8, 0, 0)
                    InfoLabel.BackgroundTransparency = 1
                    InfoLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
                    InfoLabel.TextSize = 12
                    InfoLabel.Font = Enum.Font.Code
                    InfoLabel.Text = string.Format("Players: %d/%d", playingP, maxP)
                    InfoLabel.TextXAlignment = Enum.TextXAlignment.Left
                    InfoLabel.Parent = ServerRow
                    
                    -- Tombol Join
                    local JoinBtn = Instance.new("TextButton")
                    JoinBtn.Size = UDim2.new(0, 75, 0, 24)
                    JoinBtn.Position = UDim2.new(1, -83, 0.5, -12)
                    JoinBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 127)
                    JoinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                    JoinBtn.TextSize = 12
                    JoinBtn.Font = Enum.Font.SourceSansBold
                    JoinBtn.Text = "JOIN 🚀"
                    JoinBtn.Parent = ServerRow
                    
                    local BtnCorner = Instance.new("UICorner")
                    BtnCorner.CornerRadius = UDim.new(0, 4)
                    BtnCorner.Parent = JoinBtn
                    
                    -- Aksi pas tombol Join diklik (Langsung pindah ke server itu tanpa ngulang-ngulang)
                    local targetId = server.id
                    JoinBtn.MouseButton1Click:Connect(function()
                        JoinBtn.Text = "Joining..."
                        pcall(function()
                            TeleportService:TeleportToPlaceInstance(PlaceId, targetId, LocalPlayer)
                        end)
                    end)
                end
            end
        end
        ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, count * 38)
    end
end

-- Jalankan fungsi load list server saat script dieksekusi
task.spawn(LoadServers)
