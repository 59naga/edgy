class Module
  q: require 'q'
  chalk: require 'chalk'

  log: (args...)=>
    logo= @chalk.inverse '[EDGY]'
    console.log ([logo].concat args)...

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