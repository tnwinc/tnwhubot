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

pushCmd = (msg_name, contents)->
  contents = contents || {}
  pusher.trigger channel, msg_name, contents

module.exports = (robot)->
  robot.router.post "/hubot/build/", (req, res)->
    console.log req.body
    portMap =
      5558 : 502761
      5557 : 502760
      5556 : 502759

    user = robot.userForId 'broadcast'
    user.room = portMap[process.env.PORT]
    user.type = 'groupchat'
    build = req.body.build
    
    soundToPlay = 'http://soundfxnow.com/soundfx/Human-Cheer-SmallCrowd01.mp3'

    if build.buildResult == 'failure'
      soundToPlay = 'http://soundfxnow.com/soundfx/Sad-Trombone.mp3'

    pushCmd 'play_sound', soundToPlay
    
    robot.send user, "#{build.message} and ran on agent:#{build.agentName}"

    res.end "that tickles:" + process.env.PORT

  robot.respond /play/i, (msg)->
    console.log process.env
    console.log process.env.PORT

  robot.respond /reload board/i, (msg)->
    pushCmd 'reload_board'
    msg.send 'reload command sent.'

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
    if ytids[1]?
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

