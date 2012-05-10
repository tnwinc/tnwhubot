# Commands to drive the status boards via pusher
#
# reload board - reloads the status board
#

Pusher = require "node-pusher"

pusher = new Pusher
  appId: process.env['PUSHER_APP_ID']
  key: process.env['PUSHER_API_KEY']
  secret: process.env['PUSHER_SECRET']

channel = process.env['PUSHER_CHANNEL']

pushCmd = (msg_name, contents)->
  contents = contents || {}
  pusher.trigger channel, msg_name, contents

module.exports = (robot)->
  robot.respond /reload board/i, (msg)->
    pushCmd 'reload_board'
    msg.send 'reload command sent.'
