Repository= require './lib/repository'

app_envs= require('yamljs').load 'apps.yml'

pm2= require './lib/pm2'
pm2.connect()
.then ->
  pm2.delete()
.then ->
  Repository::catastrophe app_envs
.catch (error)->
  console.error error.stack.toString()
.then ->
  pm2.start app_envs
.then (results)->
  pm2.api.disconnect ->
    console.log 'completed'

.catch (error)->
  console.error error.stack.toString()