# Description
#   Looks up a TeamCity build profile and returns deployment info
#
# Dependencies:
#   "githubot": ">=0.2.0"
#
# Configuration:
#   HUBOT_TEAMCITY_USERNAME
#   HUBOT_TEAMCITY_PASSWORD
#   HUBOT_TEAMCITY_HOSTNAME
#   HUBOT_GITHUB_TOKEN
#   HUBOT_GITHUB_API
#
# Commands:
#   hubot servers - list QA server, team and notes
#   what's on <server> - list a single QA server, team and notes
#
# Notes:
#   None
#
# Author:
#   mcrow
 
   
module.exports = (robot) ->
  github = require('githubot')(robot)
  
  gitHubApi = process.env.HUBOT_GITHUB_API || 'https://api.github.com'
  username = process.env.HUBOT_TEAMCITY_USERNAME
  password = process.env.HUBOT_TEAMCITY_PASSWORD
  hostname = process.env.HUBOT_TEAMCITY_HOSTNAME
  scheme = process.env.HUBOT_TEAMCITY_SCHEME || "http"
  
  # TODO: Make dynamic
  qaServers = [
    {name: "goby", team: "Carbon", buildTypeId: "Fishes_GobyPowershell", vcsBranch: "qa_goby"}
    {name: "grouper", team: "Carbon", buildTypeId: "Fishes_GrouperPowershell", vcsBranch: "qa_grouper"}
    {name: "carp", team: "Cobalt", buildTypeId: "Cobalt_CarpPowershell", vcsBranch: "qa_carp"}
    {name: "catfish", team: "Cobalt", buildTypeId: "Cobalt_CatfishPowershell", vcsBranch: "qa_catfish"}
    {name: "barracuda", team: "Platinum", buildTypeId:  "Fishes_BarracudaPowershell", vcsBranch: "qa_barracuda"}
    {name: "monkfish", team: "Neon", buildTypeId:  "Fishes_MonkFish", vcsBranch: "qa_monkfish"}
    {name: "silverfish", team: "Mercury", buildTypeId:  "Mercury_Silverfish", vcsBranch: "qa_silverfish"}
  ]

  Array::toDict = (key) ->
    @reduce ((dict, obj) -> dict[ obj[key] ] = obj if obj[key]?; return dict), {}

  GetTCAuthHeader = ->
    Authorization: "Basic #{new Buffer("#{username}:#{password}").toString("base64")}", "Content-type": "application/json", Accept: "application/json"

  # Hubot Command: What's on <QA server name>?
  robot.hear /What(?:\x27s| is|s) on (?:.+[_])?([\w\d]+)(?:[-].+[?])?/i, (msg) ->
    msg.send "Checking..."
    server = msg.match[1].toLowerCase()
    lookup = qaServers.toDict('name')

    #Get build details from TeamCity
    if lookup[server]?
      typeId = lookup[server].buildTypeId

      #Deploying mode notes
      url = "#{scheme}://#{hostname}/httpAuth/app/rest/builds?locator=running:true&buildType=#{typeId}"
      msg.http(url)
        .headers(GetTCAuthHeader())
        .get() (err, res, body) ->
          result = JSON.parse(body)
          if (result.build.running)
            url = "#{scheme}://#{hostname}/httpAuth/app/rest/builds/id:#{result.build.href}"
            msg.http(url)
              .headers(GetTCAuthHeader())
              .get() (err, res, body) ->
              result = JSON.parse(body)
              minRemaining = (result.running-info.estimatedTotalSeconds - result.running-info.elapsedSeconds) / 60
              msg.send "#{server.charAt(0).toUpperCase() + server.slice(1)}  (#{lookup[server].team})  :::::  :repeat: Currently Deploying eta #{minRemaining}  :::::  #{result.running-info.currentStageText}"
          else
            #----------------------------------------------
            url = "#{scheme}://#{hostname}/httpAuth/app/rest/builds/buildType:#{typeId}"
            msg.http(url)
              .headers(GetTCAuthHeader())
              .get() (err, res, body) ->
                result = JSON.parse(body)
                if (result.triggered.user)?
                  buildUser = result.triggered.user.name
                else
                  buildUser = "VCS Triggered"
                buildVersion = result.revisions.revision[0].version

                # Get sha data from GitHub
                url = "#{gitHubApi}/repos/tnwinc/grc/branches"
                myBranch = ":warning: Not at branch Head - https://github.com/tnwinc/grc/commit/#{buildVersion}"
                github.get url, (branches) ->
                  for branch in branches
                    if branch.commit.sha == buildVersion && branch.name != lookup[server].vcsBranch
                      myBranch = branch.name

                  # Output response
                  result.startDate = result.startDate.replace /^(\d{4})(\d{2})(\d{2})T(\d{2})(\d{2})(\d{2})-.*$/, "$2/$3 @ $4:$5"
                  switch result.status
                    when "FAILURE" then result.status = ":boom: #{result.status}"
                    when "SUCCESS" then result.status = ":thumbsup: #{result.status}"
                    when "CANCELED" then result.status = ":thumbsdown: #{result.status}"
                    else result.status = ":question: #{result.status}"

                  msg.send "#{server.charAt(0).toUpperCase() + server.slice(1)}  (#{lookup[server].team})   :::::   #{buildUser} on #{result.startDate}   :::::   #{result.status}: #{myBranch}"
    else msg.send "Sorry, I don't recognize a server named #{server}..."
