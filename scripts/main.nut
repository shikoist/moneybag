/*
Moneybag Deathmatch Script for VCMP 0.4 by shikoist
There is a few businesses, which repeatedly grows money.
Three Ammunations, where you can buy weapons.
Who has most money, will be a target.
Killer takes all money from victim.
*/

adminpass <- "";

//BizTime <- 5000;
BizTime <- 6; //Respawn money biz in minutes
BizTime *= 60 * 1000;

MoneyBagPlayer <-0;

MAX_BIZ <- 8;
MAX_WEAP_PICKUPS <- 17;
CurrentWeaponPickup <- 0;

MAX_COLORS <- 8;
colors <- [
	RGB(255,0,  0  ), //red
	RGB(255,100,0  ), //orange
	RGB(255,255,0  ), //yellow
	RGB(255,20, 220), // pink
	RGB(0,  255,0  ), //green
	RGB(0,  150,255), //blue
	RGB(0,  255,255),
	RGB(20, 100,255)
];

players <- {};

class Biz
{
	name = null;
	pickup = null;
	marker = 0;
	markerID = 0;
	value = 0;
	x = 0;
	y = 0;
	z = 0;
}

class WeaponPickup
{
	name = "";
	cost = 0;
	modelID = 0;
	ammo = 0;
	weaponID = 0;
	x = 0;
	y = 0;
	z = 0;
}

local   SRV_NAME = GetServerName(),
        SRV_PASS = GetPassword();
        
// Creating a connection between client and server scripts
// I'm using bytes for identification, because they are the most waste-less for the designated task
// This must be the same in both, client-side and server-side.
enum StreamType
{
    ServerName = 0x01
}

// =========================================== S E R V E R   E V E N T S ==============================================

function onScriptLoad()
{
	// server info is printed in the console
    print( "------------------------------------" );
    print( "Server name: " + SRV_NAME );
    if( SRV_PASS != "" ) print( "Password: " + SRV_PASS );
    print( "------------------------------------" );
	
	isAdmin <- array(GetMaxPlayers(), null);

	BizList <- array(MAX_BIZ, null);
	for (local i = 0; i < MAX_BIZ; i++)
	{
		BizList[i] = Biz();
	}
	
	WeaponPickups <- array(MAX_WEAP_PICKUPS, null);
	for (local i = 0; i < MAX_WEAP_PICKUPS; i++)
	{
		WeaponPickups[i] = WeaponPickup();
	}
	
	dofile("scripts/vehicles.nut", true);
	CreateVehicles();
	
	//Init Biz
	//number name value markerID x y z
	SetBiz(0, "Malibu Club",       4000, 13,  493.582, -76.9979, 11.4838);
	SetBiz(1, "Pole Position",     2000, 20,  93.4673, -1472.28, 10.4318);
	SetBiz(2, "Boatyard",          2000, 12, -647.5,   -1497.64, 12.5602);
	SetBiz(3, "Ice Cream Factory",  500, 21, -863.452, -566.209, 11.1069);
	SetBiz(4, "Sunshine Autos",    2000, 26, -1019.25, -910.857, 14.4791);
	SetBiz(5, "Print Works",       1500, 24, -1058.44, -285.999, 11.2304);
	SetBiz(6, "Kaufman Cabs",      1500, 22, -1013.43,  193.993, 11.2605);
	SetBiz(7, "Film Studio",       3500, 15,  15.5011,  967.463, 10.9542);
	
	for (local i = 0; i < MAX_BIZ; i++)
	{
		BizList[i].pickup = CreatePickup(408, 0, BizList[i].value, Vector(BizList[i].x, BizList[i].y, BizList[i].z), 255, false);
		BizList[i].pickup.Timer = BizTime;
		BizList[i].marker = CreateMarker(0, Vector(BizList[i].x, BizList[i].y, BizList[i].z), 1, RGB(0, 0, 0), BizList[i].markerID);
	}
	
	//Init Weapon Shop
	//Ocean Beach Ammunation
	//SetWeaponPickup("Health",      200,  1,   366,  0,  -57.4166, -1490.0, 10.441);
	SetWeaponPickup("Colt 45",       100,  30,  274,  17, -57.4166, -1485.0, 10.441);
	SetWeaponPickup("Ingram Mac 10", 300,  100, 283,  24, -57.4166, -1482.5, 10.441);
	SetWeaponPickup("Shotgun",       500,  10,  277,  19, -57.4166, -1480.0, 10.441);
	SetWeaponPickup("Ruger",         1000, 50,  276,  27, -57.4166, -1477.5, 10.441);
	SetWeaponPickup("Armour",        200,  1,   368,  0,  -57.4166, -1475.0, 10.441);
	
	//Mall Ammunation
	//SetWeaponPickup("Health",       200,  1,   366,  0,  372.24, 1050.0, 19.22);
	SetWeaponPickup("Colt 45",        100,  30,  274,  17, 372.24, 1052.5, 19.22);
	SetWeaponPickup("Uzi 9mm",        400,  100, 282,  23, 372.24, 1055.0, 19.22);
	SetWeaponPickup("Stubby Shotgun", 600,  10,  279,  21, 372.24, 1057.5, 19.22);
	SetWeaponPickup("Sniper Rifle",   1500, 10,  285,  28, 372.24, 1060.0, 19.22);
	SetWeaponPickup("Grenades",       300,  1,   270,  12, 372.24, 1062.5, 19.22);
	SetWeaponPickup("Armour",         200,  1,   368,  0,  372.24, 1065.0, 19.22);
	
	//Downtown Ammunation
	//SetWeaponPickup("Health",           200,  366, 1,    0,  -682.5, 1197.57, 11.0712);
	SetWeaponPickup("Python",             2000, 30,  275,  18, -680.0, 1197.57, 11.0712);
	SetWeaponPickup("MP5",                3000, 100, 284,  25, -677.5, 1197.57, 11.0712);
	SetWeaponPickup("SPAS",               4000, 10,  278,  20, -675.0, 1197.57, 11.0712);
	SetWeaponPickup("M4",                 5000, 50,  280,  26, -672.5, 1197.57, 11.0712);
	SetWeaponPickup("Laser Sniper Rifle", 6000, 10,  286,  29, -670.0, 1197.57, 11.0712);
	SetWeaponPickup("Armour",             200,  1,   368,  0,  -667.5, 1197.57, 11.0712);
	
	for (local i = 0; i < MAX_WEAP_PICKUPS; i++)
	{
		local p = CreatePickup(WeaponPickups[i].modelID, 0, WeaponPickups[i].ammo, Vector(WeaponPickups[i].x, WeaponPickups[i].y, WeaponPickups[i].z), 255, false);
		p.Timer = 5000;
	}
	
	//Map Pickups
	//Colt 45 North Ammo spawn point
	local p = CreatePickup(274, 0, 30, Vector(-901.622, 788.264, 11.0911), 255, true);
	p.Timer = 120000;
	
	//Colt 45 Diaz Mansion Spawn Point
	local p = CreatePickup(274, 0, 30, Vector(-348.244, -541.613, 17.2831), 255, true);
	p.Timer = 120000;
	
	//Colt 45 - south spawn point
	local p = CreatePickup(274, 0, 30, Vector(182.848, -846.482, 10.4318), 255, true);
	p.Timer = 120000;
	
	//Ammunations Markers
	CreateMarker(0, Vector(-672.336, 1197.57, 11.0712), 1, RGB(0, 0, 0), 16); //North
	CreateMarker(0, Vector(-57.4166, -1492.51, 10.441), 1, RGB(0, 0, 0), 16); //South
	CreateMarker(0, Vector(371.868, 1056.57, 19.1673), 1, RGB(0, 0, 0), 16); //Mall
			
	//Start Timer for updating scores
	NewTimer("UpdateScores", 1000, 0);
	
	SetSpawnCameraPos(-409.018, -584.424, 41.0443);
	SetSpawnCameraLook(-409.018, -587.424, 39.0443);
	
	SetSpawnPlayerPos(-409.018, -587.424, 39.0443);
	
	AddClass(  1, RGB( 127, 127, 127 ),  0, Vector( -378.79, -537.962, 17.2832 ), 140.020, 0, 0, 0, 0, 0, 0 );
	AddClass(  2, RGB( 127, 127, 127 ),  1, Vector( -378.79, -537.962, 17.2832 ), 140.020, 0, 0, 0, 0, 0, 0 );
	AddClass(  3, RGB( 127, 127, 127 ),  2, Vector( -378.79, -537.962, 17.2832 ), 140.020, 0, 0, 0, 0, 0, 0 );
	AddClass(  4, RGB( 127, 127, 127 ),  3, Vector( -378.79, -537.962, 17.2832 ), 140.020, 0, 0, 0, 0, 0, 0 );
	AddClass(  5, RGB( 127, 127, 127 ),  4, Vector( -378.79, -537.962, 17.2832 ), 140.020, 0, 0, 0, 0, 0, 0 );
	AddClass(  6, RGB( 127, 127, 127 ),  9, Vector( -378.79, -537.962, 17.2832 ), 140.020, 0, 0, 0, 0, 0, 0 );
	AddClass(  7, RGB( 127, 127, 127 ), 22, Vector( -378.79, -537.962, 17.2832 ), 140.020, 0, 0, 0, 0, 0, 0 );
	AddClass(  8, RGB( 127, 127, 127 ), 31, Vector( -378.79, -537.962, 17.2832 ), 140.020, 0, 0, 0, 0, 0, 0 );
	AddClass(  9, RGB( 127, 127, 127 ), 71, Vector( -378.79, -537.962, 17.2832 ), 140.020, 0, 0, 0, 0, 0, 0 );
	AddClass( 10, RGB( 127, 127, 127 ), 44, Vector( -378.79, -537.962, 17.2832 ), 140.020, 0, 0, 0, 0, 0, 0 );
	
	SetFriendlyFire(false);
	
	//Load admin pass
	local f = file("adminpass.txt", "rb");
	if (f != null) //file exists
	{
		while (!f.eos())
		{
			adminpass += format(@"%c", f.readn('b'));
		}
		f.close();
	} 
	// if file not exits, create default password
	// this dont works
	/*else
	{
		f = file("adminpass.txt", "wb");
		adminpass = "changeme";
		foreach (c in adminpass) // write default password in file
		{
			f.writen(c, 'b');
		}
		f.close();
	}*/
	print("Admin pass: " + adminpass);
	
	// Seed the rand() function
	srand(accurate_seed());
}
	
function SetBiz(n, name, value, markerID, x, y, z)
{
	BizList[n].name = name;
	BizList[n].value = value;
	BizList[n].markerID = markerID;
	BizList[n].x = x;
	BizList[n].y = y;
	BizList[n].z = z;
}

function SetWeaponPickup(name, cost, ammo, modelID, weaponID, x, y, z)
{
	WeaponPickups[CurrentWeaponPickup].name = name;
	WeaponPickups[CurrentWeaponPickup].cost = cost;
	WeaponPickups[CurrentWeaponPickup].ammo = ammo;
	WeaponPickups[CurrentWeaponPickup].modelID = modelID;
	WeaponPickups[CurrentWeaponPickup].weaponID = weaponID;
	WeaponPickups[CurrentWeaponPickup].x = x;
	WeaponPickups[CurrentWeaponPickup].y = y;
	WeaponPickups[CurrentWeaponPickup].z = z;
	CurrentWeaponPickup++;
}

function onScriptUnload()
{

}

function UpdateScores()
{
	/*foreach( pID, pInstance in players )
	{
		print( "Player: " + pInstance.Name + " - ID: " + pID );
	}*/

	if (GetPlayers() > 0)
	{
		for (local i = 0; i < GetPlayers(); i++)
		{
			local plr = GetPlayer(i);
			if (plr != null)
			{
				plr.Score = plr.Cash;
			}
		}
	}
	
	/*if (GetPlayers() > 0)
	{
		local maxScore = 0;
		for (local i = 0; i < GetPlayers(); i++)
		{
			local plr = GetPlayer(i);
			if (plr != null)
			{
				plr.Score = plr.Cash;
				//plr.Color = RGB(255,255,255);
				if (maxScore < plr.Cash)
				{
					maxScore = plr.Cash;
				}
			}
		}
		if (maxScore > 0)
		{
			for (local i = 0; i < GetPlayers(); i++)
			{
				local plr = GetPlayer(i);
				if (plr != null)
				{
					if (maxScore == plr.Cash)
					{
						// Now he is Money Bag;
						//plr.Color = RGB(255, 0, 0);
						if (MoneyBagPlayer != plr.ID)
						{
							Message("[#00FF00]" + plr.Name + "[#FFFFFF] now has a [#00FF00]$" + plr.Cash + "[#FFFFFF]!");
							AnnounceAll("~t~" + plr.Name + "~h~ now has a ~t~$" + plr.Cash + "~h~!", 1);
							MoneyBagPlayer = plr.ID;
						}
					}
				}
			}
		}
	}*/
}

// =========================================== P L A Y E R   E V E N T S ==============================================

function onPlayerJoin( player )
{
	players.rawset( player.ID, player );

	MessagePlayer("[#ffffff]*** Welcome to MONEYBAG by shikoist", player);
	MessagePlayer("[#ffffff]*** Rules are simple: grab money from business,", player);
	MessagePlayer("[#ffffff]*** buy weapons, kill other players,", player);
	MessagePlayer("[#ffffff]*** grab their money! You'll see scores on F5.", player);
	Announce("~h~Welcome to ~t~MONEYBAG", player, 5);
	return 1;
}

function accurate_seed()
{
	local uptime = split(clock().tostring(), ".");
	uptime = uptime.len() > 1 ? uptime[0] + uptime[1] : uptime[0];
	return uptime.tointeger();
}

function onPlayerPart( player, reason )
{
	players.rawdelete( player.ID );
	isAdmin[player.ID] = 0;
}

function onPlayerRequestClass( player, classID, team, skin )
{
	//Debug
	//player.Spawn();
	
	return 1;
}

function onPlayerRequestSpawn( player )
{
	return 1;
}

function onPlayerSpawn( player )
{
	local r = rand() % 4;
	
	if (r == 0)
	{
		player.Pos = Vector(-914.335, 736.85, 11.0846);
	}
	else if (r == 1)
	{
		player.Pos = Vector(-389.909, -535.172, 17.282);
	}
	else if (r == 2)
	{
		player.Pos = Vector(140.366, -823.93, 10.4444);
	}
	
	local r = rand() % MAX_COLORS;
	player.Colour = colors[r];
}

function onPlayerDeath( player, reason )
{
	//print("onPlayerDeath " + player.ID);
	SpawnMoneyPickups(player);
	SpawnWeaponPickups(player);
}

function onPlayerKill( killer, player, reason, bodypart )
{
	//print("onPlayerKill " + killer.ID + " " + player.ID);
	SpawnMoneyPickups(player);
	SpawnWeaponPickups(player);
}

function onPlayerTeamKill(  killer, player, reason, bodypart )
{
	//print("onPlayerTeamKill " + killer.ID + " " + player.ID);
	SpawnMoneyPickups(player);
	SpawnWeaponPickups(player);
}

function SpawnWeaponPickups(player)
{
	local veh = player.Vehicle;
	if (!veh)
	{
		for (local i = 0; i < 9; i++ )
		{
			if (player.GetWeaponAtSlot(i) != 0)
			{
				//wep[i] = { ID = player.GetWeaponAtSlot(i), Ammo = player.GetAmmoAtSlot(i) };
				
				//radius
				local radius = 5; // in meters
				local r_x = (rand() % (radius * 200) - (radius * 100))/100;
				local r_y = (rand() % (radius * 200) - (radius * 100))/100;
				
				local prx = player.Pos.x + r_x;
				local pry = player.Pos.y + r_y;
				local prz = player.Pos.z; // height of pickup
				
				local weapon = player.GetWeaponAtSlot(i);
				local ammo = player.GetAmmoAtSlot(i);
				local model;
				
				switch (weapon){
					case 12:{model = 270;break;}//Grenades
					case 17:{model = 274;break;}//Colt 45
					case 18:{model = 275;break;}//Python
					case 19:{model = 277;break;}//Shotgun
					case 20:{model = 278;break;}//Spaz Shotgun
					case 21:{model = 279;break;}//Stubby Shotgun
					case 22:{model = 281;break;}//Tec9
					case 23:{model = 282;break;}//Uzi
					case 24:{model = 283;break;}//Ingram
					case 25:{model = 284;break;}//MP5
					case 26:{model = 280;break;}//M4
					case 27:{model = 276;break;}//Ruger
					case 28:{model = 285;break;}//Sniper Rifle
					case 29:{model = 286;break;}//Laser Sniper
				}
				
				local pickup = CreatePickup(model, 0, ammo, Vector(prx, pry, prz), 255, true);
				pickup.Timer = 40000;
				NewTimer("RemovePickup", 30000, 1, pickup.ID);
			}
		}
	}
}

function SpawnMoneyPickups(player)
{
	//print("Player " + player.ID + " Cash " + player.Cash + " pos " + player.Pos.x + " " + player.Pos.y + " " + player.Pos.z);
	if (player.Cash >= 5)
	{
		// if count is not an integer, there'll be error
		local count = (player.Cash / 5.0).tointeger();
		
		for (local i = 0; i < 5; i++)
		{
			//radius 5 meters
			local radius = 4;
			local r_x = (rand() % (radius * 200) - (radius * 100))/100;
			local r_y = (rand() % (radius * 200) - (radius * 100))/100;
			
			local prx = player.Pos.x + r_x;
			local pry = player.Pos.y + r_y;
			local prz = player.Pos.z; // height of pickup
			
			//print("Random money pickups positioning " + r_x + " " + r_y);
			//print("Result " + prx + " " + pry + " " + prz);
		
			local pickup = CreatePickup(337, 0, count, Vector(prx, pry, prz), 255, false);
			pickup.Timer = 40000;
			NewTimer("RemovePickup", 30000, 1, pickup.ID);
			//print("Money Pickup Created " + pickup.ID);
		}
		player.Cash = 0;
	}
}

function RemovePickup(ID)
{
	local pickup = FindPickup(ID);
	//print("Money Pickup Removed " + pickup.ID);
	if (pickup != null)
	{
		pickup.Remove();
	}
}

function onPlayerChat( player, text )
{
	return 1;
}

function CVehicle::GetRadiansAngle() //by Gudio
{
	local angle = ::asin(this.Rotation.z) * -2;
	return this.Rotation.w < 0 ? 3.14159 - angle : 6.28319 - angle;
}

function onPlayerCommand(player, cmd, text)
{
	local p = player.ID;
	if (cmd == "adminpass" && text == adminpass) //secret command for admins
	{
		isAdmin[p] = 1;
		MessagePlayer("[#ffffff]You became an admin.", player);
	}

	if (isAdmin[p] == 1)
	{
		//goto
		if (cmd == "goto2")
		{
			if (text == "malibu")
			{
				player.Pos = Vector(493.582, -76.9979-2, 11.4838);
			}
			if (text == "northammo")
			{
				player.Pos = Vector(-670.0, 1197.57, 11.0712);
			}
			if (text == "southammo")
			{
				player.Pos = Vector(-57.4166, -1490.0, 10.441);
			}
		}
	
		// start addvehicle
		else if (cmd == "av" || cmd == "addvehicle")
		{
			if (!text)
			{
				MessagePlayer(">> Use /" + cmd + " <Model> <Col1> <Col2>", player);
			}
			else
			{
				local model = GetTok(text, " ", 1), color1 = GetTok(text, " ", 2), color2 = GetTok(text, " ", 3);
				if (!model || !color1 || !color2)
				{
					MessagePlayer( ">> Use /" + cmd + " <Model> <Col1> <Col2>", player);
				}
				else
				{
					player.Vehicle = CreateVehicle(model.tointeger(), player.World, Vector(player.Pos.x.tofloat(), player.Pos.y.tofloat(), player.Pos.z.tofloat() ), player.Angle.tofloat(), color1.tointeger(), color2.tointeger());
					Message("[#FF0000]Vehicle Created.");
				}
			}
		}
		// end addvehicle

		// start savedpositions.txt
		else if (cmd == "s" || cmd == "save")
		{
			local veh = player.Vehicle;
			local newline;
			if (!veh)
			{
				// the below script will check all player's weapons and save the first 3 the script founds
				local wep = array(3);
				wep[0] = { ID = 0, Ammo = 0 };
				wep[1] = { ID = 0, Ammo = 0 };
				wep[2] = { ID = 0, Ammo = 0 };
				local weps = 0;
				for (local i = 0; i < 9; i++ )
				{
					if (player.GetWeaponAtSlot(i) != 0 && weps < 3)
					{
						wep[weps] = { ID = i, Ammo = player.GetAmmoAtSlot(i) };
						weps++;
						if (weps == 3) break;
					}
				}
	   
				// format is AddClass( class, color, skin, position, angle, weapon1, ammo1 ,weapon2, ammo2, weapon3, ammo3);
				newline = "AddClass(" + player.Class + ", RGB(" + player.Colour.r + ", " + player.Colour.g + ", " + player.Colour.b + "), " + player.Skin + ", Vector" + player.Pos + ", " + player.Angle + ", " + wep[0].ID + ", " + wep[0].Ammo + ", " + wep[1].ID + ", " + wep[1].Ammo + ", " + wep[2].ID + ", " + wep[2].Ammo + " ); //" + text + "\n";
			}
			else
			{
				// format is CreateVehicle( model, world, pos, angle, col1, col2 )
				//newline = "CreateVehicle(" + veh.Model + ", " + veh.World + ", Vector" + veh.Pos + ", " + veh.Rotation.z + ", " + veh.Colour1 + ", " + veh.Colour2 + "); //" + text + "\n" + "<Vehicle model=\"" + veh.Model + "\" x=\"" + veh.Pos.x + "\" y=\"" + veh.Pos.y + "\" z=\""	+ veh.Pos.z	+ "\" angle=\""	+ veh.Rotation.z + "\" col1=\""	+ veh.Colour1 + "\" col2=\"" + veh.Colour2 + "\"/>" + "\n";
				newline = "CreateVehicle(" + veh.Model + ", " + veh.World + ", Vector" + veh.Pos + ", " + veh.GetRadiansAngle() + ", " + veh.Colour1 + ", " + veh.Colour2 + "); //" + text + "\n";
			}
	  
			MessagePlayer("Saved: " + newline, player);
	  
			local f = file("savedpositions.txt", "a+");
			foreach (c in newline)
			{
				f.writen(c, 'b');
			}
			f.close();
		}
		// end savedpositions.txt
			
		else if(cmd == "heal")
		{
			local hp = player.Health;
			if (hp == 100)
			{
				Message("[#FF3636]Error - [#8181FF]Use this command when you have less than 100% hp !");
			}
			else
			{
				player.Health = 100.0;
				MessagePlayer( "[#FFFF81]---> You have been healed !", player );
			}
		}
		
		else if (cmd == "goto")
		{
			if(!text)
			{
				MessagePlayer( "Error - Correct syntax - /goto <Name/ID>' !",player );
			}
			else
			{
				local plr = GetPlayer(text.tointeger());
				if (!plr)
				{
					MessagePlayer( "Error - Unknown player !",player);
				}
				else
				{
					player.Pos = plr.Pos;
					MessagePlayer( "[ /" + cmd + " ] " + player.Name + " was sent to " + plr.Name, player );
				}
			}
		}
		
		else if (cmd == "kick")
		{
			if(!text)
			{
				MessagePlayer( "Error - Correct syntax - /kick <Name/ID>' !",player );
			}
			else
			{
				local plr = GetPlayer(text.tointeger());
				if (!plr)
				{
					MessagePlayer( "Error - Unknown player !",player);
				}
				else
				{
					KickPlayer(plr);
				}
			}
		}
		else if (cmd == "ban")
		{
			if(!text)
			{
				MessagePlayer( "Error - Correct syntax - /kick <Name/ID>' !",player );
			}
			else
			{
				local plr = GetPlayer(text.tointeger());
				if (!plr)
				{
					MessagePlayer( "Error - Unknown player !",player);
				}
				else
				{
					BanPlayer(plr);
				}
			}
		}
		else if (cmd == "bring")
		{
			if (!text)
			{
				MessagePlayer("Error - Correct syntax - /bring <Name/ID>' !", player);
			}
			else
			{
				local plr = GetPlayer(text.tointeger());
				if (!plr)
				{
					MessagePlayer( "Error - Unknown player !",player);
				}
				else
				{
					plr.Pos = player.Pos;
					MessagePlayer("[ /" + cmd + " ] " + plr.Name + " was sent to " + player.Name, player);
				}
			}
		}
		else if (cmd == "money")
		{
			if (!text)
			{
				MessagePlayer("Error - Correct syntax - /money <Name/ID> <value>' !", player);
			}
			else
			{
				local par1 = GetTok(text, " ", 1);
				local par2 = GetTok(text, " ", 2);
				local plr = GetPlayer(par1.tointeger());
				local cash = par2.tointeger();
				if (!plr)
				{
					MessagePlayer( "Error - Unknown player !",player);
				}
				else
				{
					plr.Cash = cash;
					MessagePlayer(plr.Name + " got $" + cash, player);
				}
			}
		}
		else if (cmd == "weapon")
		{
			if (!text)
			{
				MessagePlayer("Error - Correct syntax - /weapon <ID> <weapon> <ammo>!", player);
			}
			else
			{
				local par1 = GetTok(text, " ", 1);
				local par2 = GetTok(text, " ", 2);
				local par3 = GetTok(text, " ", 3);
				
				local plr = GetPlayer(par1.tointeger());
				local weapon = par2.tointeger();
				local ammo = par3.tointeger();
				
				if (!plr)
				{
					MessagePlayer( "Error - Unknown player !",player);
				}
				else
				{
					plr.GiveWeapon(weapon, ammo);
				}
			}
		}
		
		/*
		else if(cmd == "exec") 
		{
			if( !text ) MessagePlayer( "Error - Syntax: /exec <Squirrel code>", player);
			else
			{
				try
				{
					local script = compilestring( text );
					script();
				}
				catch(e) MessagePlayer( "Error: " + e, player);
			}
		}
		*/
    }
	return 1;
}

function onPlayerPM( player, playerTo, message )
{
	return 1;
}



function onClientScriptData( player )
{
    // receiving client data
    local stream = Stream.ReadByte();
    switch ( stream )
    {
        case StreamType.ServerName:
        {
            Message( "Server received client's request, so it's sending back the server name." );
            // server received the request of client-side, so it sends back the server name
            SendDataToClient( player, StreamType.ServerName, SRV_NAME );
        }
        break;
    }
}

// ========================================== V E H I C L E   E V E N T S =============================================

function onPlayerEnteringVehicle( player, vehicle, door )
{
	return 1;
}


// =========================================== P I C K U P   E V E N T S ==============================================

function onPickupClaimPicked( player, pickup )
{
	return 1;
}

function onPickupPickedUp( player, pickup )
{
	//Small Money
	if (pickup.Model == 337)
	{
		player.Cash += pickup.Quantity;
	}
	//Biz Pickup
	else if (pickup.Model == 408)
	{
		for (local i = 0; i < 8; i++)
		{
			if (pickup.ID == BizList[i].pickup.ID)
			{
				Message("[#FFFF00]" + player.Name + " [#FFFFFF]just got $" + pickup.Quantity + " from [#FF0000]" + BizList[i].name + "[#FFFFFF]!");
				AnnounceAll("~t~" + player.Name + " ~h~just got ~t~$" + pickup.Quantity + "~h~ from ~r~" + BizList[i].name + "~h~!", 1);
				player.Cash += pickup.Quantity;
				//print("Marker " + BizList[i].marker + " destroyed");
				DestroyMarker(BizList[i].marker);
				NewTimer("RestoreMarker", BizTime, 1, i);
				break;
			}
		}
	}
	
	//Ammunation Pickup
	for (local i = 0; i < MAX_WEAP_PICKUPS; i++)
	{
		//if pickups only by ammunation shop
		if (pickup.ID == i + MAX_BIZ)
		{
			if (player.Cash >= WeaponPickups[i].cost)
			{
				if (pickup.Model == 366) //Health Pickup
				{
					if (player.Health < 100) 
					{
						player.Health = 100; // Health Pickup
						player.Cash -= WeaponPickups[i].cost;
						Announce("~h~You just bought ~r~" + WeaponPickups[i].name + " ~h~for ~t~$" + WeaponPickups[i].cost + "!", player, 1);
					}
					break;
				}
				else if (pickup.Model == 368) //Armour Pickup
				{
					if (player.Armour < 100)
					{
						player.Armour = 100; 
						player.Cash -= WeaponPickups[i].cost;
						Announce("~h~You just bought ~r~" + WeaponPickups[i].name + " ~h~for ~t~$" + WeaponPickups[i].cost + "!", player, 1);
					}
					break;
				}
				else
				{
					player.GiveWeapon(WeaponPickups[i].weaponID, WeaponPickups[i].ammo);
					player.Cash -= WeaponPickups[i].cost;
					Announce("~h~You just bought ~r~" + WeaponPickups[i].name + " ~h~for ~t~$" + WeaponPickups[i].cost + "!", player, 1);
					break;
				}
			}
			else
			{
				Announce("~h~You'll need ~t~$" + WeaponPickups[i].cost + " ~h~to buy this!", player, 1);
				break;
			}
		}
	}
	
	// Map Pickups - no need, automatic in pickup options
	/*if (pickup.ID >= MAX_WEAP_PICKUPS + MAX_BIZ)
	{
		if (pickup.Model == 274)
		{
			player.GiveWeapon(17, 30);
		}
	}*/
}

function RestoreMarker(i)
{
	BizList[i].marker = CreateMarker(0, Vector(BizList[i].x, BizList[i].y, BizList[i].z), 1, RGB(0, 0, 0), BizList[i].markerID);
	Message("[#FF0000]" + BizList[i].name + " [#FFFFFF]just got money in cash!");
	AnnounceAll("~r~" + BizList[i].name + " ~h~just got money in cash!", 1);
}

//bugged, runs constantly
/*function onPickupRespawn( pickup )
{
	//print("Pickup (" + pickup.ID + ") respawned!");

	if (pickup.Model == 408)
	{
		for (local i = 0; i < 8; i++)
		{
			if (pickup.ID == BizList[i].pickup.ID)
			{
				BizList[i].marker = CreateMarker(0, Vector(BizList[i].x, BizList[i].y, BizList[i].z), 1, RGB(0, 0, 0), BizList[i].markerID);
				Message("[#FFFFFF]Business [#FF0000]" + BizList[i].name + " [#FFFFFF]just got money in cash!");
				break;
			}
		}
	}
	return 1;
	
}*/

// ================================== E N D   OF   O F F I C I A L   E V E N T S ======================================

function SendDataToClient( player, ... )
{
    if( vargv[0] )
    {
        local     byte = vargv[0],
                len = vargv.len();
                
        if( 1 > len ) devprint( "ToClent <" + byte + "> No params specified." );
        else
        {
            Stream.StartWrite();
            Stream.WriteByte( byte );

            for( local i = 1; i < len; i++ )
            {
                switch( typeof( vargv[i] ) )
                {
                    case "integer": Stream.WriteInt( vargv[i] ); break;
                    case "string": Stream.WriteString( vargv[i] ); break;
                    case "float": Stream.WriteFloat( vargv[i] ); break;
                }
            }
            
            if( player == null ) Stream.SendStream( null );
            else if( typeof( player ) == "instance" ) Stream.SendStream( player );
            else devprint( "ToClient <" + byte + "> Player is not online." );
        }
    }
    else devprint( "ToClient: Even the byte wasn't specified..." );
}

function GetTok(string, separator, n, ...)
{
	local m = vargv.len() > 0 ? vargv[0] : n, tokenized = split(string, separator), text = "";
	if (n > tokenized.len() || n < 1)
	{
		return null
	}
	for (; n <= m; n++)
	{
		text += text == "" ? tokenized[n-1] : separator + tokenized[n-1];
	}
	return text;
}

function GetPlayer(plr)
{
	return players[plr];
}