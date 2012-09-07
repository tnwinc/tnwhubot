# Description:
#   Takes freetext notes about what is deployed to a QA server. TODO: Expand team-city-listener script to cover this in a flashier/automatic way; maybe deploy too.  
#
# Commands:
#   hubot servers - list QA server, team and notes.
#   hubot deploying <text> <text> - stores notes about deployment.

# Declarations / initial response
note ="No notes provided yet."
servers = [
   "Goby (Carbon) - #{note}",
   "Grouper (Carbon) - #{note}",
   "Catfish (Cobalt) - #{note}",
   "Carp (Platinum) - #{note}",
   "Trout (Load) - #{note}"
]

# Timestamp formatting
DateFormatter = ->
	weekdays = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']       
	verbose: (date) ->
		weekday = weekdays[date.getDay()]
		month = 1 + date.getMonth()
		"#{weekday} @ #{date.getHours()}:#{date.getMinutes()}, #{month}/#{date.getDate()}"

# Confirm notes response
ConfirmNotes = (server) ->
	"Got it. Saved notes for #{server}."
		
module.exports = (robot) ->

	# hubot servers
	robot.respond /servers/i, (msg) ->
		msg.send ":::  QA Servers  :::\n" + servers.join('\n')

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
