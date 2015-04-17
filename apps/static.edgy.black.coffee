express= require 'express'
path= require 'path'

app= express()
app.use (req,res,next)->
  res.setHeader 'Access-Control-Allow-Origin','*'
  next()
app.use express.static path.join process.cwd(),'static'
app.listen process.env.PORT