Repository= require './lib/repository'

app_envs= require('yamljs').load 'apps.yml'

if '-r' in process.argv
  console.log 'berabou.me update test'

  repo= new Repository 'apps/berabou.me',app_envs['berabou.me']
  pm2.delete()
  .then ->
    repo.update null,yes
  .then ->
    pm2.start app_envs['berabou.me']
  .then ->
    console.log 'ok'
  return

pm2= require './lib/pm2'
pm2.connect()
.then ->
  pm2.delete()
.then ->
  Repository::catastrophe app_envs
.catch (error)->
  Repository::log error.stack.toString()

.then ->
  pm2.start app_envs
.then (results)->
  pm2.api.disconnect ->
    Repository::log 'completed'
.catch (error)->
  Repository::log error.stack.toString()