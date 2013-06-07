# Description:
#   Allows good and bad things to be added to Hubot for sprint retrospective
# 
# Dependencies:
#
# Configuration:
#
# Commands:
#   hubot good <good thing> - Add something good that happened this sprint
#   hubot bad <bad thing> - Add something bad that happened this sprint
#   hubot goodlist - List all good things that happened
#   hubot badlist - List all good things that happened
#   hubot clear badlist - List all bad things that happened
#   hubot clear goodlist - Delete all good things that happened
#   hubot start retro - Start retrospective and clear lists
#
# Author:
#   gabeguz
#   mcrow - minor tweaks

class GoodBad
  constructor: (@robot) ->
    @goodcache = []
    @badcache = []
    @robot.brain.on 'loaded', =>
      if @robot.brain.data.good
        @goodcache = @robot.brain.data.good
      if @robot.brain.data.bad
        @badcache = @robot.brain.data.bad

  nextGoodNum: ->
    maxGoodNum = if @goodcache.length then Math.max.apply(Math,@goodcache.map (n) -> n.num) else 0
    maxGoodNum++
    maxGoodNum
  nextBadNum: ->
    maxBadNum = if @badcache.length then Math.max.apply(Math,@badcache.map (n) -> n.num) else 0
    maxBadNum++
    maxBadNum  
  goodlist: -> @goodcache
  badlist: -> @badcache
  good: (goodString) ->
    goodthing = {num: @nextGoodNum(), good: goodString}
    @goodcache.push goodthing
    @robot.brain.data.good = @goodcache
    goodthing
  bad: (badString) ->
    badthing = {num: @nextBadNum(), bad: badString}
    @badcache.push badthing
    @robot.brain.data.bad = @badcache
    badthing
  gooddel: ->
    @goodcache = []
    @robot.brain.data.good = @goodcache
  baddel: ->
    @badcache = []
    @robot.brain.data.bad = @badcache

  PrintGoodList = ->
    if goodbad.goodlist().length > 0
      response = ""
      for good, num in goodbad.goodlist()
        response += "##{good.num} - #{good.good}\n"
      msg.send "Good List:" 
      msg.send response
    else 
      msg.send "Nothing good happened."

  PrintBadList = ->
    if goodbad.badlist().length > 0
      response = ""
      for bad, num in goodbad.badlist()
        response += "##{bad.num} - #{bad.bad}\n"
      msg.send "Bad List:" 
      msg.send response
    else 
      msg.send "Nothing bad happened."
    
module.exports = (robot) ->
  goodbad = new GoodBad robot
  
  robot.respond /(good) (.+?)$/i, (msg) ->
    message = "#{msg.message.user.name}: #{msg.match[2]}"
    good = goodbad.good message
    msg.send "Added to retro good list"

  robot.respond /(bad) (.+?)$/i, (msg) ->
    message = "#{msg.message.user.name}: #{msg.match[2]}"
    bad = goodbad.bad message
    msg.send "Added to retro bad list"

  robot.respond /(goodlist)/i, (msg) ->
    PrintGoodList()

  robot.respond /(badlist)/i, (msg) ->
    PrintBadList()

  robot.respond /(clear goodlist)/i, (msg) ->
    goodbad.gooddel()
    msg.send "Good things deleted." 

  robot.respond /(clear badlist)/i, (msg) ->
    goodbad.baddel()
    msg.send "Bad things deleted." 
    
  robot.respond /(start retro)/i, (msg) ->
    msg.send "-----------  Starting Sprint Retrospective  -----------"
    PrintGoodList()
    PrintBadList()
    msg.send "Clearing both lists for next sprint." 
    goodbad.baddel()
    goodbad.gooddel()

