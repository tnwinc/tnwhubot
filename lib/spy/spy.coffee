module.exports = class Spy

  constructor: (identity)->
    return new Spy(identity) unless this instanceof Spy
    @identity = identity || 'unknown'

    for method in ['reset', 'andCall', 'andReturn', 'andThrow', 'toString']
      this[method] = this[method].bind this

    spy = this
    @invoker = invoker = (args...)->
      args.unshift this
      spy.invoke.apply invoker, args
    invoker.__proto__ = spy

    @invoker.reset()

    return invoker

  andCall: (fake)->
    @get_return_value = (args...)-> fake.apply this, args
    return @invoker

  andReturn: (val)->
    @get_return_value = -> val
    return @invoker

  andThrow: (err)->
    @get_return_value = -> throw err
    return @invoker

  toString: -> "[#{@identity}]"

  invoke: (context, args...)->
    @wasCalled = true
    @callCount++
    @calls.push(
      @mostRecentCall =
       args: args
       context: context
    )
    return unless @get_return_value
    @get_return_value.apply context, args

  reset: ->
    @invoker.callCount = 0
    @invoker.wasCalled = false
    @invoker.calls = []
    @invoker.mostRecentCall = undefined
    return @invoker

Spy.prototype.__proto__ = Function.prototype
