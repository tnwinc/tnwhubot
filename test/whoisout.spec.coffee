chai = require 'chai'
expect = chai.expect

Spy = require '../lib/spy/spy'
chai.use require '../lib/spy/spy.chai'

codeUnderTest = require '../scripts/whoisout'

describe 'Parse Date', ->
  beforeEach ->
    @robot = new Spy()
    @robot.brain =
      data:{outList: []}
    @robot.respond = new Spy()
    codeUnderTest.parseDate = new Spy().andCall codeUnderTest.parseDate
    codeUnderTest @robot

  describe 'when responding', ->
    beforeEach ->
      @robot.respond.mostRecentCall.args[1]({match:['', '12/12/12'], send: new Spy 'message send'})
    it 'should call parse date', ->
      parseDateArgs = codeUnderTest.parseDate.mostRecentCall.args
      (expect codeUnderTest.parseDate).was.called
      (expect parseDateArgs[0]).to.equal '12/12/12'

      describe 'when parsing date', ->
        describe 'when date is parsable by ECMA', ->
          describe 'it is an invalid date', ->
            beforeEach ->
              @thisDate = codeUnderTest.parseDate 'this could never be valid'
            it 'should return a valid date', ->
              (expect @thisDate).to.be.false
          describe 'it is a valid date', ->
            beforeEach ->
              @thisDate = codeUnderTest.parseDate '12/12/12'
            it 'should return a valid date', ->
              (expect @thisDate.start).to.eql new Date('12/12/12')

      describe 'when saving date', ->
        describe 'when user\'s entry exists', ->
          beforeEach ->
            @robot.brain.data =
              outList:[
                name: 'slacker'
                dates: [new Date('1/1/12')]]
            codeUnderTest.save @robot, {start:(new Date '12/12/12')}, {user: 'slacker'}

          it 'should add this date to the user entry', ->
            (expect @robot.brain.data.outList[0]).to.eql
              name: 'slacker'
              dates: [new Date('1/1/12'), new Date('12/12/12')]

          describe 'when user\'s vacation date already exists', ->
            beforeEach ->
              codeUnderTest.save @robot, {start:(new Date '12/12/12')}, {user: 'slacker'}
            it 'should not add it to the brain', ->
              (expect @robot.brain.data.outList[0].dates.length).to.equal 2

        describe 'when user\'s entry does not exist', ->
          beforeEach ->
            @robot.brain.data =
              outList: []
            codeUnderTest.save @robot, {start: (new Date '12/12/12')}, {user: 'slacker'}
          it 'should add date to the right user', ->
            (expect @robot.brain.data.outList[0].dates).to.eql [new Date('12/12/12')]
            (expect @robot.brain.data.outList[0].name).to.equal 'slacker'
