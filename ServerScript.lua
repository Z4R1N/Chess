--[[ ServerScript

Everything in here is actions picked by the server to fire different events on the Local Client.
  _____     _      ____    ___   _   _ 
 |__  /    / \    |  _ \  |_ _| | \ | |
   / /    / _ \   | |_) |  | |  |  \| |
  / /_   / ___ \  |  _ <   | |  | |\  |
 /____| /_/   \_\ |_| \_\ |___| |_| \_|

]]--

local Game = game.Workspace.BoardGame:WaitForChild("Chess")
local Board = Game.Board
local Score = Game.Score
local Event = Game.Event
local Active = Game.Active
local Turn = Game.Turn
local MSG = Game.Massage
local Win = false

--[[ game.Players.PlayerAdded:Connect(user)
This function fires when a player joins the game to give the player the right settings for a perfect game
]]
game.Players.PlayerAdded:Connect(function(Player)
	
	--Generate a String value by the name of TOKEN
	local GivenTOKEN = Instance.new("StringValue",Player)
	GivenTOKEN.Name = "TOKEN"
	
	--If no one in the game has the white side, giveaway the white side by setting the TOKEN value to White
	if Game.Turn.White.Value ~= true then
		GivenTOKEN.Value = "White"
		Game.Turn.White.Value = true
		
	--Elseif no one in the game has the black side, giveaway the black side by setting the TOKEN value to Black
	elseif Game.Turn.Black.Value ~= true then
		GivenTOKEN.Value = "Black"
		Game.Turn.White.Value = true
		
	--Else KICK the player because the game is already full
	else
		Player:Kick("Full game")
	end
end)

--[[ game.Players.PlayerRemoving:Connect(user)
This function fires when a player leaves the game will sett the old players settings to nil from the server side
]]
game.Players.PlayerRemoving:Connect(function(Player)
	--Find the given token
	local GivenTOKEN = Player.TOKEN
	
	--If the token was white then empty the white side
	if GivenTOKEN.Value == "White" then
		Game.Turn.White.Value = false
		
	--If the token was black then empty the black side
	elseif GivenTOKEN.Value == "Black" then
		Game.Turn.Black.Value = false
	end
end)

--A Quick check
function CHECK(Player, TimeWinner)
	Win = false
	local AliveWhite = false
	local AliveBlack = false
	
	--Check if any of the kings are dead
	for i_,v in next,Board:GetChildren() do
		if v:IsA("StringValue") then
			if v.Value == "White_King" and AliveWhite == false then
				AliveWhite = true
			end
			if v.Value == "Black_King" and AliveBlack == false then
				AliveBlack = true
			end
		end
	end
	
	--If a king is dead then its a win
	if AliveWhite == false then
		Win = true
	end
	if AliveBlack == false then
		Win = true
	end
	
	--If its a win or time win stop the game and display the winner
	if Win == true or TimeWinner == true then
		MSG.Value = Player.Name.." won!"
		Active.Value = false
	end
end

--[[ ;workspace.BoardGame.Chess.Event.Clear:FireServer()
Is an Event Fired by both clients and picked up by the server to clear and reset the board,
picking up the event from the server to return the new board is there to prevent both cheating and fair gameplay.
]]
Event.Clear.OnServerEvent:Connect(function()
	
	--Reset Timer
	Score.White.Value = 600
	Score.Black.Value = 600
	
	--Reset Pieces
	for i_,v in next,Board:GetChildren() do
		if v:IsA("StringValue") then
			if v.Name == "A1" then
				v.Value = "White_Rook"
			elseif v.Name == "A2" then
				v.Value = "White_Knight"
			elseif v.Name == "A3" then
				v.Value = "White_Bishop"
			elseif v.Name == "A4" then
				v.Value = "White_King"
			elseif v.Name == "A5" then
				v.Value = "White_Queen"
			elseif v.Name == "A6" then
				v.Value = "White_Bishop"
			elseif v.Name == "A7" then
				v.Value = "White_Knight"
			elseif v.Name == "A8" then
				v.Value = "White_Rook"
			elseif v.Name == "B1" or
				v.Name == "B2" or
				v.Name == "B3" or
				v.Name == "B4" or
				v.Name == "B5" or
				v.Name == "B6" or
				v.Name == "B7" or
				v.Name == "B8" then
				v.Value = "White_Pawn"

			elseif v.Name == "H1" then
				v.Value = "Black_Rook"
			elseif v.Name == "H2" then
				v.Value = "Black_Knight"
			elseif v.Name == "H3" then
				v.Value = "Black_Bishop"
			elseif v.Name == "H4" then
				v.Value = "Black_King"
			elseif v.Name == "H5" then
				v.Value = "Black_Queen"
			elseif v.Name == "H6" then
				v.Value = "Black_Bishop"
			elseif v.Name == "H7" then
				v.Value = "Black_Knight"
			elseif v.Name == "H8" then
				v.Value = "Black_Rook"
			elseif v.Name == "G1" or
				v.Name == "G2" or
				v.Name == "G3" or
				v.Name == "G4" or
				v.Name == "G5" or
				v.Name == "G6" or
				v.Name == "G7" or
				v.Name == "G8" then
				v.Value = "Black_Pawn"
			else
				v.Value = ""
			end
		end
	end
	
	--Start Countdown
	MSG.Value = "CLEARED"
	wait(1)
	MSG.Value = "The game will start in [3]"
	wait(1)
	MSG.Value = "The game will start in [2]"
	wait(1)
	MSG.Value = "The game will start in [1]"
	wait(1)
	MSG.Value = "Start"

	--Activate Board
	Active.Value = true
end)

--[[ ;workspace.BoardGame.Chess.Event.RESET:FireServer()
This event is there to test the different patterns for the different pieces.
]]
Event.RESET.OnServerEvent:Connect(function()
	for i_,v in next,Board:GetChildren() do
		if v:IsA("StringValue") then
			v.Value = ""
			if v.Name == "D5" then
				v.Value = "White_Rook"
			end
		end
	end
end)

--[[ ;workspace.BoardGame.Chess.Event.Move:FireServer(user, piece, oldPosition, newPosition)
Here we detect if the server is fired, if it is we check for what changes and we replace the change to return a new changed board to the client
]]
Event.Move.OnServerEvent:Connect(function(Player, Slot, OldPosition, NewPosition)
	
	--Empty the old position
	Board[OldPosition].Value = ""
	
	--Fill the new position with the repaced data
	Board[NewPosition].Value = Slot
	local TOKEN = Player:WaitForChild("TOKEN").Value
	
	--Log the change
	MSG.Value = Slot.." moved from "..OldPosition.." to "..NewPosition
	local TimeWinner = false

	wait(0.1)
	--If the piece color wasnt white then its whites turn
	if Turn.Value ~= "White"  then
		Turn.Value = "White"
		MSG.Value = "It´s time for [White] to make a move..."
		
		--Give White 10 extra seconds
		Score.White.Value = Score.White.Value + 10
		
		--Decrease the timer by one ever second only if its whites turn and the game is not over
		while Turn.Value == "White" and Win == false do
			wait(1)
			Score.White.Value = Score.White.Value - 1
			if Score.White.Value == 0 then
				break
			end
		end
		
		--If the timer reaches 0 then its a Time win
		if Score.White.Value == 0 then
			TimeWinner = true
		end
		
		--If the piece color wasnt black then its blacks turn
	elseif Turn.Value ~= "Black" then
		Turn.Value = "Black"
		MSG.Value = "It´s time for [Black] to make a move..."
		
		--Give Black 10 extra seconds
		Score.Black.Value = Score.Black.Value + 10
		
		--Decrease the timer by one ever second only if its blacks turn and the game is not over
		while Turn.Value == "Black" and Win == false do
			wait(1)
			Score.Black.Value = Score.Black.Value - 1
			if Score.Black.Value == 0 then
				break
			end
		end
		
		--If the timer reaches 0 then its a Time win
		if Score.Black.Value == 0 then
			TimeWinner = true
		end
	end
	
	--Check for Data
	CHECK(Player, TimeWinner)
end)

--[[ ;workspace.BoardGame.Chess.Event.Shutdown:FireServer()
This event kicks everyone from the server!
]]
Event.Shutdown.OnServerEvent:Connect(function()
	game.Players.ChildAdded:connect(function(h)
		h:Kick()
	end)
	for _,i in pairs (game.Players:GetChildren()) do
		i:Kick("Server")
	end
end)

--[[Contacts
01110100 01101000 01100101 01101111 01101110 01101100 01111001 01100111 01101111 01100100 00101110 01111010 01100001 01110010 01101001 01101110 01000000 01100111 01101101 01100001 01101001 01101100 00101110 01100011 01101111 01101101 
]]