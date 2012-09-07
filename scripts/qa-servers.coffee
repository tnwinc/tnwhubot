# Description:
#   Takes freetext notes about what is deployed to a QA server. TODO: Expand team-city-listener script to cover this in a flashier/automatic way; maybe deploy too.  
#
# Commands:
#   hubot servers - list QA server, team and notes.
#   hubot what's on <server> - list a single QA server, team and notes.
#   hubot deploying <text> <text> - stores notes about deployment.

note ="No notes provided yet."
servers = [
   "Goby (Carbon) - #{note}",
   "Grouper (Carbon) - #{note}",
   "Catfish (Cobalt) - #{note}",
   "Carp (Platinum) - #{note}",
   "Trout (Load) - #{note}"
]

DateFormatter = ->
	weekdays = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']       
	verbose: (date) ->
		weekday = weekdays[date.getDay()]
		month = 1 + date.getMonth()
		"#{weekday} @ #{date.getHours()}:#{date.getMinutes()}, #{month}/#{date.getDate()}"


ConfirmNotes = (server) ->
	"Got it. Saved notes for #{server}."
		
module.exports = (robot) ->

	# hubot servers
	robot.respond /servers/i, (msg) ->
		msg.send ":::  QA Servers  :::\n" + servers.join('\n')

	# hubot What's on <QA server name>?
	robot.respond /What(?:'s| is) on (\S+[^?])/i, (msg) ->
		server = msg.match[1].toLowerCase()
		switch server
			when "goby" 
				msg.send servers[0]
			when "grouper"
				msg.send servers[1]
			when "catfish"
				msg.send servers[2]
			when "carp" 
				msg.send servers[3]
			when "trout"
				msg.send servers[4]
			else
				msg.send "Sorry, I don't recognize a server named #{server}..."
		
	# hubot <QA server name> <deploy testing notes>
	robot.respond /deploying ([^\s]+)(.+?)$/i, (msg) ->
		server = msg.match[1].toLowerCase()
		note = msg.match[2]

		formatter = new DateFormatter()
		date = new Date()
		now = formatter.verbose(date)

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
			when "carp" 
				servers[3] = "Carp (Platinum) - #{now} - #{note}"
				msg.send ConfirmNotes(server)
			when "trout"
				servers[4] = "Trout (Load) - #{now} - #{note}"
				msg.send ConfirmNotes(server)
			else
				msg.send "Sorry, I don't recognize a server named #{server}..."
