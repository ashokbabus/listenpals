#!/usr/bin/liquidsoap

mount_point = argv(1)
BASE_PATH = "/home/ashok/Server"
play_live = BASE_PATH ^ "/playlists/" ^ argv(3) ^ ".pls"
play_all = BASE_PATH ^ "/playlists/" ^ argv(3) ^ "_all.pls"
groupid = argv(4)

set("server.socket",true)
set("server.socket.path",BASE_PATH ^ "/sockets/" ^ argv(2))
print("\"#{mount_point}\"")
print(play_live)
print(play_all)
print(groupid)
print(argv(2))

# This function is called when
# a new metadata block is passed in
# the stream.
def apply_metadata(m) =
  title = m["title"]
  artist = m["artist"]
  uid = m["uid"]
  gid = m["gid"]
  print("Now playing: #{title} by #{artist} #{uid} #{gid}")
  if title == "" then
	title2 = string.replace(pattern="[^/]*/",(fun (s) -> ""),m["filename"])
  	playing2="\"#{title2} by #{uid}\""
  	system("java -jar /home/ashok/java/PubSubSend.jar " ^ gid ^ "_nowplg " ^ uid ^ " " ^ playing2)
  else
  	playing="\"#{title} by #{artist}\""
  	system("java -jar /home/ashok/java/PubSubSend.jar " ^ gid ^ "_nowplg " ^ uid ^ " " ^ playing)
  end
end

# This function turns a fallible
# source into an infallible source
# by playing a static single when
# the original song is not available
def my_safe_all(s) =
  # We assume that festival is installed and
  # functional in liquidsoap
  # security = single("say:Hello, this is radio FOO! \
  #                   We are currently having some \
  #                   technical difficulties but we'll \
  #                   be back soon so stay tuned!")
    security = playlist.safe(BASE_PATH ^ "/playlist.pls")
  # We return a fallback where the original
  # source has priority over the security
  # single. We set track_sensitive to false
  # to return immediately to the original source
  # when it becomes available again.
  fallback(track_sensitive=false,[s,security])
end

def my_safe(s) =
  # We assume that festival is installed and
  # functional in liquidsoap
   security = single("say:Hello, this is listen pals! \
                     We are currently having some \
                     technical difficulties but we'll \
                     be back soon so stay tuned!")
   # security = playlist.safe(BASE_PATH ^ "/playall_list.pls")
  # We return a fallback where the original
  # source has priority over the security
  # single. We set track_sensitive to false
  # to return immediately to the original source
  # when it becomes available again.
  fallback(track_sensitive=false,[s,security])
end

# Our custom request function
def get_request() = 
  # Get the URI
  uri = list.hd(get_process_lines(BASE_PATH ^ "/get_songs.lua " ^ play_live))
  # Create a request
  request.create(uri)
end

#live = single(reload_mode="watch",reload=1, play_live)
#live = single(list.hd(get_process_lines("cat " ^ play_live)))

#always = playlist.safe(mode="normal",play_all)

req = request.dynamic(id="radio",get_request)


 #radio = fallback([ request.queue(id="quest"),
 #                           live,
 #                   always])

#radio = fallback(track_sensitive=false, [ req, always])
radio = mksafe(req)
radio = on_metadata(apply_metadata,radio)


# Music
output.icecast(%mp3, host="localhost", 
		port=8000, 
		password="radiochat@84",
		mount=mount_point,
		radio)
