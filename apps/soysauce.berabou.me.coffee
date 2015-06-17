express= require 'express'
soysauce= require 'soysauce'

app= express()
app.use '/u/',soysauce.middleware()
app.use '/u/',(req,res)->
  res.redirect 'https://github.com/59naga/soysauce'
app.listen process.env.PORT