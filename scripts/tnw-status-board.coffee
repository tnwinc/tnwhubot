# Commands to drive the status boards via pusher
#
# reload board - reloads the status board
# standup - all rise
# sound <url> - plays sound on the status board
# callout <msg> - displays a message or url on the status board

Pusher = require "node-pusher"
Robot = require('hubot').robot()

pusher = new Pusher
  appId: process.env['PUSHER_APP_ID']
  key: process.env['PUSHER_API_KEY']
  secret: process.env['PUSHER_SECRET']

channel = process.env['PUSHER_CHANNEL']

room = process.env.HUBOT_CAMPFIRE_ROOMS

pushCmd = (msg_name, contents)->
  contents = contents || {}
  pusher.trigger channel, msg_name, contents

module.exports = (robot)->
  robot.hear /!(.*)/i, (msg)->
    user = robot.userForId 'broadcast'
    user.room = process.env.HUBOT_ROOM_TO_RECEIVE_TEAM_CITY_BUILD_RESULTS
    user.type = 'groupchat'
    message = "hubot bang #{msg.match[1]}"
    msg.send message
    robot.receive new Robot.TextMessage user, message

  robot.respond /reload board/i, (msg)->
    pushCmd 'reload_board'
    msg.send 'reload command sent.'

  robot.respond /set (\w+) to (.*)/i, (msg)->
    pushCmd 'set_url',
      pane: msg.match[1]
      url: msg.match[2]
    msg.send 'url set'

  robot.respond /standup/i, (msg)->
    length = 10
    pushCmd 'start_standup', length
    msg.send "ALL RISE! For #{length} minutes."

  robot.respond /sound (.*)/i, (msg)->
    url = msg.match[1]
    pushCmd 'play_sound', url

  robot.respond /callout (.*)/i, (msg)->
    type = 'text'
    timeout = 20
    content = msg.match[1]
    if content.match /^http(|s):\/\/.*/i
      type = 'url'
      timeout = 120

      if content.match /\.(png|gif|jpg|jpeg)$/
        type = 'image'
        timeout = 30


    ytids = /youtube (.*)/i.exec content
    if ytids && ytids[1]
      type = 'youtube'
      content = ytids[1]
      timeout = undefined

    if type == 'text'
      content = "&#8220;#{content}&#8221; --#{msg.message.user.name}"

    pushCmd 'set_callout',
      timeout: timeout
      type: type
      content: content

    msg.send content if type is 'image'
