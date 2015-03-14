apps= require('yamljs').load 'apps.yml'

Repository= require './lib/repository'
pm2= require './lib/pm2'

if '-r' in process.argv
  console.log 'berabou.me update test'

  repo= new Repository 'apps/berabou.me',apps['berabou.me']
  pm2.connect()
  .then ->
    pm2.delete()
  .then ->
    repo.update null,yes
  .then ->
    pm2.start apps['berabou.me']
  .then ->
    console.log 'ok'
  return

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