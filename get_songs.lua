#!/usr/bin/lua


--Usage:
--media_agent uid gid song
--
require("persistence")

playlists_db_init = { { uid="undefined", gid="undefined", song="/home/ashok/music/machi.mp3", played=0 }, 
			{ uid="undefined", gid="undefined", song="/home/ashok/music/Stylish.mp3", played=0 },
			{ uid="undefined", gid="undefined", song="/home/ashok/uploads/Royals.mp3", played=0 },
			{ uid="undefined", gid="undefined", song="/home/ashok/uploads/Masakali.mp3", played=0 },
			{ uid="undefined", gid="undefined", song="/home/ashok/uploads/Demons.mp3", played=0 },
		}

playlist_mode_db_init = { mode="loop" }

function main()

	if arg[1] == nil then
		print("Usage : get_songs.lua playlist.pls\n")
		return -1
	end

	playlists_db = persistence.load(arg[1]);


	if ( playlists_db == nil)  then
		--playlists_db = playlists_db_init
		return -1
	end

	playlist_mode_db = persistence.load(arg[1] .. "mode.db" )
	if playlist_mode_db == nil then
		playlist_mode_db = playlist_mode_db_init
		persistence.store(arg[1] .. "mode.db", playlist_mode_db)
	end

	if ( playlist_mode_db.mode == "random" ) then
			rand = math.randomseed(os.time())
			id = math.random(#playlists_db)
			songs = playlists_db[id]
			songs["played"] = 1
			persistence.store(arg[1], playlists_db)
			print("annotate:uid=\"" .. songs["uid"] .. "\",gid=\"" .. songs["gid"] .. "\":" .. songs["song"] )
			return 0	
	end	
	for i, songs in ipairs(playlists_db) do
		if songs["played"] == 0 then
			songs["played"] = 1
			persistence.store(arg[1], playlists_db)
			print("annotate:uid=\"" .. songs["uid"] .. "\",gid=\"" .. songs["gid"] .. "\":" .. songs["song"] )
			return 0
		end
	end

	if ( playlist_mode_db.mode == "loop" ) then
		--Reload the songs
		for i, songs in ipairs(playlists_db) do
			songs["played"] = 0
		end
		persistence.store(arg[1], playlists_db)
		for i, songs in ipairs(playlists_db) do
			if songs["played"] == 0 then
				songs["played"] = 1
				persistence.store(arg[1], playlists_db)
				print("annotate:uid=\"" .. songs["uid"] .. "\",gid=\"" .. songs["gid"] .. "\":" .. songs["song"] )
				return 0
			end
		end
	end
end

main()
