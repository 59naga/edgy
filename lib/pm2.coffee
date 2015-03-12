path= require 'path'

class PM2 extends require './index'
  start: (apps,appDir='apps')->
    deferred= @q.defer()

    processes= []
    for host,env of apps
      do (host,env)=>
        deferred= @q.defer()

        try
          appRoot= path.resolve __dirname,'..',appDir,host
          script= require.resolve appRoot

          options= {}
          options.env= env
          options.cwd= path.resolve __dirname,'..' if env.REPO is undefined
          options.cwd?= appRoot
          options.name= host

          if options.env.PORT is 80 and process.getuid() isnt 0
            console.error host,'Change options.env.PORT to 8000 for avoid of EACCES Error. Requirement sudo.'
            options.env.PORT= 8000

          console.log script,options

          @api.start script,options,(error,process)->
            deferred.reject error if error?
            deferred.resolve process
        catch error
          deferred.resolve error

        processes.push deferred.promise

    @q.all processes
    .then (processes)->
      deferred.resolve processes
    .catch (error)->
      deferred.reject error

    deferred.promise

  delete: (name='all')->
    deferred= @q.defer()

    @api.list (error,processes=[])=>
      return deferred.reject error if error
      return deferred.resolve null if processes.length is 0

      names= (processName= process.name for process in processes)
      return deferred.resolve null if name isnt 'all' and not (name in names)

      @api.delete name,(error)->
        console.log 'deleted',name
        return deferred.reject error if error
        return deferred.resolve null

    deferred.promise

  connect: (busy)->
    deferred= @q.defer()

    @api= require 'pm2'
    @api.connect (error)->
      deferred.reject error if error
      deferred.resolve arguments...

    deferred.promise

module.exports= new PM2