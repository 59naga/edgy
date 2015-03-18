apps= require('yamljs').load 'apps.yml'

fs= require 'fs'
path= require 'path'
pm2= require '../lib/pm2'
Repository= require '../lib/repository'

try
  authKey= fs.readFileSync('.apps.key').toString().trim()
catch
  authKey= 'local'

deploy= (host,sha1,force=no)->
  app= apps[host]
  repo= new Repository path.resolve(__dirname,host),app
  return repo.q.reject 'host is undefined' if app is undefined

  repo.log host,sha1

  repo.update sha1,force
  .then ->
    pm2.connect()
  .then ->
    pm2.delete host
  .then ->
    pm2.start {"#{host}":app}
  .then ->
    repo.q.resolve 'Update successfully'

http= require 'http'
http.createServer (req,res)->
  res.writeHead 200,'Content-Type':'text/plain'

  body= ''
  req.on 'data',(chunk)-> body+= chunk
  req.on 'end',->
    querystring= require 'querystring'

    {host,sha1,key,force}= querystring.parse body
    console.log host,sha1,key is authKey,force
    return res.end "403 Forbidden" if key isnt authKey

    deploy host,sha1,force
    .then (result)->
      res.statusCode= 200
      res.end "200 #{host} #{result}"
    .catch (error)->
      res.statusCode= 500
      res.end "500 ERROR #{error.stack}"

.listen process.env.PORT,->
  console.log "Open #{process.env.HOST} > http://localhost:#{process.env.PORT}/"
