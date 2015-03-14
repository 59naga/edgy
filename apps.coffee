apps= require('yamljs').load 'apps.yml'

pm2= require './lib/pm2'
Repository= require './lib/repository'

if '-r' in process.argv
  console.log 'berabou.me update test'

  repo= new Repository 'apps/berabou.me',apps['berabou.me']
  pm2.connect()
  .then ->
    pm2.delete 'berabou.me'
  .then ->
    repo.update null,yes
  .then ->
    pm2.start 'berabou.me':apps['berabou.me']
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