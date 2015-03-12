debug= require('debug') 'edgy:repo'

fs= require 'fs'
path= require 'path'
child_process= require 'child_process'

rimraf= require 'rimraf'

class Repository extends require './index'
  catastrophe: (apps,appDir='apps')->
    repositories= []
    for host,app of apps
      continue if app.REPO is undefined

      repository= new Repository path.resolve(__dirname,'..',appDir,host),app
      do (repository)->
        repo= repository
          .fetchLogs()
          .then (logs)->
            [outofdate,local,remote]= logs

            return repository.initialize() if outofdate
            repository.noop()

        repositories.push repo

    @q.all repositories

  constructor: (@dirname,@env)->
  initialize: ->
    deferred= @q.defer()

    script= "git clone #{@env.REPO} #{@dirname}"

    rimraf @dirname,(error)=>
      return deferred.reject error if error?

      debug script
      child_process.exec script,(error,stdout,stderr)=>
        return deferred.reject error if error?

        debug stdout,stderr

        @install().then (stdout)=>
          deferred.resolve this
        .catch (error)->
          deferred.reject error

    deferred.promise

  install: ->
    deferred= @q.defer()

    script= 'npm install --production'

    if fs.existsSync(path.join @dirname,'package.json') is no
      process.nextTick =>
        deferred.resolve "#{@env.HOST} is Not exists package.json" 
      return deferred.promise

    debug script
    child_process.exec script,cwd:@dirname,(error,stdout,stderr)=>
      return deferred.reject error if error?

      debug stdout,stderr

      deferred.resolve this

    deferred.promise

  fetchLogs: ->
    deferred= @q.defer()

    script= "git fetch"

    if fs.existsSync(@dirname) is no
      process.nextTick ->
        deferred.resolve [yes,null,null]
      return deferred.promise

    debug script
    child_process.exec script,cwd:@dirname,(error,stdout,stderr)=>
      return deferred.reject error if error?

      debug stdout,stderr

      script= "git log --format=format:%H -1
            && echo ''
            && git log origin/master --format=format:%H -1"
      debug script
      child_process.exec script,cwd:@dirname,(error,stdout,stderr)=>
        return deferred.resolve [no,null,null] if error? # maybe "fatal: bad default revision 'HEAD'"

        debug stdout,stderr

        [local,remote]= stdout.split '\n'
        deferred.resolve [local isnt remote,local,remote]

    deferred.promise

module.exports= Repository