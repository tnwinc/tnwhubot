# Commands to drive the status boards via pusher
#
# reload board - reloads the status board
# standup - all rise
# sound <url> - plays sound on the status board
# callout <msg> - displays a message or url on the status board

Pusher = require "node-pusher"

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
  robot.hear /^!(.*)/i, (msg)->
    user = robot.userForId 'broadcast'
    user.room = process.env.HUBOT_ROOM_TO_RECEIVE_TEAM_CITY_BUILD_RESULTS
    user.type = 'groupchat'
    message = "hubot bang \"#{msg.match[1]}\""
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
    
  robot.respond /say (.*)/i, (msg)->
    # This is hacked together from watching the traffic
    # from this site: http://www.ispeech.org/text.to.speech
    api_key = '0ab8a27ef947d2b4b1f989bf2a9a6bf2'
    text = encodeURIComponent msg.match[1]
    voice = 'usenglishfemale'
    url = "http://api.ispeech.org/api/rest?voice=#{voice}&action=convert&apikey=#{api_key}&speed=0&text=#{text}"
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
