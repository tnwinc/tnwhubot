Spy = require './spy'

describe 'Spy', ->

  describe 'reset', ->
    beforeEach ->
      @spy = new Spy
      @spy()
      @spy.reset()

    it 'should reset wasCalled', ->
      (expect @spy.wasCalled).to.be.falsy
    it 'should reset callCount', ->
      (expect @spy.callCount).to.equal 0
    it 'should reset calls', ->
      (expect @spy.calls.length).to.equal 0
    it 'should reset mostRecentCall', ->
      (expect @spy.mostRecentCall).not.to.exist

  describe 'invocation data', ->

    beforeEach ->
      @spy = new Spy

    describe 'wasCalled', ->
      it 'should default to false', ->
        (expect @spy.wasCalled).to.be.falsy

      describe 'after calling the spy', ->
        beforeEach ->
          @spy()

        it 'should be true', ->
          (expect @spy.wasCalled).to.be.truthy

    describe 'callCount', ->
      it 'should default to zero', ->
        (expect @spy.callCount).to.equal 0

      it 'should increment with number of calls', ->
        @spy()
        @spy()
        (expect @spy.callCount).to.equal 2

    describe 'calls array', ->
      it 'should exist', ->
        (expect @spy.calls).to.exist

      it 'should default to empty', ->
        (expect @spy.calls.length).to.equal 0

      it 'should increase in length with each call to the spy', ->
        @spy()
        @spy()
        @spy()
        (expect @spy.calls.length).to.equal 3

      it 'should keep an ordered record of the arguments passed to the spy', ->
        @spy 'test'
        @spy 'two', 'three'
        (expect @spy.calls[0].args).to.eql ['test']
        (expect @spy.calls[1].args).to.eql ['two', 'three']

    describe 'mostRecentCall', ->
      it 'should be undefined by default', ->
        (expect @spy.mostRecentCall).not.to.exist

      describe '.args', ->
        it 'should provide access to the args for the most recent call', ->
          @spy 'one'
          @spy 'two'
          (expect @spy.mostRecentCall.args).to.eql ['two']
      describe '.context', ->
        it 'should provide access to the context for the most recent call', ->
          ctx = spy: @spy
          @spy()
          ctx.spy()
          (expect @spy.mostRecentCall.context).to.equal ctx
