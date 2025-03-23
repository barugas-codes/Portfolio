local module = {}

local plrs = game:GetService("Players")
local TweenService = game:GetService("TweenService")

currentPlayers = {}

local goingDown = false 
local minimumSurvivalsForClaw = 3

local function destroyWeld()
	game.Workspace.Conveyor.Grabber.Claw.Hitbox.Script.Enabled = false
	for _, weld in pairs(game.Workspace.Conveyor.Grabber.Claw.Hitbox:GetChildren()) do
		if weld:IsA("Weld") and weld.Part0.Name == "Head" then
			weld:Destroy()
			print("Found")
		end
	end
	wait(3)
	game.Workspace.Conveyor.Grabber.Claw.Hitbox.Script.Enabled = true
end

function module.Countdown(Time)
	local originalTime = Time
	
	repeat
		Time -=1 
		print(Time)
		wait(1)
	until Time == 0 
	
	if originalTime == 30 then
		print("Intermission has ended.")
		module.StartRound()
	else
		print("Round has ended.")
		module.EndRound()
	end
end

function module.Intermission()
	module.Countdown(30)
end

function module.StartRound()
	local grabber 
	local plrsTable = plrs:GetPlayers()

	if not plrs:FindFirstChild("Grabber", true) then
		repeat
			grabber = plrsTable[math.random(1, #plrsTable)]
			wait()
		until grabber.leaderstats.Survivals.Value > minimumSurvivalsForClaw

		print(grabber.Name.." has been selected as the grabber!")

		local val = Instance.new("StringValue", grabber)
		val.Name = "Grabber"
	else
		grabber = plrs:FindFirstChild("Grabber", true).Parent
		print("current grabber", grabber)
		print(grabber.Name.." has been selected as the grabber!")
	end

	for _, plr in pairs(plrsTable) do
		if plr ~= grabber then
			plr.Character.HumanoidRootPart.Position = game.Workspace.Machine.PlayerSpawn.Position
			table.insert(currentPlayers, plr)

			local val = Instance.new("StringValue", plr)
			val.Name = "Competitor"

			local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
			if humanoid then
				print(humanoid.BodyHeightScale.Value, humanoid.BodyWidthScale.Value, humanoid.BodyDepthScale.Value, humanoid.HeadScale.Value)

				
				humanoid.BodyHeightScale.Value = 10
				humanoid.BodyWidthScale.Value = 10
				humanoid.BodyDepthScale.Value = 10
				humanoid.HeadScale.Value = 10
			end
		else
			plr.Character.HumanoidRootPart.Position = game.Workspace.GrabberSpawn.Position
			plr.Character.Humanoid.WalkSpeed = 0
		end
		task.wait(.2)
	end

	local round = Instance.new("BoolValue", game.ServerStorage)
	round.Name = "CurrentRound"
	round.Value = true
	
	module.Countdown(60)
end


function module.EndRound()
	local plrsTable = plrs:GetPlayers()

	for _, plr in pairs(plrsTable) do
		plr.Character.HumanoidRootPart.Position = game.Workspace.SpawnLocation.Position + Vector3.new(0,3,0)
		
		destroyWeld()
		
		local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid.BodyHeightScale.Value = 1
			humanoid.BodyWidthScale.Value = 1
			humanoid.BodyDepthScale.Value = 1
			humanoid.HeadScale.Value = 1
		end
		
		task.wait()

		if plr:FindFirstChild("Grabber") then
			if not plr:FindFirstChild("Competitor") then
				plr.Character.Humanoid.WalkSpeed = 16
				plr.Grabber:Destroy()
				print("deleted grabber")
			end
		end
		
		if plr:FindFirstChild("Competitor") then
			plr.leaderstats.Survivals.Value += 1
			plr.Competitor:Destroy()
		end
	end
	
	game.ServerStorage.CurrentRound:Destroy()
	
	module.Countdown(30)
end

function module.Movement(input, isHeld)
	print(input, isHeld)
	local moveDirection = nil
	
	if input == Enum.KeyCode.A then
		moveDirection = Vector3.new(0, 0, 10)
	elseif input == Enum.KeyCode.W then
		moveDirection = Vector3.new(-10, 0, 0)
	elseif input == Enum.KeyCode.S then
		moveDirection = Vector3.new(10, 0, 0)
	elseif input == Enum.KeyCode.D then
		moveDirection = Vector3.new(0, 0, -10)
	elseif input == Enum.KeyCode.E and game.Workspace.Conveyor.Grabber.Claw.Body.Position.Y == 618 then
		goingDown = true
		local grabber = game.Workspace.Conveyor.Grabber
		local prongs = {grabber.Prong1, grabber.Prong2, grabber.Prong3}
		local TweenService = game:GetService("TweenService")
		local tweenTime = 1 

		repeat
			for _, part in pairs(grabber:GetDescendants()) do
				if part:IsA("BasePart") then
					part.Position += Vector3.new(0, -300 * 0.005, 0)
				end
			end
			task.wait(0.01)
		until grabber.Claw.Body.Position.Y == 318

		for _, prong in pairs(prongs) do
			local targetCFrame = prong.Transparent.CFrame
			local tweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			local tween = TweenService:Create(prong.Union, tweenInfo, {CFrame = targetCFrame})
			tween:Play()
		end

		task.wait(2) 

		repeat
			for _, part in pairs(grabber:GetDescendants()) do
				if part:IsA("BasePart") then
					part.Position += Vector3.new(0, 300 * 0.005, 0)
				end
			end
			task.wait(0.01)
		until grabber.Claw.Body.Position.Y == 618
		
		goingDown = false
	elseif input == Enum.KeyCode.F and game.Workspace.Conveyor.Grabber.Claw.Body.Position.Y == 618 then
		goingDown = true
		local grabber = game.Workspace.Conveyor.Grabber
		local prongs = {grabber.Prong1, grabber.Prong2, grabber.Prong3}
		local TweenService = game:GetService("TweenService")
		local tweenTime = 1 

		repeat
			for _, part in pairs(grabber:GetDescendants()) do
				if part:IsA("BasePart") then
					part.Position += Vector3.new(0, -250 * 0.005, 0)
				end
			end
			task.wait(0.01)
		until grabber.Claw.Body.Position.Y == 348

		for _, prong in pairs(prongs) do
			local targetCFrame = prong.Original.CFrame
			local tweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			local tween = TweenService:Create(prong.Union, tweenInfo, {CFrame = targetCFrame})
			tween:Play()
		end
		
		destroyWeld()

		task.wait(2) 

		repeat
			for _, part in pairs(grabber:GetDescendants()) do
				if part:IsA("BasePart") then
					part.Position += Vector3.new(0, 250 * 0.005, 0)
				end
			end
			task.wait(0.01)
		until grabber.Claw.Body.Position.Y == 618

		goingDown = false
	end

	if moveDirection and not goingDown then
		while isHeld() do
			
			if goingDown then
				print("goingDown detected, breaking loop")
				break
			end	
			
			if input == Enum.KeyCode.A and game.Workspace.Conveyor.Grabber.Claw.Body.Position.Z < 155 then
				for _, part in pairs(game.Workspace.Conveyor.Grabber:GetDescendants()) do
					if part:IsA("BasePart") then
						part.Position += moveDirection * 0.05
					end
				end
			elseif input == Enum.KeyCode.D and game.Workspace.Conveyor.Grabber.Claw.Body.Position.Z > -90 then
				for _, part in pairs(game.Workspace.Conveyor.Grabber:GetDescendants()) do
					if part:IsA("BasePart") then
						part.Position += moveDirection * 0.05
					end
				end
			elseif input == Enum.KeyCode.W and game.Workspace.Conveyor.Grabber.Claw.Body.Position.X > -650 then
				for _, part in pairs(game.Workspace.Conveyor:GetDescendants()) do
					if part:IsA("BasePart") then
						part.Position += moveDirection * 0.05
					end
				end
			elseif input == Enum.KeyCode.S and game.Workspace.Conveyor.Grabber.Claw.Body.Position.X < -405 then
				for _, part in pairs(game.Workspace.Conveyor:GetDescendants()) do
					if part:IsA("BasePart") then
						part.Position += moveDirection * 0.05
					end
				end
			end
			task.wait(0.01)
		end
	end
end

function module.AddPlayer(plr, char)
	char.HumanoidRootPart.Position = game.Workspace.Machine.PlayerSpawn.Position
	table.insert(currentPlayers, plr)

	local val = Instance.new("StringValue", plr)
	val.Name = "Competitor"

	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if humanoid then
		print(humanoid.BodyHeightScale.Value, humanoid.BodyWidthScale.Value, humanoid.BodyDepthScale.Value, humanoid.HeadScale.Value)
		humanoid.BodyHeightScale.Value = 10
		humanoid.BodyWidthScale.Value = 10
		humanoid.BodyDepthScale.Value = 10
		humanoid.HeadScale.Value = 10
	end
end

return module
