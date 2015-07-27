#!/bin/nodejs

var BASE_PATH = "/home/ashok/Server";

var http = require('http'),
    util = require('util'),
    sys = require('sys'),
    formidable = require('formidable'),
    server;

var exec = require('child_process').exec;
function puts(error, stdout, stderr) { sys.puts(stdout) }
//exec("ls -la", puts);
var MEDIA_AGENT_APP = BASE_PATH + "/media_agent.lua "

function exec_media_agent_app(uid, gid, song)
{
	song = song.replace(/\$/g, "\\\$");
	gid = gid.replace(/\$/g, "\\\$");
	uid = uid.replace(/\$/g, "\\\$");
	console.log(MEDIA_AGENT_APP + uid + " " + gid + " \"" + song + "\" true");
	exec(MEDIA_AGENT_APP + uid + " " + gid + " \"" + song + "\" true", puts);
}

server = http.createServer(function(req, res) {
  if (req.url == '/') {
    res.writeHead(200, {'content-type': 'text/html'});
    res.end(
      '<form action="/upload" enctype="multipart/form-data" method="post">'+
      '<input type="text" name="title"><br>'+
      '<input type="text" name="gid" <br>'+
      '<input type="text" name="uid" <br>'+
      '<input type="text" name="challenge" <br>'+
      '<input type="file" name="upload" multiple="multiple"><br>'+
      '<input type="submit" value="Upload">'+
      '</form>'
    );
  } else if (req.url == '/upload') {
	console.log("Starting : " + new Date());
	
    var form = new formidable.IncomingForm(),
        files = [],
        fields = [];

    form.uploadDir = "./"
    form
      .on('fileBegin', function(name, file) {
	files.push(['sent',0])
        file.path = './uploads/' + file.name;
	files.push(['fname',file.path])
	console.log("\tReceiving file : " + file.path);
    	})
      .on('field', function(field, value) {
        //fields.push([field, value]);
        console.log("\t" + field, value);
        files.push([field, value]);
      })
      .on('file', function(field, file) {
        //console.log(field, file);
        files.push([field, file]);
      })
      .on('end', function() {
	console.log("End : " + new Date());
        console.log('-> upload done');
        res.writeHead(200, {'content-type': 'text/plain'});
        //res.write('received fields:\n\n '+util.inspect(fields));
        //res.write('received fields:\n\n '+fields);
        res.write('\n\n');
        res.end('received files:\n\n '+util.inspect(files));
        //res.end('received files:\n\n '+files);
      })
      .on('progress', function(bytesReceived, bytesExpected) {
        var percent_complete = (bytesReceived / bytesExpected) * 100;
	if ( percent_complete.toFixed(2) > 60.00) {
		if ( files[3][1] == 0 ) {
        		console.log("\t PercentComplet : " + percent_complete.toFixed(2));
			files[3][1] = 1;
			//console.log("\tsending to ls : " + files[5][1] + " :" + files[1][1] + " :" + files[2][1]);
			//Call the media agent application to play the stream
			exec_media_agent_app(files[0][1], files[1][1],files[4][1]);
		}
	}
      })
      .on('error', function(e) {
	      console.log(' Error occured during receiving');
      });
    form.parse(req);
  } else {
    res.writeHead(404, {'content-type': 'text/plain'});
    res.end('404');
  }
});
server.listen(9080);

process.on('uncaughtException', function ( err ) {
	    console.error('An uncaughtException was found, the program will end.');
	        //hopefully do some logging
   
  });
