
// Project: Virposa 2 
// Created: 2016-11-21

// show all errors
SetErrorMode(2)

// set window properties
SetWindowTitle( "Virposa 2" )
SetWindowSize( 621, 1104, 0 )          //Change this for exact resolution

//SetWindowSize( 640, 960, 0 )

global w as integer
w = GetDeviceWidth()
//w = 621
global h as integer
h = GetDeviceHeight()
//h = 1104


//Game is based on horizontal ratio of 320
global dRatio# as integer
dRatio# =  w/320.0

// set display properties
SetVirtualResolution(w, h)
SetOrientationAllowed(1, 0, 0, 0)

global asteroid = 1001
LoadImage(asteroid, "Asteroid32.png")

global mainFont = 2001
LoadImage(mainFont, "mainFont.png")

global white
white = MakeColor(255, 255, 255)
global yellow
yellow = MakeColor(255, 255, 0)
global red
red = MakeColor(255, 50, 0)

CreateMemblockFromImage(1, asteroid)
for i = 12 to 11+32*32*4 step 4
	if i+3 <> 0
		SetMemblockByte(1, i, GetMemblockByte(1, i)+80)
		SetMemblockByte(1, i+1, GetMemblockByte(1, i+1)+50)
		SetMemblockByte(1, i+2, GetMemblockByte(1, i+2)+60)
	endif
next i
CreateImageFromMemblock(asteroid, 1)
//SaveImage(asteroid, "lightStoid.png")

global PlanetPick = 2
global LunarLalaA = 3
global LunarLalaB = 4
global LunarLalaC = 5
global OrbitalCluster = 6
global StarSpegI = 7
global StarSpegL = 8
global ClockHorI = 9
global ClockHorL = 10
global OrtCloudColony = 11
global RadiantRush = 12

LoadMusicOgg(PlanetPick, "planet_pick.ogg")
LoadMusicOgg(LunarLalaA, "song1_1.ogg")
LoadMusicOGG(LunarLalaB, "song1_2.ogg")
LoadMusicOGG(LunarLalaC, "song1_3.ogg")
LoadMusicOGG(OrbitalCluster, "orbital_cluster.ogg")
LoadMusicOGG(StarSpegI, "s_s_intro.ogg")
LoadMusicOGG(StarSpegL, "s_s_loop.ogg")
LoadMusicOGG(ClockHorI, "c_h_intro.ogg")
LoadMusicOGG(ClockHorL, "c_h_loop.ogg")
LoadMusicOGG(OrtCloudColony, "ort_cloud_colony.ogg")
LoadMusicOGG(RadiantRush, "radiant_rush.ogg")

global move = 1
global clear = 2
global breakSound = 3

LoadSound(move, "move.wav")
LoadSound(clear, "clear.wav")
LoadSound(breakSound, "break.wav")

/*SPRITE NUMEBERS:
1 - Jeb
2 - Room Explosion
202 - Room 4 Explosion
3 - Darkness
4 - Space background
5 - Planet
6 - Florm
7 - Pause Button
8 - Lives picture

41 - Big Clock Hand (Behind You)
42 - Little Clock Hand (In Front of You)

51 - Florm Left Claw
52 - Florm Left Arm
53 - Florm Right Claw
54 - Florm Right Arm

71-72 - Pause Backdrops
73 - Back to Planet Select
74-76 - Volume

11-13 Jeb Planet Progress
14-15 Mid Room Animations
16-17 Room Transition Text Boader
18-19 Top & Bottom bounds for planet 2

1000 Menu background
1001-1006 Menu select planets

1022-1026 Planet Locks

1001+ - Blocks
2001+, 3000+ Planet 2 Blocks
*/

/*TEXT NUMBERS
1 - Game Name after pressing first planet
2-3 - Level description

4-8 Pause Screen

*/

SetPhysicsGravity(0, 0)

Function Button(sprite) 
returnValue = 0 `reset value for check
If GetPointerX() > GetSpriteXByOffset( sprite ) - ( GetSpriteWidth( sprite ) / 2 )
 If GetPointerX() < GetSpriteXByOffset( sprite ) + ( GetSpriteWidth( sprite ) / 2 )
   If GetPointerY() > GetSpriteYByOffset( sprite ) - ( GetSpriteHeight( sprite ) / 2 )
    If GetPointerY() < GetSpriteYByOffset( sprite ) + ( GetSpriteHeight( sprite ) / 2 )
      If GetPointerState() = 1
        returnValue = 1
      Endif
     Endif
   Endif
  Endif
Endif
EndFunction returnValue

function ResetToMenu()
	SetViewOffset(0, 0)
	for i = 0 to 4500
		if GetSpriteExists(i) then DeleteSprite(i)
	next i
	doorSprite = 0
	DeleteParticles(1)
	SetPhysicsGravity(0, 0)
	//Jeb Properties
	roomNum = 1
	roomRegion = 1
	roomsCleared = 0
	isStageEnd = 0
	endAnimation = 0

	paused = 0
	volumeOn = 1
	vibrationOn = 1

	effRotSpeed# = 1
	effVelo# = 1
	effBounce# = 1
	effRotReverse = 1
	effWind# = 0
	effDark = 0
	effScrollSpeed# = 1.1
	effClockSpeed# = 10.0

	effect = 0

	moveGuide = 0

	xOff# = 0
	yOff# = 0

	planetNum = 0
	planetHeight# = 0

	numSpinners = 0
	numBreakables = 0
	superSpin = 0
	jebLives = 3
	endlessLeft = 0
	endlessMax = 0

	clockTime = 0
	MusicStart(2)

	tempTheta = 0

	loopActive = 0

		menuOffset = 0
		CreateSprite(1000, LoadImage("menuSpace.png"))
		SetSpriteSize(1000, h, h)
		FixSpriteToScreen(1000, 1)
		SetSpriteX(1000, w/2-h/2)
endfunction

function LoadMap()
	global roomWidth = 11
	global roomHeight = 16
	
	/*OpenToRead(1, "roomA.txt")
	row1$ = ReadLine(1)
	roomWidth = Len(row1$)
	nextRowStart = 1
	while nextRowStart <> 9
		nextRowStart = Val(ReadLine(1))
		roomHeight = roomHeight + 1
	endwhile
	
	CloseFile(1)
	*/
	
	
	//OpenToRead(1, "roomA.txt")
	if planetNum = 1
		OpenToRead(1, "rooms"+Str(roomRegion)+".txt")
		if roomsCleared <> 0 then roomNum = random(1,3)
		if roomNum <> 1
			roomFound = 0
			while (roomFound = 0)
				if val(ReadLine(1)) = roomNum then roomFound = 1
			endwhile
		endif
	elseif planetNum = 2
		OpenToRead(1, "roomsB.txt")
		if (roomsCleared <> -2)
			roomNum = RandomWONum(2, 12, roomNum)
			roomFound = 0
			while (roomFound = 0)
				if ReadLine(1) = Str(roomNum)+"R" then roomFound = 1
			endwhile
		endif
	elseif planetNum = 3
		OpenToRead(1, "rooms"+Str(roomRegion)+".txt")
		roomNum = 4
		if roomsCleared <> 0 then roomNum = random(4,6)
		if roomNum <> 1
			roomFound = 0
			while (roomFound = 0)
				if val(ReadLine(1)) = roomNum then roomFound = 1
			endwhile
		endif
	elseif planetNum = 4
		OpenToRead(1, "roomsD.txt")
		roomNum = 1
		roomHeight = 11
		if (roomsCleared <> -4)
			roomNum = RandomWONum(2, 13, roomNum) //roomsCleared+6//
			roomFound = 0
			while (roomFound = 0)
				if ReadLine(1) = Str(roomNum)+"R" then roomFound = 1
			endwhile
		endif
	else //Planet Nums 5 & 6
		OpenToRead(1, "rooms"+Str(roomRegion)+".txt")
		roomNum = 7
		if roomsCleared <> 0 then roomNum = random(1,9)
		if roomNum <> 1
			roomFound = 0
			while (roomFound = 0)
				if val(ReadLine(1)) = roomNum then roomFound = 1
			endwhile
		endif
	endif
	
	
	global roomMap as integer[11, 16]
	//if planetNum = 4
	//	roomMap as integer[11, 11]
	//endif
	dim roomMap[roomWidth, roomHeight]
	for j = 1 to roomHeight
		currentRow$ = ReadLine(1)
		for i = 1 to roomWidth
			if Mid(currentRow$, i, 1) = " "
				roomMap[i,j] = 0
			else
				roomMap[i,j] = Val(Mid(currentRow$, i, 1))
			endif
		next i
	next j
	CloseFile(1)
endfunction


function DrawMap()
	numSpinners = 0
	numBreakables = 0
	tileSize = 25*dRatio#
	for i = 1 to roomWidth
		for j = 1 to roomHeight //step -1
			spriteNum = 1000+i+j*roomWidth
			if planetNum = 2
				if Mod(roomsCleared+3, 3) = 1
					spriteNum = spriteNum + 1000
				elseif Mod(roomsCleared+3, 3) = 2
					spriteNum = spriteNum + 2000
				endif
			endif
			if planetNum = 4
				if Mod(roomsCleared+4, 4) = 1
					spriteNum = spriteNum + 1000
				elseif Mod(roomsCleared+4, 4) = 2
					spriteNum = spriteNum + 2000
				elseif Mod(roomsCleared+4, 4) = 3
					spriteNum = spriteNum + 3000
				endif
			endif
			if GetSpriteExists(spriteNum) = 0 then CreateSprite(spriteNum, 0)
			SetSpriteSize(spriteNum, tileSize, tileSize)
			SetSpritePhysicsOff(spriteNum)
			SetSpritePosition(spriteNum,  tileSize*(-1+i) + (w-11*(tileSize))/2, tileSize*(j-1)+(h-16*(tileSize))/2)
			if planetNum = 2
				SetSpritePosition(spriteNum,  tileSize*(-1+i) + (w-11*(tileSize))/2, tileSize*(j-1)+(h-16*(tileSize))/2 - (roomsCleared+2)*(GetSpriteHeight(spriteNum)*16))
			elseif planetNum = 4
				//Here is the restore point
				if Mod(roomsCleared+4, 4) = 1
					SetSpritePosition(spriteNum,  tileSize*(11-j) + (w-11*(tileSize))/2, (11*tileSize) + tileSize*(i-1)+(h-16*(tileSize))/2)
				elseif Mod(roomsCleared+4, 4) = 2
					SetSpritePosition(spriteNum,  -(11*tileSize) + tileSize*(11-i) + (w-11*(tileSize))/2, (11*tileSize) + tileSize*(11-j)+(h-16*(tileSize))/2)
				elseif Mod(roomsCleared+4, 4) = 3
					SetSpritePosition(spriteNum,  -(11*tileSize) + tileSize*(j-1) + (w-11*(tileSize))/2, tileSize*(11-i)+(h-16*(tileSize))/2)
				elseif Mod(roomsCleared+4, 4) = 0
					SetSpritePosition(spriteNum,  tileSize*(i-1) + (w-11*(tileSize))/2, tileSize*(j-1)+(h-16*(tileSize))/2)
				endif
			endif
			SetSpritePhysicsOff(spriteNum)
			SetSpriteAngle(spriteNum, 0)
			if roomMap[i,j] = 1
				if GetSpriteImageID(spriteNum) <> asteroid then SetSpriteImage(spriteNum, asteroid)
				SetSpriteColor(spriteNum, 200, 255, 200, 255)
				SetSpritePhysicsOn(spriteNum, 3)
				SetSpriteShape(spriteNum, 1)
				SetSpriteAngle(spriteNum, Random(1, 360))
			elseif roomMap[i,j] = 0 or roomMap[i,j] = 3
				SetSpriteColorAlpha(spriteNum, 0)
			elseif roomMap[i,j] = 4
				SetSpriteColorAlpha(spriteNum, 0)
				//SetSpritePosition(6, GetSpriteX(spriteNum)+GetSpriteWidth(spriteNum)/2-GetSpriteWidth(6)/2, GetSpriteY(spriteNum)+GetSpriteHeight(spriteNum)/2-GetSpriteHeight(6)/2)
			elseif roomMap[i,j] = 5
				
				inc numSpinners, 1
				SetSpriteImage(spriteNum, LoadImage("spinner.png"))
				SetSpriteColor(spriteNum, 255, 255, 255, 0)
				if roomMap[i,j+1] = 1 then SetSpritePosition(spriteNum, GetSpriteX(spriteNum), GetSpriteY(spriteNum)-GetSpriteHeight(spriteNum)/2)
				if roomMap[i,j-1] = 1 then SetSpritePosition(spriteNum, GetSpriteX(spriteNum), GetSpriteY(spriteNum)+GetSpriteHeight(spriteNum)/2)
				if roomMap[i+1,j] = 1 then SetSpritePosition(spriteNum, GetSpriteX(spriteNum)-GetSpriteWidth(spriteNum)/2, GetSpriteY(spriteNum))
				if roomMap[i-1,j] = 1 then SetSpritePosition(spriteNum, GetSpriteX(spriteNum)+GetSpriteWidth(spriteNum)/2, GetSpriteY(spriteNum))
			elseif roomMap[i,j] = 6
				inc numBreakables, 1
				DeleteSprite(spriteNum)
				CreateSprite(spriteNum, asteroid)
				SetSpriteSize(spriteNum, tileSize, tileSize)
				SetSpritePosition(spriteNum,  tileSize*(-1+i) + (w-11*(tileSize))/2, tileSize*(j-1)+(h-16*(tileSize))/2)
				//if GetSpriteImageID(spriteNum) <> asteroid then SetSpriteImage(spriteNum, asteroid)
				SetSpriteColor(spriteNum, 100, 155, 100, 255)
				SetSpritePhysicsOn(spriteNum, 2)
				//SetSpritePhysicsMass(spriteNum, 20000)
				SetSpritePhysicsMass(spriteNum, 100)
				SetSpriteShape(spriteNum, 2)
				SetSpriteAngle(spriteNum, Random(1, 360))
			elseif roomMap[i,j] = 8
				//SetSpriteImage(spriteNum, LoadImage("end1.png"))
				if planetNum = 1 and roomsCleared = 29
					SetSpriteImage(spriteNum, LoadImage("key.png"))
					SetSpriteColor(spriteNum, 0, 255, 0, 255)
				elseif planetNum = 3 and roomsCleared = 29
					SetSpriteImage(spriteNum, LoadImage("key.png"))
					SetSpriteColor(spriteNum, 0, 255, 255, 255)
				else
					AddSpriteAnimationFrame(spriteNum, LoadImage("end1.png"))
					AddSpriteAnimationFrame(spriteNum, LoadImage("end2.png"))
					AddSpriteAnimationFrame(spriteNum, LoadImage("end3.png"))
					PlaySprite(spriteNum, 8, 1, 1, 3)
				endif
				SetSpriteColorAlpha(spriteNum, 254)
				
				
				doorSprite = spriteNum
				//Prevents doors from being attatched to walls
				if roomMap[i,j+1] = 1 then SetSpritePosition(doorSprite, GetSpriteX(doorSprite), GetSpriteY(doorSprite)-GetSpriteHeight(doorSprite)/2)
				if roomMap[i,j-1] = 1 then SetSpritePosition(doorSprite, GetSpriteX(doorSprite), GetSpriteY(doorSprite)+GetSpriteHeight(doorSprite)/2)
				if roomMap[i+1,j] = 1 then SetSpritePosition(doorSprite, GetSpriteX(doorSprite)-GetSpriteWidth(doorSprite)/2, GetSpriteY(doorSprite))
				if roomMap[i-1,j] = 1 then SetSpritePosition(doorSprite, GetSpriteX(doorSprite)+GetSpriteWidth(doorSprite)/2, GetSpriteY(doorSprite))
			endif
			
		next j
	next i
	
	//Breakables & Spinner creation
	if (numSpinners <> 0 or numBreakables <> 0)
		k = numSpinners
		l = numBreakables
		global dim spinners[k]
		global dim breakables[l]
		for i = 1 to roomWidth
			for j = 1 to roomHeight
				if roomMap[i,j] = 5
					spinners[k] = 1000+i+j*roomWidth
					inc k, -1
				elseif roomMap[i,j] = 6
					tSprite = 1000+i+j*roomWidth
					breakables[l] = tSprite
					SetSpritePhysicsOff(tSprite)
					SetSpritePhysicsOn(tSprite, 2)
					inc l, -1
				endif
			next j
		next i
	endif
	
	//Background creation
	if GetSpriteExists(4) = 0 
		CreateSprite(4, LoadImage("spaceBackground.png"))
		SetSpriteSize(4, h, h)
		FixSpriteToScreen(4, 1)
	endif
	SetSpritePosition(4, w/2-GetSpriteWidth(4)/2, h/2-GetSpriteHeight(4)/2)
	SetSpriteDepth(4, 999)
	
	//Planet Creation
	if GetSpriteExists(5) = 0
		CreateSprite(5, LoadImage("tempPlanet.png"))
		SetSpriteSize(5, h/4, h/4)
		if planetNum = 1 then SetSpriteColor(5, 0, 255, 0, 255)
		if planetNum = 2 then SetSpriteColor(5, 255, 0, 255, 255)
		if planetNum = 3 then SetSpriteColor(5, 0, 255, 255, 255)
		if planetNum = 4 then SetSpriteColor(5, 255, 0, 0, 255)
		if planetNum = 5 then SetSpriteColor(5, 255, 255, 0, 255)
		if planetNum = 6 then SetSpriteColor(5, 50, 100, 205, 255)
		FixSpriteToScreen(5, 1)
	endif
	SetSpritePosition(5, w/2-GetSpriteWidth(5)/2, h/2-GetSpriteHeight(5)/2)
	SetSpriteDepth(5, 998)
endfunction


function RoomUpdate()
	/*tempSprite = 1002+roomWidth
	
	//Make the room continue to 1187, skip over deleted tiles
	
	//SetSpriteAngle(tempSprite-1, GetSpriteAngle(tempSprite-1)+1)
	while (tempSprite < 1188)
		if GetSpriteExists(tempSprite)
			if (tempSprite <> doorSprite) and (GetSpriteColorAlpha(tempSprite) <> 0) and (Mod(GetSpriteAngle(1001+roomWidth), 3) = Mod(tempSprite, 3))
				if Mod(tempSprite, 3) = 0
					//SetSpritePhysicsAngularVelocity(tempSprite, 2)
				else
					//SetSpritePhysicsAngularVelocity(tempSprite, 1)
				endif
			endif
		endif
		tempSprite = tempSprite + 1
	endwhile 
	if planetNum = 2
		for j = 1 to 2
			tempSprite = 1002+roomWidth+1000*j
			SetSpriteAngle(tempSprite-1, GetSpriteAngle(tempSprite-1)+1)
			while (GetSpriteExists(tempSprite)=1)
				if (tempSprite <> doorSprite) and (GetSpriteColorAlpha(tempSprite) <> 0) and (Mod(GetSpriteAngle(1001+roomWidth), 3) = Mod(tempSprite, 3))
					if Mod(tempSprite, 3) = 0
						//SetSpritePhysicsAngularVelocity(tempSprite, 2)
					else
						//SetSpritePhysicsAngularVelocity(tempSprite, 1)
					endif
				endif
				tempSprite = tempSprite + 1
			endwhile
		next j
		//Sets boundaries
		SetSpriteY(18, -planetHeight#*(roomHeight*25*dRatio#)/1000.0)
		SetSpriteY(19, h - planetHeight#*(roomHeight*25*dRatio#)/1000.0)
	endif
	
	//if planetNum >= 5 then */
	
	if planetNum = 2
		//Space
		SetSpriteSize(4, h+backgroundIncSize*planetHeight#/1000.0, h+backgroundIncSize*planetHeight#/1000.0)
		SetSpritePosition(4, w/2-GetSpriteWidth(4)/2, h/2-GetSpriteHeight(4)/2)
		//Planet
		SetSpriteSize(5, w/4+planetIncSize*planetHeight#/1000.0, w/4+planetIncSize*planetHeight#/1000.0)
		SetSpritePosition(5, w/2-GetSpriteWidth(5)/2, h/2-GetSpriteHeight(5)/2)
		//Sets boundaries
		SetSpriteY(18, -planetHeight#*(roomHeight*25*dRatio#)/1000.0)
		SetSpriteY(19, h - planetHeight#*(roomHeight*25*dRatio#)/1000.0 - 10*dRatio#)
	endif
	
	if planetNum = 4
		//Space
		SetSpriteSize(4, h+backgroundIncSize*clockTime/1000.0, h+backgroundIncSize*clockTime/1000.0)
		SetSpritePosition(4, w/2-GetSpriteWidth(4)/2, h/2-GetSpriteHeight(4)/2)
		//Planet
		SetSpriteSize(5, w/4+planetIncSize*clockTime/1000.0, w/4+planetIncSize*clockTime/1000.0)
		SetSpritePosition(5, w/2-GetSpriteWidth(5)/2, h/2-GetSpriteHeight(5)/2)
	endif
	
	if planetNum <> 4 then SetViewOffset(xOff#, yOff#-planetHeight#*(roomHeight*25*dRatio#)/1000.0)
	xOff# = xOff#/1.5
	yOff# = yOff#/1.5
	if (yOff# > .9) or (xOff# > .9)
		//DrawLine(lineSX-w*cos(lineSTheta)-1, lineSY-h*sin(lineSTheta)-1, lineSX+w*cos(lineSTheta)-1, lineSY+h*sin(lineSTheta)-1, 255, 225, 0)
		//DrawLine(lineSX-w*cos(lineSTheta), lineSY-h*sin(lineSTheta), lineSX+w*cos(lineSTheta), lineSY+h*sin(lineSTheta), 255, 255, 0)
		//DrawLine(lineSX-w*cos(lineSTheta)+1, lineSY-h*sin(lineSTheta)+1, lineSX+w*cos(lineSTheta)+1, lineSY+h*sin(lineSTheta)+1, 255, 225, 0)
		//DrawLine(lineSX-1, lineSY-1, lineSX+w*cos(lineSTheta)-1, lineSY+h*sin(lineSTheta)-1, 255, 225, 0)
		//DrawLine(lineSX, lineSY, lineSX+w*cos(lineSTheta), lineSY+h*sin(lineSTheta), 255, 255, 0)
		//DrawLine(lineSX+1, lineSY+1, lineSX+w*cos(lineSTheta)+1, lineSY+h*sin(lineSTheta)+1, 255, 225, 0)
	endif
endfunction

function DeleteRoom()
	for i = 1 to numBreakables
		if GetSpriteExists(breakables[i]) then DeleteSprite(breakables[i])
		if GetSpriteExists(breakables[i]-10000) then DeleteSprite(breakables[i]-10000)
	next i
	for i = 1001 to 1000+11+16*11
		//If GetSpriteExists(i) then DeleteSprite(i)
	next i
endfunction

function RealDeleteRoom()
	for i = 1 to numBreakables
		if GetSpriteExists(breakables[i]) then DeleteSprite(breakables[i])
		if GetSpriteExists(breakables[i]-10000) then DeleteSprite(breakables[i]-10000)
	next i
	for i = 1001 to 1000+11+16*11
		if GetSpriteExists(i) then DeleteSprite(i)
	next i
endfunction

function LevelCreate()
	DeleteRoom()
	LoadMap()
	DrawMap()
	CreateJeb()
endfunction

function LevelCreatePlanet2()
	LoadMap()
	DrawMap()
endfunction

function CreateJeb()
	if GetSpriteExists(1) = 0
		if moveGuide = 0 then CreateSprite(1, LoadImage("jeb.png"))
		//if moveGuide = 1 then CreateSprite(1, LoadImage("jeb2.png"))
		AddSpriteAnimationFrame(1, LoadImage("jeb.png"))
		AddSpriteAnimationFrame(1, LoadImage("jebBlink.png"))
		AddSpriteAnimationFrame(1, LoadImage("jeb.png"))
		AddSpriteAnimationFrame(1, LoadImage("jeb3.png"))
		AddSpriteAnimationFrame(1, LoadImage("jeb2.png"))
		AddSpriteAnimationFrame(1, LoadImage("jeb3.png"))
		AddSpriteAnimationFrame(1, LoadImage("jeb4.png"))
		AddSpriteAnimationFrame(1, LoadImage("jeb.png"))
	endif
	//SetSpriteSize(1, 35*dRatio#, 27*dRatio#) //*dRatio#
	SetSpriteSize(1, 31*dRatio#, 23*dRatio#)
	SetSpritePhysicsOn(1, 2)
	SetSpritePhysicsRestitution(1, .0*effBounce#)
	SetSpritePhysicsMass(1, 50)
	//setSpritePhysicsCanRotate(1, 0)
	
	//if roomsCleared = 0 then SetSpritePosition(1, 50*dRatio#, 100*dRatio#) //The y needs to be set to a starting map tile
	if planetNum <> 2
		if roomsCleared = 0 or roomRegion = 1
			SetSpritePosition(1, GetSpriteX(1036), GetSpriteY(1036))
		elseif roomRegion = 2
			SetSpritePosition(1, GetSpriteX(1042), GetSpriteY(1042))
		elseif roomRegion = 3
			SetSpritePosition(1, GetSpriteX(1091), GetSpriteY(1091))
		elseif roomRegion = 4
			SetSpritePosition(1, GetSpriteX(1108), GetSpriteY(1108))
		elseif roomRegion = 5
			SetSpritePosition(1, GetSpriteX(1157), GetSpriteY(1157))
		elseif roomRegion = 6
			SetSpritePosition(1, GetSpriteX(1163), GetSpriteY(1163))
		endif
	elseif planetNum = 2
		SetSpritePosition(1, w/2-GetSpriteWidth(1)/2, h/2-GetSpriteHeight(1)/2)
		if GetSpriteExists(18) = 0
			CreateSprite(18, 0)
			SetSpriteSize(18, w, 1)
			SetSpriteDepth(18, 99999)
			SetSpritePhysicsOn(18, 1)
			CreateSprite(19, 0)
			SetSpriteSize(19, w, 10*dRatio#)
			SetSpriteY(19, h-10*dRatio#)
			SetSpriteDepth(19, 1)
			SetSpritePhysicsOn(19, 1)
			SetSpriteImage(19, LoadImage("clockHand2.png"))
			//FixSpriteToScreen(19, 1)
		endif
	endif
	
	
	if GetSpriteExists(3) = 0 then CreateSprite(3, LoadImage("light.png"))
	if h>w then SetSpriteSize(3, h*2.5, h*2.5)
	if h<w then SetSpriteSize(3, w*2.5, w*2.5)
	SetSpritePosition(3, GetSpriteX(1), GetSpriteY(1))
	SetSpriteAngle(3, GetSpriteAngle(1))
	SetSpriteColorAlpha(3, effDark)
	SetSpriteDepth(3, 2)
endfunction

function MoveJeb()
	SetSpriteDepth(1, 2)
	//SetSpriteAngle(1, GetSpriteAngle(1) + 3.0*effRotSpeed#*effRotReverse)
	SetSpritePhysicsAngularVelocity(1, 3.0*effRotSpeed#*effRotReverse*(1+superSpin))
	SetSpritePosition(3, GetSpriteX(1)-GetSpriteWidth(3)/2+GetSpriteWidth(1)/2, GetSpriteY(1)-GetSpriteHeight(3)/2+GetSpriteHeight(1)/2)
	SetSpriteAngle(3, GetSpriteAngle(1))
	
	if GetSpriteExists(13) then SetSpriteAngle(13, cos(GetSpriteAngle(1))*(15.0*effVelo#))
	
	
	if (Mod(planetNum, 2) = 0)
		temp = planetHeight# - roomsCleared*1000
		if (temp > 375)
			DrawEllipse(GetSpriteX(1)+GetSpriteWidth(1)/2, GetSpriteY(1)-GetViewOffsetY()+GetSpriteHeight(1)/2, (500-temp)*3.0*dRatio#, (500-temp)*3.0*dRatio#, yellow, yellow, 0)
		elseif (temp < -425)
			DrawEllipse(GetSpriteX(1)+GetSpriteWidth(1)/2, GetSpriteY(1)-GetViewOffsetY()+GetSpriteHeight(1)/2, (500+temp)*5.0*dRatio#, (500+temp)*5.0*dRatio#, yellow, yellow, 0)
		endif
	endif
	
	if (GetPointerPressed() = 1 or GetRawKeyPressed(32) = 1) and (Button(7) = 0) and (GetSpriteColorAlpha(2) = 0 or GetSpriteExists(2) = 0)
		PlaySound(move, volume/3*volumeOn)
		//if vibrationOn then VibrateDevice(.008)
		if planetNum = 5 then inc endlessLeft, -1
		PlaySprite(1, 40, 0, 4, 8)
		superSpin = 0
		tempTheta = GetSpriteAngle(1)
		SetSpritePhysicsVelocity(1, 150.0*cos(GetSpriteAngle(1))*dRatio#*effVelo#, 150.0*sin(GetSpriteAngle(1))*dRatio#*effVelo#) 
		
		if planetNum <> 4 then SetViewOffset(10.0*cos(GetSpriteAngle(1))*dRatio#*effVelo#, 8.0*sin(GetSpriteAngle(1))*dRatio#*effVelo#)
		xOff# = 3.0*cos(GetSpriteAngle(1))*dRatio#*effVelo#
		yOff# = 3.0*sin(GetSpriteAngle(1))*dRatio#*effVelo#
		
		if moveGuide = 1
			lineSX = GetSpriteX(1)+GetSpriteWidth(1)/2
			lineSY = GetSpriteY(1)+GetSpriteHeight(1)/2+planetHeight#*(roomHeight*25*dRatio#)/1000.0
			lineSTheta = GetSpriteAngle(1)
			DrawLine(lineSX-1, lineSY-1, lineSX+w*cos(lineSTheta)-1, lineSY+h*sin(lineSTheta)-1, 255, 225, 0)
			DrawLine(lineSX, lineSY, lineSX+w*cos(lineSTheta), lineSY+h*sin(lineSTheta), 255, 255, 0)
			DrawLine(lineSX+1, lineSY+1, lineSX+w*cos(lineSTheta)+1, lineSY+h*sin(lineSTheta)+1, 255, 225, 0)
		endif
	endif
	//Make a line going verticle to jeb when moving
endfunction
	
global lineSX = 0
global lineSY = 0
global lineSTheta = 0
	
function RoomExplodeStart()
	PlaySound(clear, volume/3*volumeOn)
	if GetSpriteExists(2) = 0 then CreateSprite(2, 0)
	FixSpriteToScreen(2, 1)
	SetSpriteColor(2, 87, 174, 218, 255)
	if deathColor then SetSpriteColor(2, 205, 16, 26, 255)
	if GetSpriteExists(doorSprite)
		SetSpritePosition(2, GetSpriteX(doorSprite)+GetSpriteWidth(doorSprite)/2, GetSpriteY(doorSprite)+GetSpriteHeight(doorSprite)/2)
	else
		SetSpritePosition(2, w/2, h/2)
	endif
	SetSpriteDepth(2, 1)
	//SetSpriteSize(2, h/10, h/10)
	for i = 1 to 20
		SetSpriteSize(2, i*h/10, i*h/10)
		SetSpritePosition(2, GetSpriteX(2)-h/20, GetSpriteY(2)-h/20)
		if planetNum <> 0 
			//SetSpriteColorAlpha(1, 0)
			//for i = 11 to 13
			//	SetSpriteColorAlpha(i, 0)
			//next i
			MoveJeb()
			RoomUpdate()
		endif
		Sleep(6)
		Sync()
	next i
endfunction

function RoomExplodeEnd()
	SetSpriteDepth(2, 1)
	//SetSpritePosition(2, GetSpriteX(doorSprite)+GetSpriteHeight(doorSprite)/2-GetSpriteWidth(2)/2, GetSpriteY(doorSprite)+GetSpriteHeight(doorSprite)/2-GetSpriteHeight(2)/2)
	for i = 1 to 15
		//SetSpriteSize(2, (15-i)*h/10, (15-i)*h/10)
		//SetSpritePosition(2, GetSpriteX(2)+h/20, GetSpriteY(2)+h/20)
		SetSpriteColorAlpha(2, 255-17*i)
		if planetNum <> 0  
			//SetSpriteColorAlpha(1, 255)
			MoveJeb()
			RoomUpdate()
		endif
		//Sleep(4)
		if planetNum = 2 then Planet2Scroll()
		if planetNum = 4 then Planet4Scroll()
		Sync()
	next i
endfunction

function RoomExplodeStart4()
	
	if GetSpriteExists(202) = 0 then CreateSprite(202, 0)
	SetSpriteDepth(202, 3)
	//SetSpriteColor(202, 87, 174, 218, 255)
	SetSpriteColor(202, 222, 0, 21, 255)
	SetSpritePosition(202, 0, GetSpriteY(2012))
	
	//SetSpriteSize(2, h/10, h/10)
	for i = 1 to 20
		SetSpriteSize(202, i*h/20, i*h/20)
		
		
		if Mod(roomsCleared, 4) = 0 then SetSpritePosition(202, 0, GetSpriteY(202)-h/20)
		if Mod(roomsCleared, 4) = 2 then SetSpritePosition(202, GetSpriteX(202)-h/20, GetSpriteY(202))
		if Mod(roomsCleared, 4) = 3 then SetSpritePosition(202, GetSpriteX(202)-h/20, GetSpriteY(202)-h/20)
		
		//SetSpritePosition(2, GetSpriteX(2)-h/20, GetSpriteY(2)-h/20)
	
			MoveJeb()
			RoomUpdate()
			Planet4Scroll()
			
			
		//Sleep(3)
		Sync()
	next i
endfunction

function RoomExplodeEnd4()
	SetSpriteDepth(202, 3)
	
	for i = 1 to 15
		
		SetSpriteColorAlpha(202, 255-17*i)
		MoveJeb()
		RoomUpdate()
		
		Sleep(2)
		Planet4Scroll()
		Sync()
	next i
endfunction

function JebProgressUpdate()
	if GetSpriteExists(11) = 0
		CreateSprite(11, 0)
		SetSpriteSize(11, w/2, 20*dRatio#)
		SetSpriteColor(11, 220, 220, 220, 255)
		SetSpritePosition(11, w/4, 8*dRatio#)
		FixSpriteToScreen(11, 1)
	endif
	if GetSpriteExists(12) = 0
		CreateSprite(12, 0)
		SetSpriteSize(12, w/2-6*dRatio#, 14*dRatio#)
		SetSpriteColor(12, 50, 50, 50, 255)
		SetSpritePosition(12, w/4+3*dRatio#, 11*dRatio#)
		FixSpriteToScreen(12, 1)
	endif
	
	if (planetNum = 2 or planetNum = 4) and GetSpriteExists(8) = 0
		CreateSprite(8, 0)
		SetSpriteSize(8, 30*dRatio#, 30*dRatio#)
		//SetSpriteColor(8, 50, 50, 50, 255)
		SetSpriteImage(8, LoadImage("lives3.png"))
		SetSpritePosition(8, 10*dRatio#, 10*dRatio#)
		FixSpriteToScreen(8, 1)
	endif
	
	SetSpriteSize(12, (roomsCleared)*(w/2-6*dRatio#)/30, 14*dRatio#)
	
	if planetNum = 2 then SetSpriteSize(12, (roomsCleared)*(w/2-6*dRatio#)/25, 14*dRatio#)
	if planetNum = 4 then SetSpriteSize(12, (roomsCleared)*(w/2-6*dRatio#)/20, 14*dRatio#)
	
	if planetNum = 5 then SetSpriteSize(12, (1.0*endlessLeft/endlessMax)*(w/2-6*dRatio#), 14*dRatio#)
	if planetNum = 6
		SetSpriteSize(12, (w/2-6*dRatio#) - (1.0*GetMusicPositionOGG(12)/GetMusicDurationOGG(12)*(w/2-6*dRatio#)), 14*dRatio#)
		
	endif
	
	if GetSpriteExists(13) = 0
		CreateSprite(13, LoadImage("jebSmall.png"))
		SetSpriteSize(13, 20*dRatio#, 15*dRatio#)
		FixSpriteToScreen(13, 1)
	endif
	SetSpritePosition(13, GetSpriteX(12)+GetSpriteWidth(12)-GetSpriteWidth(13)+5*dRatio#, GetSpriteY(12)+GetSpriteHeight(12)/2-GetSpriteHeight(13)/2)
	
	
	SetSpriteDepth(11, 2)
	SetSpriteDepth(12, 2)
	SetSpriteDepth(13, 2)
endfunction

function EffectText()
	tempSTR$ = ""
	
	if GetSpriteExists(14) = 0 then CreateSprite(14, 0)
	if GetSpriteExists(15) = 0 then CreateSprite(15, 0)
	SetSpriteImage(14, LoadImage("jebBlank.png"))
	
	if (roomsCleared <= 15) or (Random(1,2) = 1) or (planetNum <> 1)
		max = 4
		if planetNum = 2 then max = 6
		if planetNum = 4 or planetNum = 5 or planetNum = 6 then max = 5
		effect = RandomWONum(1, max, effect)
		if effect = 1
			tempSTR$ = "Rotation Speed UP!"
			effRotSpeed# = effRotSpeed# + .15
		elseif effect = 2
			tempSTR$ = "Speed UP!"
			effVelo# = effVelo# + .15
		elseif effect = 3
			tempSTR$ = "Bounce UP!"
			effBounce# = effBounce# + .12
		elseif effect = 4
			tempSTR$ = "Reverse Rotation!"
			effRotReverse = effRotReverse * -1
		elseif effect = 6
			if planetNum = 2
				tempSTR$ = "Scroll Speed UP!"
				effScrollSpeed# = effScrollSpeed# + .15
			endif
		elseif effect = 5
			tempSTR$ = "Darkness UP!"
			effDark = effDark + 45
			SetSpriteImage(15, LoadImage("particle1.png"))
			if effDark > 225
				tempSTR$ = "Speed UP!"
				effDark = 225
				effVelo# = effVelo# + .15
				effect = 2
				SetSpriteImage(15, asteroid)
			endif
		endif
		if effect <> 5 then SetSpriteImage(15, asteroid)
	else
		effect = 4 + Random(1,2)
		if planetNum = 2 or planetNum = 3 then effect = 6
		if effect = 5
			tempSTR$ = "Wind UP!"
			effWind# = effWind# + 10
			SetSpriteImage(15, asteroid)
		elseif effect = 6
			tempSTR$ = "Darkness UP!"
			effDark = effDark + 45
			SetSpriteImage(15, LoadImage("particle1.png"))
			if effDark > 225
				tempSTR$ = "Speed UP!"
				effDark = 225
				effVelo# = effVelo# + .15
				effect = 2
				SetSpriteImage(15, asteroid)
			endif
		endif
		
	endif
	
	//Fixes the animation for later levels
	if planetNum > 1 and effect = 5 then effect = 6
	
	//Sets physics effects
	SetSpritePhysicsRestitution(1, .4*effBounce#)
	SetPhysicsGravity(effWind#/2.0*dRatio#, 0)
	SetSpriteColorAlpha(3, effDark)
	SetSpriteDepth(3, 2)
	
	
	
	if effWind# <> 0
		if GetParticlesExists(1) = 0
			CreateParticles(1, 0, 0)
			SetParticlesImage(1, LoadImage("particle1.png"))
			SetParticlesStartZone(1, -20, 10*dRatio#, -10, h-10*dRatio#)
			SetParticlesAngle(1, 18)
			SetParticlesLife(1, 10)
			SetParticlesSize(1, 5*dRatio#)
			AddParticlesColorKeyFrame(1, 0, 0, 200, 20, 200)
		endif
		SetParticlesFrequency(1, effWind#/3.0)
		SetParticlesDirection(1, effWind#*3*dRatio#, 0)
	endif
	
	//Sets new background size
	SetSpriteSize(4, GetSpriteWidth(4)+backgroundIncSize, GetSpriteHeight(4)+backgroundIncSize)
	SetSpritePosition(4, w/2-GetSpriteWidth(4)/2, h/2-GetSpriteHeight(4)/2)
	SetSpriteSize(5, GetSpriteWidth(5)+planetIncSize, GetSpriteHeight(5)+planetIncSize)
	SetSpritePosition(5, w/2-GetSpriteWidth(5)/2, h/2-GetSpriteHeight(5)/2)
	
	if GetTextExists(2) = 1 then DeleteText(2)
	CreateText(2, tempSTR$)
	SetTextSize(2, 19.0*dRatio#)
	SetTextColor(2, 10, 10, 10, 255)
	SetTextPosition(2, w/2-GetTextSize(2)-2, 2*h/5+15*dRatio#)
	SetTextFontImage(2, mainFont)
	SetTextDepth(2, 1)
	if GetSpriteExists(16) = 0
		CreateSprite(16, 0)
		SetSpriteSize(16, w, 45*dRatio#)
		SetSpritePosition(16, 0, 2*h/5)
		SetSpriteColor(16, 20, 20, 20, 255)
		FixSpriteToScreen(16, 1)
		CreateSprite(17, 0)
		SetSpriteSize(17, w, 35*dRatio#)
		SetSpritePosition(17, 0, 2*h/5+5*dRatio#)
		SetSpriteColor(17, 230, 230, 230, 255)
		FixSpriteToScreen(17, 1)
	endif
	SetSpriteDepth(16, 1)
	SetSpriteColorAlpha(16, 255)
	SetSpriteDepth(17, 1)
	SetSpriteColorAlpha(17, 255)
	
	FixSpriteToScreen(14, 1)
	FixSpriteToScreen(15, 1)
	FixTextToScreen(2, 1)
	for i = -50 to 50
		if planetNum = 6 then i = 50
		//SetTextPosition(2, 0, (h/2+(i/3.0)^3.0+1.3*i)*h/960.0)
		SetTextX(2, dRatio#*((i/8.0)^3.0)+(i/6)+w/4-30*dRatio#)
		
		if Mod(planetNum, 2) = 1 then AnimateChange(effect, i/2.0)
		
		//https://graphsketch.com/
		//Sleep(1)
		MoveJeb()
		RoomUpdate()
		Sync()
		
		if planetNum = 2 then Planet2Scroll()
		if planetNum = 4 then Planet4Scroll()
		
		
	next i
	
	SetTextColorAlpha(2, 0)
	SetSpriteColorAlpha(16, 0)
	SetSpriteColorAlpha(17, 0)
	
endfunction

function AnimateChange(effNum, stepNum#)
	if stepNum# = -25
		SetSpriteSize(14, 45*dRatio#, 32*dRatio#)
		SetSpriteDepth(14, 1)
		SetSpriteColorAlpha(14, 255)
		SetSpritePosition(14, w/2-GetSpriteWidth(14)/2, 2*h/3)
		if effNum = 2 then SetSpriteX(14, w/2-75*dRatio#-GetSpriteWidth(14))
		if effNum = 3 then SetSpriteX(14, w/3-GetSpriteWidth(14))
		SetSpriteSize(15, 35*dRatio#, 35*dRatio#)
		SetSpriteDepth(15, 1)
		SetSpriteColor(15, 0, 0, 0, 255)
	endif
	
	if effNum = 1		//Rot Speed Up
		//Jeb
		SetSpriteAngle(14, stepNum#*4)
		if stepNum# > 0
			SetSpriteAngle(14, stepNum#*7)
			SetSpriteX(14, GetSpriteX(14)-1.0*dRatio#)
		endif
		//Asteroid
		SetSpritePosition(15, w/2+10*dRatio#, 3*h/4-50*dRatio#+stepNum#*dRatio#)
		if stepNum# > 0 then SetSpriteX(15, w/2+(10+stepNum#)*dRatio#)
		SetSpriteAngle(15, stepNum#/2)
	elseif effNum = 2	//Speed Up
		//Jeb
		SetSpriteAngle(14, stepNum#*4)
		SetSpriteX(14, GetSpriteX(14)+1*dRatio#)
		if stepNum# > 0 then SetSpriteX(14, GetSpriteX(14)+1*dRatio#)
		//Asteroid
		SetSpritePosition(15, w/3+(5+stepNum#*3)*dRatio#-10*dRatio#, 3*h/4-(4+stepNum#)*dRatio#-10*dRatio#)
		if stepNum# > 0 then SetSpriteX(15, w/3+(5-stepNum#/2.0)*dRatio#-10*dRatio#)
		SetSpriteAngle(15, stepNum#/2)
	elseif effNum = 3	//Bounce Up
		//Jeb
		SetSpriteAngle(14, stepNum#*4)
		SetSpriteX(14, GetSpriteX(14)+1.55*dRatio#)
		if stepNum# > 0 then SetSpriteX(14, GetSpriteX(14)-2.5*dRatio#)
		//Asteroid
		SetSpritePosition(15, 3*w/5-2*dRatio#-10*dRatio#, 2*h/3+5*dRatio#)
		SetSpriteAngle(15, stepNum#/2)
		if stepNum# > 0 then SetSpriteX(15, 3*w/5+(-2+stepNum#)*dRatio#-10*dRatio#)
	elseif effNum = 4	//Reverse Rotation
		//Jeb
		SetSpriteAngle(14, stepNum#*5+30)
		if stepNum# > 0 then SetSpriteAngle(14, -stepNum#*6+30)
		//Asteroid
		SetSpritePosition(15, w/2+(2-stepNum#/3.0)*dRatio#, 3*h/4-stepNum#/2.0*dRatio#-10*dRatio#)
		if stepNum# > 0 then SetSpritePosition(15, w/2+(2+stepNum#)*dRatio#, 3*h/4+stepNum#*dRatio#-10*dRatio#)
		SetSpriteAngle(15, stepNum#/2)
	elseif effNum = 5	//Wind Up
		//SetSpriteColorAlpha(15, 0)
		SetSpriteAngle(14, stepNum#*4+90)
		SetSpriteX(14, GetSpriteX(14)+(stepNum#+25)/5.0)
		SetSpriteX(15, GetSpriteX(15)+(stepNum#+25)/5.0)
		//if stepNum# = 25 then SetParticlesDirection(1, effWind#*3*dRatio#, 0)
	elseif effNum = 6	//Darkness Up
		SetSpriteAngle(14, stepNum#*5+90)
		SetSpriteColorAlpha(15, (stepNum#+50)*5)
		//Make particle bigger, center it on jeb
		SetSpriteSize(15, (40+stepNum#)*3*dRatio#, (40+stepNum#)*3*dRatio#)
		SetSpritePosition(15, GetSpriteX(14)+GetSpriteWidth(14)/2-GetSpriteWidth(15)/2, GetSpriteY(14)+GetSpriteHeight(14)/2-GetSpriteHeight(15)/2)
	endif
	
	if Abs(stepNum#) > 19
		SetSpriteColorAlpha(14, (25-Abs(stepNum#))*45)
		SetSpriteColorAlpha(15, (25-Abs(stepNum#))*45)
	endif
	
endfunction

function MusicStart(songNum)
	SetMusicSystemVolumeOGG(volume*volumeOn)
	for i = 2 to 12
		if GetMusicPlayingOGG(i) then StopMusicOGG(i)
	next i
	
	loopActive = 0
	if planetNum = 6
		PlayMusicOGG(songNum)
	elseif planetNum <> 3 and planetNum <> 4
		PlayMusicOGG(songNum, 1)
	else
		PlayMusicOGG(songNum)
	endif
	
	if songNum = 3
		PlayMusicOGG(4, 1)
		PlayMusicOGG(5, 1)
	endif
	
endfunction

function MusicUpdate(rc)
	//SetMusicSystemVolumeOGG(volume*volumeOn)
	for i = 3 to 12 //For each song volume
		if GetMusicPlayingOGG(i) then SetMusicVolumeOGG(i, volume*volumeOn)
	next i
	if planetNum = 1 //and rc = 1
		SetMusicVolumeOGG(LunarLalaA, volume*volumeOn)
		SetMusicVolumeOGG(LunarLalaB, 10*(roomsCleared-5)*volume/100.0*volumeOn)
		SetMusicVolumeOGG(LunarLalaC, 10*(roomsCleared-15)*volume/100.0*volumeOn)
	endif
	if planetNum = 3 and GetMusicPlayingOGG(7) = 0 and loopActive = 0
		PlayMusicOGG(8, 1)
		loopActive = 1
	endif
	if planetNum = 4 and GetMusicPlayingOGG(9) = 0 and loopActive = 0
		PlayMusicOGG(10, 1)
		loopActive = 1
	endif
endfunction

function Planet2Scroll()
	heightMult# = 1
	if GetSpriteYByOffset(1) < h/4+GetViewOffsetY() then heightMult# = (h/4.0)/(GetSpriteYByOffset(1)-GetViewOffsetY())
	if heightMult# > 2 then heightMult# = 2
	planetHeight# = planetHeight# + effScrollSpeed#*heightMult#
endfunction

function Planet4Scroll()
	SetViewOffset(w*(GetSpriteX(1)-w)/(22.0*25*dRatio#*.9)+20*dRatio#, h*GetSpriteY(1)/(22.0*25*dRatio#*2.7))	//2.5 is a temp solution, find out why it works
	inc clockTime, 1
	//Make clockTime divided by a speed variable, use that for room checking
	SetSpriteAngle(41, clockTime/effClockSpeed#)
	SetSpriteAngle(42, GetSpriteAngle(41)-100)		//MAKE PLANET 4 SCROLL
	
	//Print(Atan((h/2-GetSpriteY(1))/GetSpriteX(1)))
	if GetSpriteDistance(1, 42) < 180 then inc clockTime, 1
	if GetSpriteDistance(1, 42) < 140 then inc clockTime, 1
	if GetSpriteDistance(1, 42) < 100 then inc clockTime, 1
	//if Abs(
	
	
endfunction

function PlanetFlairText()
	if GetTextExists(1001) then DeleteText(1001)
	if GetTextExists(1002) then DeleteText(1002)
	if planetSelected > planetUnlocked
		CreateText(1001, "?????")
	elseif planetSelected = 1
		CreateText(1001, "The Lunar Whirlwind")
	elseif planetSelected = 2
		CreateText(1001, "The Orbital Cluster")
	elseif planetSelected = 3
		CreateText(1001, "The Spiral Quadrant")
	elseif planetSelected = 4
		CreateText(1001, "The Clockwork Horizon")
	elseif planetSelected = 5
		CreateText(1001, "Endless: Move Limit")
		CreateText(1002, "(High Score: "+Str(planet5Score)+")")
	elseif planetSelected = 6
		CreateText(1001, "Endless: Time Limit")
		CreateText(1002, "(High Score: "+Str(planet6Score)+")")
	endif
	SetTextSize(1001, 15*dRatio#)
	SetTextFontImage(1001, mainFont)
	SetTextPosition(1001, Random(0,5)*dRatio# + 10*dRatio#, GetSpriteY(1012)+GetSpriteHeight(1012)/2-7*dRatio#)
	if GetTextExists(1002)
		SetTextY(1001, GetTextY(1001)-8*dRatio#)
		SetTextSize(1002, 15*dRatio#)
		SetTextFontImage(1002, mainFont)
		SetTextPosition(1002, Random(0,5)*dRatio# + 10*dRatio#, GetSpriteY(1012)+GetSpriteHeight(1012)/2+5*dRatio#)
	endif
endfunction

function RandomWONum(min, max, WO)
	temp = Random(min, max)
	while (temp = WO)
		temp = Random(min, max)
	endwhile
endfunction temp

function EndChecker()
	if (planetNum = 1 and roomsCleared = 30) or (planetNum = 2 and roomsCleared = 25) or (planetNum = 3 and roomsCleared = 30) or (planetNum = 4 and roomsCleared = 20) or (planetNum = 5 and endlessLeft <= 0) or (planetNum = 6 and GetMusicPlayingOGG(12) = 0) //GetMusicDurationOGG(12) <= GetMusicPositionOGG(12))
		if planetNum = 5 then planet5Score = roomsCleared
		if planetNum = 6 then planet6Score = roomsCleared
		isStageEnd = 1
	endif
endfunction

function PauseScreenSet(state)
	if state = 1
		if GetSpriteExists(71) = 0
			for i = 71 to 77
				CreateSprite(i, 0)
				FixSpriteToScreen(i, 1)
				SetSpriteDepth(i, 2)
			next i
			SetSpriteSize(71, w-40*dRatio#, h-40*dRatio#)
			SetSpritePosition(71, w/2-GetSpriteWidth(71)/2, h/2-GetSpriteHeight(71)/2)
			SetSpriteColor(71, 215, 240, 217, 255)
			SetSpriteSize(72, w-46*dRatio#, h-46*dRatio#)
			SetSpritePosition(72, w/2-GetSpriteWidth(72)/2, h/2-GetSpriteHeight(72)/2)
			SetSpriteColor(72, 81, 191, 219, 255)
			
			CreateSprite(78, LoadImage("pauseIcon.png"))
			SetSpriteSize(78, 90*dRatio#, 90*dRatio#)
			SetSpritePosition(78, w/2-GetSpriteWidth(78)/2, h/2-GetSpriteHeight(78)/2)
			SetSpriteDepth(78, 1)
			FixSpriteToScreen(78, 1)
			//CreatePauseText(4, "PAUSE", w/2, h/2)
			//SetTextSize(4, 25*dRatio#)
			//SetTextPosition(4, w/2-GetTextLength(4), h/2)
			
			//Back Button
			SetSpriteSize(75, 50*dRatio#, 50*dRatio#)
			SetSpriteImage(75, LoadImage("backArrow.png"))
			SetSpritePosition(75, GetSpriteX(72)+20*dRatio#, GetSpriteY(72)+20*dRatio#)
			
			if volumeOn = 0
				SetSpriteImage(73, LoadImage("volumeOff.png"))
			else
				SetSpriteImage(73, LoadImage("volumeOn.png"))
			endif
			SetSpriteSize(73, 64*dRatio#, 43*dRatio#)
			SetSpritePosition(73, GetSpriteX(72)+20*dRatio#, GetSpriteY(72)+GetSpriteHeight(72)-GetSpriteHeight(73)-20*dRatio#)
		
			if vibrationOn = 0
				//SetSpriteImage(74, LoadImage("vibrationOff.png"))
			else
				//SetSpriteImage(74, LoadImage("vibrationOn.png"))
			endif
			SetSpriteImage(74, LoadImage("logo.png"))
			SetSpriteSize(74, 100*dRatio#, 66*dRatio#)
			SetSpritePosition(74, GetSpriteX(72)+GetSpriteWidth(72)-GetSpriteWidth(74)-15*dRatio#, GetSpriteY(72)+GetSpriteHeight(72)-GetSpriteHeight(74)-15*dRatio#)
			
			//Until Vibration is fixed
			
		endif
		for i = 71 to 78
			SetSpriteColorAlpha(i, 255)
		next i
		
		SetSpriteImage(7, LoadImage("playButton.png"))
		SetSpriteSize(7, 50*dRatio#, 50*dRatio#)
		SetSpritePosition(7, GetSpriteX(72)+GetSpriteWidth(72)-GetSpriteWidth(7)-20*dRatio#, GetSpriteY(72)+20*dRatio#)
		//SetSpritePosition(7, 5*w/8, h/6)
		SetSpriteDepth(7, 1)	//Depth isn't working, figure out why
		
		CreatePauseText(7, "Exit Level", GetSpriteX(75)-15*dRatio#, GetSpriteY(75)+GetSpriteHeight(75)+5*dRatio#)
		CreatePauseText(5, "Volume", GetSpriteX(73), GetSpriteY(73)-GetTextSize(7)-5*dRatio#)
		CreatePauseText(6, "Vibration", GetSpriteX(74)-15*dRatio#, GetSpriteY(74)-GetTextSize(7)-5*dRatio#)
		CreatePauseText(8, "Unpause", GetSpriteX(7)-15*dRatio#, GetSpriteY(7)+GetSpriteHeight(7)+5*dRatio#)
		
		SetTextColorAlpha(6, 0)
		
		//Jeb Dissapear
		SetSpriteColorAlpha(1, 0)
	elseif state = 0
		for i = 5 to 8
			DeleteText(i)
		next i
		for i = 71 to 78
			SetSpriteColorAlpha(i, 0)
		next i
		SetSpritePosition(7, w-40*dRatio#, 10*dRatio#)
		SetSpriteImage(7, LoadImage("pauseButton.png"))
		SetSpriteDepth(7, 2)
		SetSpriteSize(7, 30*dRatio#, 30*dRatio#)
	endif
	//Jeb Dissapear
	SetSpriteColorAlpha(1, 255)
endfunction

function CreatePauseText(num, string$, x, y)
	CreateText(num, string$)
	SetTextFontImage(num, mainFont)
	SetTextSize(num, 15*dRatio#)
	SetTextPosition(num, x, y)
	SetTextDepth(num, 1)
	FixTextToScreen(num, 1)
endfunction

function LoseALife()
	deathColor = 1
	RoomExplodeStart()
	//Variable for exploding color change
	inc jebLives, -1
	
	//Add in sprite 8, put in changing code here
	if jebLives = 2 then SetSpriteImage(8, LoadImage("lives2.png"))
	if jebLives = 1 then SetSpriteImage(8, LoadImage("lives1.png"))
	
		
	RoomExplodeEnd()
	deathColor = 0
	if jebLives = 0 then ResetToMenu()
endfunction

function SaveGame()
	OpenToWrite(1, "virposaSave.txt")
	WriteInteger(1, planetUnlocked)
	WriteInteger(1, planetSelected)
	WriteInteger(1, planet5Score)
	WriteInteger(1, planet6Score)
	CloseFile(1)
endfunction

function LoadGame()
	OpenToRead(1, "virposaSave.txt")
	planetUnlocked = ReadInteger(1)
	planetSelected = ReadInteger(1)
	planet5Score = ReadInteger(1)
	planet6Score = ReadInteger(1)
	CloseFile(1)
endfunction

global doorSprite = 0

//Jeb Properties
global roomNum = 1
global roomRegion = 1
global roomsCleared = 0
global isStageEnd = 0
global endAnimation = 0

global paused = 0
global volumeOn = 1
global vibrationOn = 1

global effRotSpeed# = 1
global effVelo# = 1
global effBounce# = 1
global effRotReverse = 1
global effWind# = 0
global effDark = 0
global effScrollSpeed# = 1.1
global effClockSpeed# = 10.0

global effect = 0

global moveGuide = 0

global xOff# = 0
global yOff# = 0

global planetNum = 0
global planetHeight# = 0
global planetSelected = 1

global numSpinners = 0
global numBreakables = 0
global superSpin = 0

global clockTime = 0
global jebLives = 3
global endlessLeft = 0
global endlessMax = 0

global flormAttack = 0

global backgroundIncSize
backgroundIncSize = 17*dRatio#
global planetIncSize
planetIncSize = 21*dRatio#

global tempTheta = 0
global deathColor = 0

SetPhysicsScale(.1)
/*LoadMap()
DrawMap()
CreateJeb()*/

global volume = 80
global loopActive = 0
  
MusicStart(2)

//SPECIAL SAVE VARIABLES
global planetUnlocked = 3
global planet5Score = 0
global planet6Score = 0
LoadGame()

if planetUnlocked < 1 or planetUnlocked > 6
	planetUnlocked = 1
	planetSelected = 1
	planet5Score = 0
	planet6Score = 0
endif

//SetSyncRate(60, 0)
//SetVSync(1)

CreateSprite(1000, LoadImage("menuSpace.png"))
SetSpriteSize(1000, h, h)
FixSpriteToScreen(1000, 1)
SetSpriteX(1000, w/2-h/2)

do
    if planetNum <> 0 and isStageEnd = 0 and paused = 0
		MoveJeb()
		JebProgressUpdate()
		RoomUpdate()
	endif
	
	if planetNum = 6 then inc endlessLeft, -1
	
	/*for i = 1012 to 1000+11+16*11
		SetSpriteX(i, w/11*(Mod(i,11))*dRatio#+(w-11*(w/11))/2 + 1.0*propBlockWaveSize*cos(3.14*(propBlockWaveTimer/200)*(i/16)))
		inc propBlockWaveTimer, 10
		if propBlockWaveTimer > 600
			propBlockWaveTimer = 0
		endif.
	next i*/
	if paused = 1
		
		
	elseif isStageEnd = 1
		
		if planetNum = planetUnlocked
			if planetNum <> 6 then inc planetUnlocked, 1
			planetSelected = planetUnlocked
			SaveGame()
			if planetUnlocked = 5 then planetUnlocked = 6
		endif
		if planetNum >= 5 or planetNum = 2 or planetNum = 4
			RoomExplodeStart()
			//RoomExplodeEnd()
		endif
		ResetToMenu()
		//if endAnimation = 0
			//RoomExplodeEnd()
			//RealDeleteRoom()
			//if GetSpriteExists(3) then DeleteSprite(3)
			//SetSpriteDepth(5, 1)
			//SetSpriteSize(5, 2*w/3, 2*w/3)
			//SetSpritePosition(5, w/6, h/2-w/3)
			//SetSpriteSize(1, 10*dRatio#, 7*dRatio#)
		//elseif endAnimation < 1500
			//SetSpritePosition(1, endAnimation/4.0*dRatio#, h/4+endAnimation/6.0*dRatio#)
		//endif
		//inc endAnimation, 1
		
	elseif planetNum = 0
		maxPlanets = 6
		
		
		//For initial setup, drawing planets
		if GetSpriteExists(1001) = 0
			
			//CreateSprite(99999, 0)
			//SetSpriteSize(99999, w/3,h)
			//SetSpritePosition(99999, w/3, 0)
			
			for i = 1 to maxPlanets	//Make more for i when there are more planets
				CreateSprite(1000+i, LoadImage("tempPlanet.png"))
				SetSpriteSize(1000+i, w/3.5, w/3.5)
				//SetSpritePosition(1000+i, (Mod(i-1,2)+1)*w/3-GetSpriteWidth(1000+i)/2, h/8+h/3*((i-1)/2)) //For Quick Testing
				SetSpritePosition(1000+i, w/9, w/9+h/4*((i-1)/2))
				if Mod(i,2) = 0 then SetSpriteX(1000+i, w-GetSpriteWidth(1000+i)-w/9)
				//SetSpritePosition(1000+i, w/2, h/2-GetSpriteHeight(1000+i)/2-h*(i-1))
				if i = 1 then SetSpriteColor(1000+i,  0, 255, 0, 255)
				if i = 2 then SetSpriteColor(1000+i, 255, 0, 255, 255)
				if i = 3 then SetSpriteColor(1000+i, 0, 255, 255, 255)
				if i = 4 then SetSpriteColor(1000+i, 255, 0, 0, 255)
				if i = 5 then SetSpriteColor(1000+i, 255, 255, 0, 255)
				//if i = 6 then SetSpriteColor(1000+i, 105, 250, 220, 255)
				if i = 6 then SetSpriteColor(1000+i, 50, 100, 205, 255)
			next
			for i = planetUnlocked+1 to 6
				tempS = 1020+i
				CreateSprite(tempS, LoadImage("lock.png"))
				SetSpriteSize(tempS, 20*dRatio#, 30*dRatio#)
				SetSpritePosition(tempS, GetSpriteX(1000+i)+GetSpriteWidth(1000+i)/2-GetSpriteWidth(tempS)/2, GetSpriteY(1000+i)+GetSpriteHeight(1000+i)/2-GetSpriteHeight(tempS)/2)
				if i = 2 then SetSpriteColor(tempS,  0, 255, 0, 255)
				if i = 3 then SetSpriteColor(tempS, 255, 0, 150, 255)
				if i = 4 then SetSpriteColor(tempS, 0, 255, 255, 255)
				if i = 5 then SetSpriteColor(tempS, 255, 0, 0, 255)
				if i = 6 then SetSpriteColor(tempS, 255, 0, 0, 255)
			next i
			
			tempS = 1000+planetSelected
			CreateSprite(1010, LoadImage("jeb.png"))
			SetSpriteSize(1010, 20*dRatio#, 14*dRatio#)
			SetSpritePosition(1010, GetSpriteX(tempS)+GetSpriteWidth(tempS)/2-GetSpriteWidth(1010)/2, GetSpriteY(tempS)+GetSpriteHeight(tempS)/2-GetSpriteHeight(1010)/2)
			
			CreateSprite(1011, 0)
			SetSpriteSize(1011, w, h/6)
			SetSpritePosition(1011, 0, h-GetSpriteHeight(1011))
			SetSpriteColor(1011, 81, 191, 219, 255)
			
			CreateSprite(1012, 0)
			SetSpriteSize(1012, w-10*dRatio#, h/6-10*dRatio#)
			SetSpritePosition(1012, GetSpriteX(1011)+5*dRatio#, GetSpriteY(1011)+5*dRatio#)
			
			SetSpriteColor(1012, 45, 143, 171, 255)
			
			//Button for planet go
			CreateSprite(1013, 0)
			SetSpriteSize(1013, w/7.0, w/7.0)
			SetSpritePosition(1013, w-GetSpriteWidth(1013)-10*dRatio#, GetSpriteY(1012)+GetSpriteHeight(1012)/2-GetSpriteHeight(1013)/2) //Make the position better
			SetSpriteImage(1013, LoadImage("goButton.png"))
			PlanetFlairText()
			
		endif
		
		SetSpriteAngle(1010, GetSpriteAngle(1010)+2)
		
		//Button checking for each planet
		for i = 1 to maxPlanets
			if GetPointerPressed() = 1 and GetSpriteHitTest(1000+i, GetPointerX(), GetPointerY()+GetViewOffsetY())
				planetSelected = i
				PlanetFlairText()
				SaveGame()
				if planetSelected > planetUnlocked
					SetSpriteColorAlpha(1013, 0)
				else
					SetSpriteColorAlpha(1013, 255)
				endif
			endif
		next i
		//Jeb repositioning
		tempS = 1000+planetSelected
		SetSpritePosition(1010, (5*GetSpriteX(1010)+GetSpriteX(tempS)+GetSpriteWidth(tempS)/2-GetSpriteWidth(1010)/2)/6, (5*GetSpriteY(1010)+GetSpriteY(tempS)+GetSpriteHeight(tempS)/2-GetSpriteHeight(1010)/2)/6)
		if GetPointerPressed() = 1 and GetSpriteHitTest(1013, GetPointerX(), GetPointerY()+GetViewOffsetY()) and GetSpriteColorAlpha(1013) = 255
			planetNum = planetSelected
		endif
		
		//Deleting planet images
		if planetNum <> 0
			tempP = planetNum
			planetNum = 0
			RoomExplodeStart()
			planetNum = tempP
			for i = 0 to maxPlanets
				DeleteSprite(1000+i)
			next i
			for i = 1010 to 1013
				DeleteSprite(i)
			next i
			DeleteText(1001)
			if GetTextExists(1002) then DeleteText(1002)
			SetViewOffset(0, 0)
			LoadMap()
			DrawMap()
			CreateJeb()
			
			//Pause Button
			CreateSprite(7, LoadImage("pauseButton.png"))
			SetSpriteSize(7, 30*dRatio#, 30*dRatio#)
			SetSpritePosition(7, w-40*dRatio#, 10*dRatio#)
			FixSpriteToScreen(7, 1)
			SetSpriteDepth(7, 2)
			
			planetNum = 0
			RoomExplodeEnd()
			planetNum = tempP
		endif
		
		if planetNum = 1
			MusicStart(3)
			MusicUpdate(1)
		endif
		
		if planetNum = 3 then MusicStart(7)
		
		//Specific planet 2 setup
		if planetNum = 2
			roomsCleared = -3
			LoadMap()
			DrawMap()
			roomsCleared = -2
			LoadMap()
			DrawMap()
			roomsCleared = -1
			LoadMap()
			DrawMap()
			roomsCleared = 0
			MusicStart(6)
		endif
		if planetNum = 4
			roomsCleared = -4
			LoadMap()
			DrawMap()
			roomsCleared = -3
			LoadMap()
			DrawMap()
			roomsCleared = -2
			LoadMap()
			DrawMap()
			roomsCleared = -1
			LoadMap()
			DrawMap()
			roomsCleared = 0
			clockTime = 0
			for i = 41 to 42
				CreateSprite(i, 0)
				SetSpriteSize(i, (10-5*(i-41))*dRatio#, w*1.4)
				SetSpriteImage(i, LoadImage("clockHand.png"))
				//Fix these exact values later
				SetSpritePosition(i, 20*dRatio#, -w*.4)
				SetSpriteOffset(i, 0, w*1.4)
				SetSpritePhysicsOn(i, 3)
			next i
			MusicStart(9)
		endif
		
		if planetNum = 5
			endlessMax = 150
			MusicStart(11)
		elseif planetNum = 6
			endlessMax = 1000
			MusicStart(12)
		endif
		endlessLeft = endlessMax
		
	elseif Mod(planetNum, 2) = 1 or planetNum = 6
		
		//Planet 3 spinner
		if planetNum > 2
			if superSpin = 0
				
				for i = 1 to numSpinners
					if GetSpriteColorAlpha(spinners[i]) < 255 then SetSpriteColorAlpha(spinners[i], GetSpriteColorAlpha(spinners[i])+51)
					SetSpriteAngle(spinners[i], GetSpriteAngle(spinners[i])+15)
					if GetSpriteCollision(1, spinners[i])
						superSpin = 1
						SetSpritePhysicsVelocity(1, GetSpritePhysicsVelocityX(1)*2.2, GetSpritePhysicsVelocityY(1)*2.2)
					endif
				next i
			elseif superSpin = 1
				//NOT TESTED
				for i = 1 to numSpinners
					if GetSpriteColorAlpha(spinners[i]) > 0 then SetSpriteColorAlpha(spinners[i], GetSpriteColorAlpha(spinners[i])-51)
				next i
				if numBreakables <> 0
					for i = 1 to numBreakables
						if GetSpriteExists(breakables[i])
							if GetSpriteCollision(1, breakables[i])
								PlaySound(breakSound, volume/3*volumeOn)
								inc breakables[i], 10000
								//DeleteSprite(breakables[i])
								//Add more effects
								//SetSpritePhysicsOff(breakables[i])
								//SetSpriteColorAlpha(breakables[i], 0)
							endif
						endif
					next i
				endif
			endif
			
			//Breakables fadeaway affect
			for i = 1 to numBreakables
				tSprite = breakables[i] - 10000
				if GetSpriteExists(tSprite) and tSprite > 0
					SetSpritePhysicsOff(tSprite)
					SetSpriteColorAlpha(tSprite, GetSpriteColorAlpha(tSprite)-17)
					SetSpriteSize(tSprite, GetSpriteWidth(tSprite)+(2-4*Mod(tSprite,2))*dRatio#, GetSpriteHeight(tSprite)+(2-4*Mod(tSprite,2))*dRatio#)
					if GetSpriteColorAlpha(tSprite) < 35 then DeleteSprite(tSprite)
				endif
			next i
			
		endif
		
		if planetNum >= 5 then EndChecker()
		
		//Room finishing
		if GetSpriteCollision(1, doorSprite)
			roomsCleared = roomsCleared + 1
			flormAttack = 0
			superSpin = 0
			for i = 61 to 64
				if GetSpriteExists(i) then DeleteSprite(i)
			next i
			if GetSpriteX(doorSprite) < w/2
				if GetSpriteY(doorSprite) < h/3 then roomRegion = 1
				if GetSpriteY(doorSprite) < 2*h/3 and GetSpriteY(doorSprite) > h/3 then roomRegion = 3
				if GetSpriteY(doorSprite) > 2*h/3 then roomRegion = 5
			elseif GetSpriteX(doorSprite) > w/2
				if GetSpriteY(doorSprite) < h/3 then roomRegion = 2
				if GetSpriteY(doorSprite) < 2*h/3 and GetSpriteY(doorSprite) > h/3 then roomRegion = 4
				if GetSpriteY(doorSprite) > 2*h/3 then roomRegion = 6
			endif
			MusicUpdate(1)
			RoomExplodeStart()
			EndChecker()
			if isStageEnd = 0
				LevelCreate()
				EffectText()
				JebProgressUpdate()
				RoomExplodeEnd()
			endif
		endif
	elseif planetNum = 2
		Planet2Scroll()
		
		//blinkCheck = Round(Mod(planetHeight#, 500))
		//if blinkCheck = 60 then PlaySprite(1, 10, 0, 2, 3)
		//if blinkCheck = 110 then PlaySprite(1, 10, 0, 2, 3)
		
		if planetHeight# > 1000*(roomsCleared+0.5)
			LevelCreatePlanet2()
			roomsCleared = roomsCleared + 1
			EndChecker()
			if isStageEnd = 0 then EffectText()
		endif
		
		//Losing (Need to update to be better)
		//if GetSpriteYByOffset(1) > h+GetViewOffsetY()
		if GetSpriteCollision(1, 19)
			//Maybe add check for what room they are stuck on
			planetHeight# = 1000*(roomsCleared-0.5)
			SetViewOffset(0, 0-planetHeight#*(roomHeight*25*dRatio#)/1000.0)
			SetSpritePosition(1, w/2-GetSpriteWidth(1)/2, h/2 + GetViewOffsetY())
			LoseALife()
		endif
	
	elseif planetNum = 4
		Planet4Scroll()
		
		if GetSpriteAngle(41)+(roomsCleared/4)*360 > 90*(roomsCleared+1)-1
			
			SetSpriteDepth(41, 2)
			SetSpriteDepth(42, 2)
			//Get First Room
			//BlueSquareThing()
			RoomExplodeStart4()
			LevelCreatePlanet2()	//Even though it says planet 2 it still works
			RoomExplodeEnd4()
			inc roomsCleared, 1
			EndChecker()
			if isStageEnd = 0 then EffectText()
			
			
		endif
		
		
		//Failing
		if GetSpriteCollision(1, 41) and clockTime > 700 and GetSpriteAngle(41) > 50
			clockTime = clockTime - 500
			LoseALife()
		elseif GetSpriteCollision(1, 41) and clockTime > 700 and GetSpriteAngle(41) > 22
			clockTime = clockTime - 200
			LoseALife()
		endif
		
		//if GetSpriteCollision(1, 42)
		//	clockTime = clockTime + 200
		//endif
		
	endif

	if GetPointerPressed() = 1 and GetSpriteExists(7)
		if Button(7)
			paused = Mod(paused+1, 2)
			PauseScreenSet(paused)
			SetSpriteColorAlpha(1, 255*(1-paused))
		endif
		if paused = 1
			if Button(73) //Volume Button
				volumeOn = Mod(volumeOn+1, 2)
				MusicUpdate(0)
				if volumeOn = 0
					SetSpriteImage(73, LoadImage("volumeOff.png"))
				else
					SetSpriteImage(73, LoadImage("volumeOn.png"))
				endif
			endif
			if Button(74) //Vibration Button
				vibrationOn = Mod(vibrationOn+1, 2)
				//if vibrationOn then VibrateDevice(.008)
				if vibrationOn = 0
				//	SetSpriteImage(74, LoadImage("vibrationOff.png"))
				else
				//	SetSpriteImage(74, LoadImage("vibrationOn.png"))
				endif
			endif
			if Button(75) // Back Button
				//RoomExplodeStart()
				planetSelected = planetNum
				paused = 0
				PauseScreenSet(paused)
				ResetToMenu()
				//RoomExplodeEnd()
			endif
		endif
	endif
	
	if GetSpriteExists(1)
		inc blinkCheck, 1
		blinkCheck = Mod(blinkCheck, 350)
		if blinkCheck = 60 then PlaySprite(1, 10, 0, 2, 3)
		if blinkCheck = 110 then PlaySprite(1, 10, 0, 2, 3)
	endif
	
	if planetNum <> 0 and planetNum <> 1 then MusicUpdate(0)
    //Print(ScreenFPS())
    //Print(h)
    
    //SetVSync(1)
    
    Sync()
loop



//Lives system level 2 & 4
//Level 4 clock graphics
//Finish music for Endless
//Sound effects for planet select & movable asteroid



//Assure volume on/off even at start of program running

//FINISHED
//Level 1 music
//Selection screen go button
//Finish music for Level Select
//Set music for each area
//Planets with colored locks
//WINDY MENACE


//Level 3 asteroid weight EHH not to bad i guess????


//AR Destine
