express= require 'express'
path= require 'path'

app= express()
app.use express.static path.join process.cwd(),'static'
app.listen process.env.PORT