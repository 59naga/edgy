mysqldump edgy_test > $(pwd)/backups/$(date '+%Y%m%d-%H%k%M').sql
zip -r $(pwd)/backups/$(date '+%Y%m%d-%H%k%M') $(pwd)/apps/edgy.black/storage