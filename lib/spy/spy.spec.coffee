Spy = require './spy'

describe 'Spy', ->

  it 'should exist', ->
    (expect Spy).to.exist

  it 'should be a function', ->
    (expect Spy).to.be.a 'function'

  describe 'spy instantiation', ->
    beforeEach ->
      @spy = new Spy

    it 'should return a function', ->
      (expect @spy).to.be.a 'function'
    it 'should result in a valid spy', ->
      (expect @spy).to.be.an.instanceof Spy

  describe 'calling the constructor without the new modifier', ->
    it 'should result in a valid spy', ->
      @spy = Spy()
      (expect @spy).to.be.an.instanceof Spy

  describe 'spy identity', ->
    describe 'unnamed spies', ->
      beforeEach ->
        @spy = new Spy

      it 'should be unknown', ->
        (expect @spy.identity).to.equal 'unknown'

      it 'should have an unknown toString', ->
        (expect "#{@spy}").to.equal '[unknown]'

    describe 'named spies', ->

      beforeEach ->
        @spy = new Spy 'some name'

      it 'should reflect its name in the identity property', ->
        (expect @spy.identity).to.equal 'some name'

      it 'should reflect its name in the toString', ->
        (expect "#{@spy}").to.equal '[some name]'

  describe 'a spy intance', ->
    beforeEach ->
      @spy = new Spy

    describe 'andCall', ->
      it 'should expose a method andCall', ->
        (expect @spy).to.have.property('andCall').be.a 'function'

      describe 'calling andCall', ->
        beforeEach ->
          @returned = @spy.andCall @fake = -> 'fake return'

        it 'should return the spy for further chaining', ->
          (expect @returned).to.equal @spy

        describe 'then calling the spy', ->
          beforeEach ->
            @returned = @spy 'input'

          it 'the return value be that of the fake', ->
            (expect @returned).to.equal 'fake return'

    describe 'andReturn', ->
      it 'should expose a method andReturn', ->
        (expect @spy).to.have.property('andReturn').be.a 'function'

      describe 'calling andReturn', ->
        beforeEach ->
          @returned = @spy.andReturn 'return value'

        it 'should return the spy', ->
          (expect @returned).to.equal @spy

        describe 'then calling the spy', ->
          beforeEach ->
            @returned = @spy()

          it 'should return the setup return value', ->
            (expect @returned).to.equal 'return value'

    describe 'andThrow', ->
      it 'should expose a method andThrow', ->
        (expect @spy).to.have.property('andThrow').be.a 'function'

      describe 'calling andThrow', ->
        beforeEach ->
          @returned = @spy.andThrow new Error 'err'
        it 'should return the spy api', ->
          (expect @returned).to.equal @spy
        describe 'execution', ->
          it 'should throw the exception', ->
            (expect => @spy()).to.throw()
