#!/usr/bin/lua


--Usage:
--media_agent uid gid song
--
require("persistence")
BASE_PATH = "/home/ashok/Server"

mount = "'dogs(dot)mp3'"
playlist = BASE_PATH .. "/playall_list.pls"
live = BASE_PATH .. "/playlist.pls"
socket = BASE_PATH .. "/socket2"
S_SOCKET_PATH = BASE_PATH .. "/sockets/"
PLAYLISTS_PATH = BASE_PATH .. "/playlists/"
MEDIA_SERVER_DB= BASE_PATH .. "/media_server.db"
MEDIA_INSTANCES_DB= BASE_PATH .. "/media_instances.db"
LS_PATH = BASE_PATH .. "/double.ls"

playlists_db_init = { { uid="undefined", gid="undefined", song="/home/ashok/music/machi.mp3", played=0 }, 
			{ uid="undefined", gid="undefined", song="/home/ashok/music/Stylish.mp3", played=0 },
			{ uid="undefined", gid="undefined", song="/home/ashok/uploads/Royals.mp3", played=0 },
			{ uid="undefined", gid="undefined", song="/home/ashok/uploads/Masakali.mp3", played=0 },
			{ uid="undefined", gid="undefined", song="/home/ashok/uploads/Demons.mp3", played=0 },
		}
function main()

	if arg[4] == nil or arg[3] == nil or arg[2] == nil or arg[1] == nil then
		print("Usage : load_song.lua playlist.pls uid gid song_path\n")
		print(arg[1])
		print(arg[2])
		print(arg[3])
		print(arg[4])
		return -1
	end

	playlists_db = persistence.load(arg[1]);
	if ( playlists_db == nil)  then
		playlists_db = {  }
	end

	newsong = { uid=arg[2]:gsub("%a", string.upper, 1), gid=arg[3], song=arg[4], played = 0 }
	table.insert (playlists_db, 1, newsong)
	persistence.store(arg[1], playlists_db)
end

main()
