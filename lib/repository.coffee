fs= require 'fs'
path= require 'path'
child_process= require 'child_process'

rimraf= require 'rimraf'

class Repository extends require './index'
  appDir:'apps'
  catastrophe: (apps)->
    repositories= []
    for host,app of apps
      continue if app.REPO is undefined

      repository= new Repository path.resolve(__dirname,'..',@appDir,host),app
      do (repository)->
        repo= repository
          .fetchLogs()
          .then (logs)->
            [outofdate,local,remote]= logs

            return repository.initialize() if outofdate
            repository.noop()

        repositories.push repo

    @q.allSettled repositories

  constructor: (@dirname,@env)->
  initialize: ->
    deferred= @q.defer()

    script= "git clone #{@env.REPO} #{@dirname}"

    rimraf @dirname,(error)=>
      return deferred.reject error if error?

      @log @env.HOST,script
      child_process.exec script,(error,stdout,stderr)=>
        return deferred.reject error if error?

        @log @env.HOST,stdout,stderr

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
        @log @env.HOST,'Not exists package.json' 
        deferred.resolve this
    else
      @log @env.HOST,script
      child_process.exec script,cwd:@dirname,(error,stdout,stderr)=>
        return deferred.reject error if error?

        @log @env.HOST,stdout,stderr
        deferred.resolve null

    deferred.promise

  update: (sha1=null,force=no)->
    deferred= @q.defer()

    @fetchLogs().then (logs)=>
      [outofdate,local,remote]= logs

      @log @env.HOST,outofdate,local,remote
      if force is no
        return @q.reject 'invaild request.' if remote isnt sha1
        return @q.resolve 'already up-to-date.' if not outofdate

      script= "git pull"

      @log @env.HOST,script
      child_process.exec script,cwd:@dirname,(error,stdout,stderr)=>
        return deferred.reject error if error?

        @log @env.HOST,stdout,stderr
        @install().then =>
          deferred.resolve null
        .catch (error)->
          deferred.reject error
    
    deferred.promise

  fetchLogs: ->
    deferred= @q.defer()

    script= "git fetch"

    @log @env.HOST,'exists',@dirname
    if fs.existsSync(@dirname) is no
      process.nextTick ->
        deferred.resolve [yes,null,null]
      return deferred.promise

    @log @env.HOST,script
    child_process.exec script,cwd:@dirname,(error,stdout,stderr)=>
      return deferred.reject error if error?

      @log @env.HOST,stdout,stderr

      script= "git log --format=format:%H -1
            && echo ''
            && git log origin/master --format=format:%H -1"
      @log script
      child_process.exec script,cwd:@dirname,(error,stdout,stderr)=>
        return deferred.resolve [no,null,null] if error? # maybe "fatal: bad default revision 'HEAD'"

        @log @env.HOST,stdout,stderr

        [local,remote]= stdout.split '\n'
        deferred.resolve [local isnt remote,local,remote]

    deferred.promise

module.exports= Repository