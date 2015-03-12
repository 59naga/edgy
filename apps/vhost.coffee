apps= require('yamljs').load 'apps.yml'
path= require 'path'

bouncy= require 'bouncy'
bouncy (req,res,bounce)->
  for host,env of apps
    if req.headers.host is host
      return bounce env.PORT
  for host,env of apps
    if req.headers.host.indexOf(host) > -1
      return bounce env.PORT

  res.statusCode= 404
  res.end '404'

.listen process.env.PORT,->
  try
    process.setuid 500
  catch error
    console.error error.stack

  console.log "Open http://localhost:#{process.env.PORT}/"