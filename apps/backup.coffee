execSync= (require 'child_process').execSync

hours= 60*60*1000
backup= ->
  console.log (execSync 'npm run backup').toString()

  setInterval (->backup()),24*hours
backup()