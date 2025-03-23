local module = {}

local plrs = game:GetService("Players")
local TweenService = game:GetService("TweenService")

currentPlayers = {}

local goingDown = false 
local minimumSurvivalsForClaw = 3

-- If any players are welded to the claw, it will unweld them
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

-- A simple countdown for the round and intermission
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

--Beginning the intermission
function module.Intermission()
	module.Countdown(30)
end

function module.StartRound()
	local grabber 
	local plrsTable = plrs:GetPlayers()

	--This if statement is done to check if someone already purchased the become instant grabber devproduct
	if not plrs:FindFirstChild("Grabber", true) then
		repeat
			grabber = plrsTable[math.random(1, #plrsTable)]
			wait()
		until grabber.leaderstats.Survivals.Value > minimumSurvivalsForClaw 	--The player must have a certain amount of survivals to be picked as the grabber

		print(grabber.Name.." has been selected as the grabber!")

		local val = Instance.new("StringValue", grabber)
		val.Name = "Grabber"
	else
		grabber = plrs:FindFirstChild("Grabber", true).Parent
		print("current grabber", grabber)
		print(grabber.Name.." has been selected as the grabber!")
	end

	--Below, the players are put into the claw machine as the round starts.
	for _, plr in pairs(plrsTable) do
		if plr ~= grabber then
			plr.Character.HumanoidRootPart.Position = game.Workspace.Machine.PlayerSpawn.Position
			table.insert(currentPlayers, plr)

			local val = Instance.new("StringValue", plr)
			val.Name = "Competitor"

			--Making the players bigger
			local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
			if humanoid then
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
	
	module.Countdown(60) --The round now goes for 60 seconds
end


function module.EndRound()
	local plrsTable = plrs:GetPlayers()

	for _, plr in pairs(plrsTable) do
		plr.Character.HumanoidRootPart.Position = game.Workspace.SpawnLocation.Position + Vector3.new(0,3,0) --Bringing players back to spawn
		
		destroyWeld() --Calling destroyweld to check if there is a player currently being held by the claw
		
		--Making players normal size again
		local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid.BodyHeightScale.Value = 1
			humanoid.BodyWidthScale.Value = 1
			humanoid.BodyDepthScale.Value = 1
			humanoid.HeadScale.Value = 1
		end
		
		task.wait()
		
		--Allowing the grabber to walk again
		if plr:FindFirstChild("Grabber") then
			if not plr:FindFirstChild("Competitor") then
				plr.Character.Humanoid.WalkSpeed = 16
				plr.Grabber:Destroy()
				print("deleted grabber")
			end
		end
		
		--Adding on survivals if the player did not get caught by the claw
		if plr:FindFirstChild("Competitor") then
			plr.leaderstats.Survivals.Value += 1
			plr.Competitor:Destroy()
		end
	end
	
	game.ServerStorage.CurrentRound:Destroy()
	
	module.Countdown(30)
end

--Full claw movement
function module.Movement(input, isHeld)
	print(input, isHeld)
	local moveDirection = nil
	
	--Below sets the movement variable
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

		--Claw moving down
		repeat
			for _, part in pairs(grabber:GetDescendants()) do
				if part:IsA("BasePart") then
					part.Position += Vector3.new(0, -300 * 0.005, 0)
				end
			end
			task.wait(0.01)
		until grabber.Claw.Body.Position.Y == 318

		--Closing the prongs to pick up player
		for _, prong in pairs(prongs) do
			local targetCFrame = prong.Transparent.CFrame
			local tweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			local tween = TweenService:Create(prong.Union, tweenInfo, {CFrame = targetCFrame})
			tween:Play()
		end

		task.wait(2) 

		--Claw moving back up
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

		--Claw moving down
		repeat
			for _, part in pairs(grabber:GetDescendants()) do
				if part:IsA("BasePart") then
					part.Position += Vector3.new(0, -250 * 0.005, 0)
				end
			end
			task.wait(0.01)
		until grabber.Claw.Body.Position.Y == 348

		--Claw opening to drop the player
		for _, prong in pairs(prongs) do
			local targetCFrame = prong.Original.CFrame
			local tweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			local tween = TweenService:Create(prong.Union, tweenInfo, {CFrame = targetCFrame})
			tween:Play()
		end
		
		destroyWeld() --Letting go of the player

		task.wait(2) 

		--Moving back up
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

	if moveDirection and not goingDown then --Checking if the claw is not moving up or down, and to check if the grabber is trying to move the claw left, right, forward or backwards
		while isHeld() do
			
			if goingDown then
				print("goingDown detected, breaking loop")
				break
			end	
			
			if input == Enum.KeyCode.A and game.Workspace.Conveyor.Grabber.Claw.Body.Position.Z < 155 then --Stops at a certain position
				for _, part in pairs(game.Workspace.Conveyor.Grabber:GetDescendants()) do
					if part:IsA("BasePart") then
						part.Position += moveDirection * 0.05 --Moving gradually in accordance to the direction
					end
				end
			elseif input == Enum.KeyCode.D and game.Workspace.Conveyor.Grabber.Claw.Body.Position.Z > -90 then --Stops at a certain position
				for _, part in pairs(game.Workspace.Conveyor.Grabber:GetDescendants()) do
					if part:IsA("BasePart") then
						part.Position += moveDirection * 0.05 --Moving gradually in accordance to the direction
					end
				end
			elseif input == Enum.KeyCode.W and game.Workspace.Conveyor.Grabber.Claw.Body.Position.X > -650 then --Stops at a certain position
				for _, part in pairs(game.Workspace.Conveyor:GetDescendants()) do
					if part:IsA("BasePart") then
						part.Position += moveDirection * 0.05 --Moving gradually in accordance to the direction
					end
				end
			elseif input == Enum.KeyCode.S and game.Workspace.Conveyor.Grabber.Claw.Body.Position.X < -405 then --Stops at a certain position
				for _, part in pairs(game.Workspace.Conveyor:GetDescendants()) do
					if part:IsA("BasePart") then
						part.Position += moveDirection * 0.05 --Moving gradually in accordance to the direction
					end
				end
			end
			task.wait(0.01)
		end
	end
end

-- The below function sends the players into the claw machine, making them bigger too. This is only used if a round is happening, and a player joins mid round.
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
