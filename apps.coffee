apps= require('yamljs').load 'apps.yml'

pm2= require './lib/pm2'
Repository= require './lib/repository'

pm2.connect()
.then ->
  pm2.delete()
.then ->
  Repository::catastrophe apps
.catch (error)->
  Repository::log error.stack.toString()

.then ->
  pm2.start apps
.then (results)->
  pm2.api.disconnect ->
    Repository::log 'completed'
.catch (error)->
  Repository::log error.stack.toString()