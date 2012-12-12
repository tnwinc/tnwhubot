# Show/Enter who is out of office
#

moment = require 'moment'
_ = require 'underscore'

plugin = (robot)->
  robot.brain.data.outList = [] unless robot.brain.data.outList?
  robot.respond /I am out +(.*)/i, (msg)->
    thisDate = plugin.parseDate msg.match[1]
    if thisDate
      plugin.save robot, thisDate, msg
      msg.send 'success'
    else
      msg.send 'unable to parse date'

plugin.parseDate = (fuzzyDateString)->
  if (@thisDate = (moment fuzzyDateString)).isValid()
    return {start: @thisDate.toDate(), end: null}
  else
    return false

plugin.save = (robot, vacationDateRange, msg)->
  userOutList = robot.brain.data.outList
  userVacation = _(userOutList).find (item)-> item.name is msg.user.name
  if userVacation is undefined
    userOutList.push
      name: msg.user.name
      dates: [vacationDateRange.start]
  else
    unless _(userVacation.dates).some( (item)-> (moment item).format('M/D/YY') is (moment vacationDateRange.start).format('M/D/YY'))
      userVacation.dates.push vacationDateRange.start

module.exports = plugin
