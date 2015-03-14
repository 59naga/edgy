apps= require('yamljs').load 'apps.yml'
path= require 'path'
fs= require 'fs'

authKey= fs.readFileSync('.apps.key').toString().trim()

http= require 'http'
http.createServer (req,res)->
  res.writeHead 200,'Content-Type':'text/plain'

  body= ''
  req.on 'data',(chunk)-> body+= chunk
  req.on 'end',->
    querystring= require 'querystring'

    {host,sha1,key}= querystring.parse body
    console.log host,sha1,key is authKey,req.headers
    return res.end "403 Forbidden" if key isnt authKey

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
  env= apps[host]  
  return q.reject 'host is undefined' if env is undefined

  pm2= require '../lib/pm2'
  path= require 'path'
  Repository= require '../lib/repository'
  repository= new Repository path.resolve('..',host),env
  repository.update sha1