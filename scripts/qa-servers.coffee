# Description:
#   Takes freetext notes about what is deployed to a QA server. 
#   TODO: Expand team-city-listener script to cover this in a flashier/automatic way. 
#
# Dependencies:
#   None
#
# Configurations:
#   None
#
# Commands:
#   hubot deploying <server> <text> - stores notes about deployment.
#   hubot servers - list QA server, team and notes.
#   what's on <server> - list a single QA server, team and notes.
#   hubot slap <user> - mIRC trout slap
#
# Notes:
#
# Author:
#   3.26.13 - mcrow

emptyNote ="No notes provided yet."
serverStatus = []
serverNames= ["Goby      (Carbon)  "
			"Grouper   (Carbon)  "
			"Carp      (Cobalt)  "
			"Catfish   (Cobalt)  "
			"Barracuda (Platinum)"
			"Trout     (Load)    "]

IndexLookup = (server) ->
	switch server	
		when "goby" then return 0
		when "grouper" then return 1
		when "carp" then return 2
		when "catfish" then return 3
		when "barracuda" then return 4
		when "trout" then return 5
		else return "Sorry, I don't recognize a server named #{server}..."

DateFormatter = ->
	weekdays = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']       
	verbose: (date) ->
		weekday = weekdays[date.getDay()]
		month = 1 + date.getMonth()
		minutes = date.getMinutes()
		if minutes < 10 then "0#{minutes}" else "#{minutes}"
		"#{weekday} #{month}/#{date.getDate()} @ #{date.getHours()}:#{minutes}"

	
module.exports = (robot) ->
	robot.brain.on 'loaded', =>
		robot.brain.data.servers ?= []
    
	EmptyStatusCheck = (index) ->
		#if not serverStatus[index] then serverStatus[index]=" - #{emptyNote}"
		if not robot.brain.data.servers[index] 
			#serverStatus[index]=" - #{emptyNote}"
			robot.brain.data.servers[index] = serverNames[index] + " - " + emptyNote

	# hubot servers
	robot.respond /servers/i, (msg) ->
		output = ":::  Active QA Server Deploys  :::\n"
		for element, index in robot.brain.data.servers
			EmptyStatusCheck(index)
			output += robot.brain.data.servers[index] + "\n"
		msg.send output

	# hubot What's on <QA server name>? \x27 testing apostrophe
	robot.hear /What(?:\x27s| is|s) on (\S+[^?])/i, (msg) ->
		server = msg.match[1].toLowerCase()
		index = IndexLookup(server)
		if index in [0..5]
			EmptyStatusCheck(index)
			#msg.send serverNames[index] + serverStatus[index]
			msg.send robot.brain.data.servers[index]
		else msg.send index

	# hubot <QA server name> no notes
	robot.respond /deploying (\w+)$/i, (msg) ->
		server = msg.match[1].toLowerCase()
		msg.send "You need to tell me a note about what is being deployed to the #{server} server..."
		
	# hubot <QA server name> <testing notes>
	robot.respond /deploying (\w+) (.*)$/i, (msg) ->
		server = msg.match[1].toLowerCase()
		note = msg.match[2]
		name = msg.message.user.name

		formatter = new DateFormatter()
		date = new Date()
		now = formatter.verbose(date)

		index = IndexLookup(server)
		if index in [0..5]
			serverStatus[index] = " - #{name} on #{now} - #{note}"
			robot.brain.data.servers[index] = serverNames[index] + serverStatus[index]
			msg.send "Got it. Saved notes for #{server}."
		else msg.send index

	# hubot slap <UserName> (this is silly, it can be removed)
	robot.respond /slap\s(.+)/i, (msg) ->
		slappedUser = msg.match[1].replace(/\s+$/g, "")
		msg.send "!slap"		
		msg.send "Hubot slaps #{slappedUser} around a bit with a large trout"

	# TC deploy listener
	robot.hear /Build (?:\w+) :: qa_(\w+) (?:.+) status of "Running"/i, (msg) ->
		justDeployedServer = msg.match[1]
		msg.send "Let me know if #{justDeployedServer} needs a new note by typing: \"hubot deploying #{justDeployedServer} New Notes\""