module.exports = (_chai, utils)->

  Assertion = _chai.Assertion

  Assertion.addProperty 'was', ->
    return this

  Assertion.addProperty 'but', ->
    return this

  Assertion.addProperty 'called', ->
    throw Error "Expected a spy, but was given #{@_obj}" unless @_obj.wasCalled?
    @assert (@_obj.wasCalled),
      "expected spy #{@_obj} to have been called",
      "expected spy #{@_obj} not to have been called"

    assertion = this
    obj = @_obj

    return \
      with: (args...)->
        for historical_entry in obj.calls
          passed = utils.eql args, historical_entry.args
          break if passed

        assertion.assert passed,
          "expected #{obj} to have been called with [#{args}] but was called with [#{historical_entry.args}]",
          "expected #{obj} not to have been called with [#{args}] but was not called with [#{historical_entry.args}]"
      on: (ctx)->
        for historical_entry in obj.calls
          passed = historical_entry.context == ctx
          break if passed

        assertion.assert passed,
          "expected #{obj} to have been called on context [#{ctx}]",
          "expected #{obj} not to have been called on context [#{ctx}]"
