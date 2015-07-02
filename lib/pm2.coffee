fs= require 'fs'
path= require 'path'

class PM2 extends require './index'
  connect: (busy)->
    deferred= @q.defer()

    @api= require 'pm2'
    @api.connect (error)->
      deferred.reject error if error
      deferred.resolve arguments...

    deferred.promise

  restart: (name='all')->
    deferred= @q.defer()

    @api.restart name,(error,result)->
      deferred.reject error if error?
      deferred.resolve result

    deferred.promise

  start: (apps={},appDir='apps')->
    return deferred.reject 'Requirement @connect' if @api is undefined

    processes= []
    for host,env of apps
      do (host,env)=>
        deferred= @q.defer()

        try
          appRoot= path.resolve __dirname,'..',appDir,host
          script= require.resolve appRoot

          options= {}
          options.env= env
          options.cwd= appRoot
          options.cwd= path.resolve __dirname,'..' if not fs.existsSync appRoot
          options.name= host
          if options.env.PORT is 80 and process.getuid() isnt 0
            @log host,'Change options.env.PORT to 8000 for avoided EACCES Error. Requirement sudo.'
            options.env.PORT= 8000
          @log host,JSON.stringify options

          @api.start script,options,(error,process)->
            deferred.reject error if error?
            deferred.resolve process
        catch error
          deferred.reject error

        processes.push deferred.promise

    @q.allSettled processes

  delete: (name='all')->
    return deferred.reject 'Requirement @connect' if @api is undefined

    deferred= @q.defer()

    @api.list (error,processes=[])=>
      return deferred.reject error if error
      return deferred.resolve null if processes.length is 0

      names= (processName= process.name for process in processes)
      @log name,'launched hosts',names,(name in names)

      return deferred.resolve null if name isnt 'all' and not (name in names)
      @log name,'delete'

      @api.delete name,(error)=>
        @log name,'deleted'
        return deferred.reject error if error
        return deferred.resolve null

    deferred.promise
  
module.exports= new PM2
