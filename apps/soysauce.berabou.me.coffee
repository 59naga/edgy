express= require 'express'
soysauce= require 'soysauce'

app= express()
app.use (req,res,next)->
  res.set 'Expires',new Date(Date.now() - 60*60*24 * 1000).toUTCString()
  next()

app.use soysauce.middleware()
app.listen process.env.PORT