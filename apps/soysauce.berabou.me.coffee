express= require 'express'
Soysauce= require 'soysauce'

app= express()
app.use new Soysauce().middleware()
app.listen process.env.PORT