--[[ LocalScript

Everything in here is actions picked by the the client from the server, or requests to the server.
  _____     _      ____    ___   _   _ 
 |__  /    / \    |  _ \  |_ _| | \ | |
   / /    / _ \   | |_) |  | |  |  \| |
  / /_   / ___ \  |  _ <   | |  | |\  |
 /____| /_/   \_\ |_| \_\ |___| |_| \_|

]]--

game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList,false)

local Game = game.Workspace.BoardGame:WaitForChild("Chess")
local Board = Game.Board
local Score = Game.Score
local Event = Game.Event
local Active = Game.Active
local Turn = Game.Turn
local MSG = Game.Massage

local Player = game.Players.LocalPlayer
local GameUI = Player.PlayerGui:WaitForChild("Chess")
local BoardUI = GameUI.Board.Design:WaitForChild("V1").Frame
local RestartFrame = GameUI.Board.Reset
local ScoreUI = GameUI.Score
local MassageUI = GameUI.Massage.Frame.TextLabel
local PlayerListUI = GameUI.PlayerList

local UserClone = script.UserClone
local Selected = nil
local Clickable = true

--Path Color
local Colors = {
	Empty = Color3.fromRGB(255, 255, 55);
	Enemy = Color3.fromRGB(255, 55, 55);
}

--Piece Images
local Pieces = {
	White = {
		Pawn = "rbxassetid://5230214599";
		Rook = "rbxassetid://5230213087";
		Knight = "rbxassetid://5230213545";
		Bishop = "rbxassetid://5230215978";
		Queen = "rbxassetid://5230213905";
		King = "rbxassetid://5230214282";
	};
	Black = {
		Pawn = "rbxassetid://5230217966";
		Rook = "rbxassetid://5230216449";
		Knight = "rbxassetid://5230216810";
		Bishop = "rbxassetid://5230218475";
		Queen = "rbxassetid://5230217179";
		King = "rbxassetid://5230217570";
	};
}
--game.Players.LocalPlayer:WaitForChild("TOKEN").Value = "Black"
TOKEN =  game.Players.LocalPlayer:WaitForChild("TOKEN").Value

--Flip the table layout depending on the TOKEN color
if TOKEN == "White" then
	BoardUI.UIGridLayout.StartCorner = "BottomRight"
elseif TOKEN == "Black" then
	BoardUI.UIGridLayout.StartCorner = "TopLeft"
end

--This function changes the player image in the leaderboard depending on the color
function TokenUI(user)
	if user:WaitForChild("TOKEN").Value == "White" then
		return Pieces.White.Pawn
	end
	if user:WaitForChild("TOKEN").Value == "Black" then
		return Pieces.Black.Pawn
	end
end

--Here resets the leaderboard and refills with new infermation, also the function is fired by a playerAdded event
function Reset_PlayerListUI()
	for _,v in next,PlayerListUI:GetChildren() do
		if v:IsA("Frame") then
			v:Destroy()
		end
	end
	
	for _,v in next,game.Players:GetChildren() do
		local User = UserClone:Clone()
		User.BGFrame.PlayerName.Text = v.Name
		User.BGFrame.PlayerToken.Image = TokenUI(v)
		User.Parent = PlayerListUI
	end
end

--This function changes the visibility of the timer depending on whos turn it is
Turn.Changed:Connect(function()
	if Turn.Value == "White" then
		ScoreUI.White.TextLabel.TextTransparency = 0.25
		ScoreUI.Black.TextLabel.TextTransparency = 0.75
	elseif Turn.Value == "Black" then
		ScoreUI.Black.TextLabel.TextTransparency = 0.25
		ScoreUI.White.TextLabel.TextTransparency = 0.75
	end
end)

--What this function does is, its recalculates the seconds to a clock with minutes:seconds for white
Score.White.Changed:Connect(function()
	if Turn.Value == "White" then
		ScoreUI.White.Frame.TextLabel.Text = tostring(math.floor(Score.White.Value/60)).." : "..tostring(math.floor(Score.White.Value%60))
	end
end)

--What this function does is, its recalculates the seconds to a clock with minutes:seconds for Black
Score.Black.Changed:Connect(function()
	if Turn.Value == "Black" then
		ScoreUI.Black.Frame.TextLabel.Text = tostring(math.floor(Score.Black.Value/60)).." : "..tostring(math.floor(Score.Black.Value%60))
	end
end)

--HERE is the logging massage, when its updated a function fires to update the Logged message
MSG.Changed:Connect(function()
	MassageUI.Text = MSG.Value
end)

--An update function on Active value, so when the game is over stop movements and display a dark screen
Active.Changed:Connect(function()
	if Active.Value == false then
		RestartFrame.Visible = true
	elseif Active.Value == true then
		RestartFrame.Visible = false
		RestartFrame.Frame.Visible = true
	end
end)

--A click event on a button calling on "Clear" ServerEvent
RestartFrame.Frame.ResetButton.Activated:Connect(function()
	RestartFrame.Frame.Visible = false
	wait(0.5)
	Event:FindFirstChild("Clear"):FireServer()
end)

--This function clears all the pathmarks on the client side
function CLEAR()
	for i_,v in next,BoardUI:GetChildren() do
		if v:IsA("Frame") then
			v.Frame.Mark.Visible = false
		end
	end
end

--A small SPLIT function to detect what piece it is and what color it is
function SPLIT(Slot)
	local ColorSplit, PieceSplit
	local s = pcall(function()
        local Split = Slot:split('_')
		ColorSplit = Split[1]
		PieceSplit = Split[2]
	end)
	return ColorSplit, PieceSplit
end

--This will display the Pathmark
function MARK(Path, Piece)
	for i_,v in next,BoardUI:GetChildren() do
		if v:IsA("Frame") then
			if Path.Frame.Slot.Value == "" and Piece ~= "Pawn" then
				Path.Frame.Mark.ImageColor3 = Colors.Empty
				Path.Frame.Mark.Visible = true
				
			elseif Path.Frame.Slot.Value ~= "" then
				local Slot = Path.Frame.Slot.Value
				local ColorSplit, PieceSplit = SPLIT(Slot)
				if ColorSplit ~= TOKEN then
					Path.Frame.Mark.ImageColor3 = Colors.Enemy
					Path.Frame.Mark.Visible = true
				end
				return "break"
			end
		end
	end
end

--Its a for loop to detect all the pieces on the board
for i_,v in next,Board:GetChildren() do
	if v:IsA("StringValue") then
		v.Changed:Connect(function()
			local Slot = v.Value
			if Slot ~= "" then
				local ColorSplit, PieceSplit = SPLIT(Slot)			
				print(ColorSplit.." colored "..PieceSplit.."!")
				
				BoardUI[v.Name].Frame.Button.Image = Pieces[ColorSplit][PieceSplit]
			else
				BoardUI[v.Name].Frame.Button.Image = ""
			end		
			BoardUI[v.Name].Frame.Slot.Value = v.Value
		end)
	end
end

--THIS IS THE MAIN FUNCTION WITH ALL PATHS FOR ALL DIFFRENT PIECES
function Move(Location, Piece, PieceColor) -- https://gyazo.com/a05477eef4251154fc2b3af5666d61cd
	local NewLocation = {Location.NextSelectionUp, Location.NextSelectionDown, Location.NextSelectionLeft, Location.NextSelectionRight}
	local Position = Location.Name
	local i
	CLEAR()
	
	if Piece == "Pawn" then
		if PieceColor == "White" then
			if Position == "B1" and Location.NextSelectionDown.NextSelectionDown.Frame.Slot.Value == "" and Location.NextSelectionDown.Frame.Slot.Value == "" or
				Position == "B2" and Location.NextSelectionDown.NextSelectionDown.Frame.Slot.Value == "" and Location.NextSelectionDown.Frame.Slot.Value == "" or
				Position == "B3" and Location.NextSelectionDown.NextSelectionDown.Frame.Slot.Value == "" and Location.NextSelectionDown.Frame.Slot.Value == "" or
				Position == "B4" and Location.NextSelectionDown.NextSelectionDown.Frame.Slot.Value == "" and Location.NextSelectionDown.Frame.Slot.Value == "" or
				Position == "B5" and Location.NextSelectionDown.NextSelectionDown.Frame.Slot.Value == "" and Location.NextSelectionDown.Frame.Slot.Value == "" or
				Position == "B6" and Location.NextSelectionDown.NextSelectionDown.Frame.Slot.Value == "" and Location.NextSelectionDown.Frame.Slot.Value == "" or
				Position == "B7" and Location.NextSelectionDown.NextSelectionDown.Frame.Slot.Value == "" and Location.NextSelectionDown.Frame.Slot.Value == "" or
				Position == "B8" and Location.NextSelectionDown.NextSelectionDown.Frame.Slot.Value == "" and Location.NextSelectionDown.Frame.Slot.Value == ""
			then
				Location.NextSelectionDown.Frame.Mark.ImageColor3 = Colors.Empty
				Location.NextSelectionDown.Frame.Mark.Visible = true
				Location.NextSelectionDown.NextSelectionDown.Frame.Mark.ImageColor3 = Colors.Empty
				Location.NextSelectionDown.NextSelectionDown.Frame.Mark.Visible = true
			elseif Location.NextSelectionDown ~= nil and Location.NextSelectionDown.Frame.Slot.Value == "" then
				Location.NextSelectionDown.Frame.Mark.ImageColor3 = Colors.Empty
				Location.NextSelectionDown.Frame.Mark.Visible = true
			end
			i = 2
		elseif PieceColor == "Black" then
			if Position == "G1" and Location.NextSelectionUp.NextSelectionUp.Frame.Slot.Value == "" and Location.NextSelectionUp.Frame.Slot.Value == "" or
				Position == "G2" and Location.NextSelectionUp.NextSelectionUp.Frame.Slot.Value == "" and Location.NextSelectionUp.Frame.Slot.Value == "" or
				Position == "G3" and Location.NextSelectionUp.NextSelectionUp.Frame.Slot.Value == "" and Location.NextSelectionUp.Frame.Slot.Value == "" or
				Position == "G4" and Location.NextSelectionUp.NextSelectionUp.Frame.Slot.Value == "" and Location.NextSelectionUp.Frame.Slot.Value == "" or
				Position == "G5" and Location.NextSelectionUp.NextSelectionUp.Frame.Slot.Value == "" and Location.NextSelectionUp.Frame.Slot.Value == "" or
				Position == "G6" and Location.NextSelectionUp.NextSelectionUp.Frame.Slot.Value == "" and Location.NextSelectionUp.Frame.Slot.Value == "" or
				Position == "G7" and Location.NextSelectionUp.NextSelectionUp.Frame.Slot.Value == "" and Location.NextSelectionUp.Frame.Slot.Value == "" or
				Position == "G8" and Location.NextSelectionUp.NextSelectionUp.Frame.Slot.Value == "" and Location.NextSelectionUp.Frame.Slot.Value == ""
			then
				Location.NextSelectionUp.Frame.Mark.ImageColor3 = Colors.Empty
				Location.NextSelectionUp.Frame.Mark.Visible = true
				Location.NextSelectionUp.NextSelectionUp.Frame.Mark.ImageColor3 = Colors.Empty
				Location.NextSelectionUp.NextSelectionUp.Frame.Mark.Visible = true
			elseif Location.NextSelectionUp ~= nil and Location.NextSelectionUp.Frame.Slot.Value == "" then
				Location.NextSelectionUp.Frame.Mark.ImageColor3 = Colors.Empty
				Location.NextSelectionUp.Frame.Mark.Visible = true
			end
			i = 1
		end
		
		--ATTACK
		local Path = NewLocation[i]
		if Path ~= nil then
			if Location.NextSelectionLeft ~= nil then
				local Path = Path.NextSelectionLeft
				MARK(Path, "Pawn")
			end
			if Location.NextSelectionRight ~= nil then
				local Path = Path.NextSelectionRight
				MARK(Path, "Pawn")
			end
		end
		
	elseif Piece == "Rook" then
		for i = 1, 4 do
			local Path = NewLocation[i]
			while true do
				if Path ~= nil then
					if MARK(Path) == "break" then
						break
					end
				else
					break
				end
				
				if i == 1 then
					Path = Path.NextSelectionUp
				elseif i == 2 then
					Path = Path.NextSelectionDown
				elseif i == 3 then
					Path = Path.NextSelectionLeft
				elseif i == 4 then
					Path = Path.NextSelectionRight		
				end
			end
		end
		
	elseif Piece == "Knight" then
		for i = 1, 4 do
			local Path = NewLocation[i]
			if Path ~= nil then
				if i == 1 then
					Path = Path.NextSelectionUp
				elseif i == 2 then
					Path = Path.NextSelectionDown
				elseif i == 3 then
					Path = Path.NextSelectionLeft
				elseif i == 4 then
					Path = Path.NextSelectionRight		
				end
				if Path ~= nil and i == 1 or Path ~= nil and i == 2 then
					if Path.NextSelectionLeft ~= nil then
						MARK(Path.NextSelectionLeft)
					end
					if Path.NextSelectionRight ~= nil then
						MARK(Path.NextSelectionRight)
					end
				elseif Path ~= nil and i == 3 or Path ~= nil and i == 4 then
					if Path.NextSelectionUp ~= nil then
						MARK(Path.NextSelectionUp)
					end
					if Path.NextSelectionDown ~= nil then
						MARK(Path.NextSelectionDown)
					end
				end
			end
		end
		
	elseif Piece == "Bishop" then		
		for i = 1, 2 do
			local Path = NewLocation[i]
			while true do
				if Path ~= nil then
					if Path.NextSelectionRight ~= nil then
						Path = Path.NextSelectionRight
						if MARK(Path) == "break" then
							break
						end
						if i == 1 then
							Path = Path.NextSelectionUp
						elseif i == 2 then
							Path = Path.NextSelectionDown
						end
					else
						break
					end
				else
					break
				end
			end
			
			Path = NewLocation[i]
			while true do
				if Path ~= nil then
					if Path.NextSelectionLeft ~= nil then
						Path = Path.NextSelectionLeft
						if MARK(Path) == "break" then
							break
						end
						if i == 1 then
							Path = Path.NextSelectionUp
						elseif i == 2 then
							Path = Path.NextSelectionDown
						end
					else
						break
					end
				else
					break
				end
			end
		end
		
	elseif Piece == "Queen" then
		for i = 1, 4 do
			local Path = NewLocation[i]
			while true do
				if Path ~= nil then
					if MARK(Path) == "break" then
						break
					end
				else
					break
				end
				
				if i == 1 then
					Path = Path.NextSelectionUp
				elseif i == 2 then
					Path = Path.NextSelectionDown
				elseif i == 3 then
					Path = Path.NextSelectionLeft
				elseif i == 4 then
					Path = Path.NextSelectionRight		
				end
			end
		end
		
		for i = 1, 2 do
			local Path = NewLocation[i]
			while true do
				if Path ~= nil then
					if Path.NextSelectionRight ~= nil then
						Path = Path.NextSelectionRight
						if MARK(Path) == "break" then
							break
						end
						if i == 1 then
							Path = Path.NextSelectionUp
						elseif i == 2 then
							Path = Path.NextSelectionDown
						end
					else
						break
					end
				else
					break
				end
			end
			
			Path = NewLocation[i]
			while true do
				if Path ~= nil then
					if Path.NextSelectionLeft ~= nil then
						Path = Path.NextSelectionLeft
						if MARK(Path) == "break" then
							break
						end
						if i == 1 then
							Path = Path.NextSelectionUp
						elseif i == 2 then
							Path = Path.NextSelectionDown
						end
					else
						break
					end
				else
					break
				end
			end
		end
		
	elseif Piece == "King" then
		for i = 1, 4 do
			local Path = NewLocation[i]
			if Path ~= nil then
				MARK(Path)
				if Path ~= nil and i == 1 or Path ~= nil and i == 2 then
					if Path.NextSelectionLeft ~= nil then
						MARK(Path.NextSelectionLeft)
					end
					if Path.NextSelectionRight ~= nil then
						MARK(Path.NextSelectionRight)
					end
				elseif Path ~= nil and i == 3 or Path ~= nil and i == 4 then
					if Path.NextSelectionUp ~= nil then
						MARK(Path.NextSelectionUp)
					end
					if Path.NextSelectionDown ~= nil then
						MARK(Path.NextSelectionDown)
					end
				end
			end
		end
		
	end
end

for i_,v in next,BoardUI:GetChildren() do
	if v:IsA("Frame") then
		v.Frame.Button.Activated:Connect(function()
			local Slot = v.Frame.Slot.Value
			local ColorSplit, PieceSplit = SPLIT(Slot)
			if v.Frame.Slot.Value ~= "" and ColorSplit == TOKEN and Turn.Value == TOKEN and Clickable == true and Active.Value == true and RestartFrame.Visible == false then
				Clickable = false
				if v ~= Selected and v.Name ~= "" then
					Selected = v

					warn(v,PieceSplit,ColorSplit)
					Move(v,PieceSplit,ColorSplit)
				else
					Selected = nil
					CLEAR()
				end
				wait(0.1)
				Clickable = true
			elseif v.Frame.Mark.Visible == true then
				local OldPosition = Selected.Name
				local NewPosition = v.Name
				local Slot = Selected.Frame.Slot.Value

				Event:FindFirstChild("Move"):FireServer(Slot, OldPosition, NewPosition)
				CLEAR()
			end
		end)
	end
end

RestartFrame.Frame.ResetButton.Activated:Connect(function()
	RestartFrame.Frame.Visible = false
	wait(0.5)
	Event:FindFirstChild("Clear"):FireServer()
end)


Reset_PlayerListUI()
game.Players.PlayerAdded:Connect(Reset_PlayerListUI)
game.Players.PlayerRemoving:Connect(Reset_PlayerListUI)

--[[Contacts
01110100 01101000 01100101 01101111 01101110 01101100 01111001 01100111 01101111 01100100 00101110 01111010 01100001 01110010 01101001 01101110 01000000 01100111 01101101 01100001 01101001 01101100 00101110 01100011 01101111 01101101 
]]