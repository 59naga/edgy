express= require 'express'
soysauce= require 'soysauce'

app= express()
app.use soysauce.middleware()
app.listen process.env.PORT