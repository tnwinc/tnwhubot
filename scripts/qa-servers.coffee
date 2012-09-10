# Description:
#	Takes freetext notes about what is deployed to a QA server. 
#	TODO: Expand team-city-listener script to cover this in a flashier/automatic way. 
#
# Dependencies:
#	None
#
# Configurations:
#	None
#
# Commands:
#	hubot deploying <server> <text> - stores notes about deployment.
#	hubot servers - list QA server, team and notes.
#	what's on <server> - list a single QA server, team and notes.
#
# Notes:
#
# Author:
#	mcrow

note ="No notes provided yet."
servers = [
	"Goby (Carbon) - #{note}",
	"Grouper (Carbon) - #{note}",
	"Catfish (Cobalt) - #{note}",
	"Barracuda (Platinum) - #{note}",
	"Trout (Load) - #{note}",
	"Carp (Open) - #{note}"]

DateFormatter = ->
	weekdays = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']       
	verbose: (date) ->
		weekday = weekdays[date.getDay()]
		month = 1 + date.getMonth()
		minutes = date.getMinutes()
		if minutes < 10 then "0#{minutes}" else "#{minutes}"
		"#{weekday} @ #{date.getHours()}:#{minutes}, #{month}/#{date.getDate()}"

module.exports = (robot) ->
	robot.brain.on 'loaded', ->
		robot.brain.data.servers ?= []
		servers = robot.brain.data.servers ?= []

	# hubot servers
	robot.respond /servers/i, (msg) ->
		msg.send ":::  QA Servers  :::\n" + servers.join('\n')

	# hubot What's on <QA server name>?
	robot.hear /What(?:'s| is|s) on (\S+[^?])/i, (msg) ->
		server = msg.match[1].toLowerCase()
		switch server
			when "goby" 
				msg.send servers[0]
			when "grouper"
				msg.send servers[1]
			when "catfish"
				msg.send servers[2]
			when "barracuda"
				msg.send servers[3]
			when "trout"
				msg.send servers[4]
			when "carp" 
				msg.send servers[5]
			else
				msg.send "Sorry, I don't recognize a server named #{server}..."
		
	# hubot <QA server name> <deploy testing notes>
	robot.respond /deploying ([^\s]+) (.+?)$/i, (msg) ->
		server = msg.match[1].toLowerCase()
		note = msg.match[2]
		
		formatter = new DateFormatter()
		date = new Date()
		now = formatter.verbose(date)

		ConfirmNotes = (server) ->
			robot.brain.data.servers = servers
			"Got it. Saved notes for #{server}."
		
		switch server
			when "goby" 
				servers[0] = "Goby (Carbon) - #{now} - #{note}"
				msg.send ConfirmNotes(server)
			when "grouper"
				servers[1] = "Grouper (Carbon) - #{now} - #{note}"
				msg.send ConfirmNotes(server)
			when "catfish"
				servers[2] = "Catfish (Cobalt) - #{now} - #{note}"
				msg.send ConfirmNotes(server)
			when "barracuda"
				servers[3] = "Barracuda (Platinum) - #{now} - #{note}"
				msg.send ConfirmNotes(server)
			when "trout"
				servers[4] = "Trout (Load) - #{now} - #{note}"
				msg.send ConfirmNotes(server)
			when "carp" 
				servers[5] = "Carp (Open) - #{now} - #{note}"
				msg.send ConfirmNotes(server)
			else
				msg.send "Sorry, I don't recognize a server named #{server}..."
