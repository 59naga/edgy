class Module
  q: require 'q'

  noop: =>
    deferred= @q.defer()

    process.nextTick =>
      deferred.resolve this

    deferred.promise

  noopCallback: (...,callback)->
    process.nextTick ->
      callback null

Module::q.longStackSupport= yes

module.exports= Module