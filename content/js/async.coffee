# Keeps track of the number of pending callbacks.
# Calls a function when all the added callbacks
# have been called.
class @Callbacks
  # onFinished will be called when there are
  # no pending callbacks left.
  constructor: (onFinished) ->
    @onFinished = onFinished
    @pendingCount = 0

  add: (func) ->
    @pendingCount++
    return =>
      try
        func.apply null, arguments
      catch e
        console.log 'failed to call', func
        throw e
      if --@pendingCount == 0
        @onFinished()
