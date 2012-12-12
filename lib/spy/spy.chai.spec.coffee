Spy = require './spy'
chai = require 'chai'
spy_matchers = require './spy.chai'
chai.use spy_matchers


describe 'Spy Chai Matchers', ->
  beforeEach ->
    @spy = new Spy()

  describe '.called', ->
    it 'true', ->
      @spy()
      (expect @spy).was.called
    it 'false', ->
      (expect @spy).was.not.called
    describe 'when the subject is not a spy', ->
      it 'should throw', ->
        (expect (-> (expect {}).was.called)).to.throw()

    describe '.with', ->
      it 'false', ->
        @spy 'arg2'

        (expect @spy).was.called.but.not.with 'arg1'
        (expect @spy).was.called.but.not.with()

      it 'true', ->
        @spy 'arg1'
        @spy 'arg1', 'arg2'
        @spy()

        (expect @spy).was.called.with 'arg1'
        (expect @spy).was.called.with 'arg1', 'arg2'
        (expect @spy).was.called.with()
    describe '.on', ->
      beforeEach ->
        @ctx = spy: @spy, toString: -> 'other context'
        @ctx.spy()

      it 'false', ->
        (expect @spy).was.called.but.not.on this

      it 'true', ->
        (expect @spy).was.called.on @ctx
