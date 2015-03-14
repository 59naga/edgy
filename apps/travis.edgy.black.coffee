apps= require('yamljs').load 'apps.yml'
path= require 'path'
fs= require 'fs'

http= require 'http'
http.createServer (req,res)->
  res.writeHead 200,'Content-Type':'text/plain'

  body= ''
  req.on 'data',(chunk)-> body+= chunk
  req.on 'end',->
    querystring= require 'querystring'

    {host,sha1,key}= querystring.parse body
    console.log host,sha1,key,req.headers
    return res.end "403 Forbidden" if key isnt fs.readFileSync('.apps.key').toString().trim()

    deploy host,sha1
    .then (result)->
      res.statusCode= 200
      res.end "200 #{host} #{result}"
    .catch (error)->
      res.statusCode= 500
      res.end "500 ERROR #{error.stack}"

.listen process.env.PORT,->
  console.log "Open #{process.env.HOST} > http://localhost:#{process.env.PORT}/"

deploy= (host,sha1)->
  q= require 'q'
  deferred= q.defer()

  env= apps[host]
  if env is undefined
    process.nextTick ->
      deferred.reject 'host is undefined'
    return deferred.promise

  pm2= require '../lib/pm2'
  path= require 'path'
  Repository= require '../lib/repository'
  repository= new Repository path.resolve('..',host),env
  repository.fetchLogs().then (logs)->
    [outofdate,local,remote]= logs

    if not outofdate
      deferred.resolve 'already up-to-date.'
      return deferred.promise

    if remote isnt sha1
      deferred.resolve 'invaild request.'
      return deferred.promise

    pm2.connect()
  .then ->
    pm2.delete HOST
  .then ->
    repository.initialize()
  .then ->
    envs= {}
    envs[HOST]= env
    pm2.start envs
  .then ->
    deferred.resolve 'successfully updated.'
  .catch (error)->
    deferred.reject error
  
  deferred.promise