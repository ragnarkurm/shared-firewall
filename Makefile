include conf/config.mk

DRUSH_FLAGS = -it

all:
	@echo
	@echo "make start"
	@echo "make stop"
	@echo "make backup"
	@echo "make restore"
	@echo "make restore RESTORE_SOURCE='/abs/path/to/backups/YYYYMMDD-HHMMSS-label'"
	@echo "make drush"
	@echo "make drush DRUSH_ARGS='drush cmd ...'"
	@echo

#
#		general
#

start:
	make -C db start
	make -C web start

stop:
	make -C web stop
	make -C db stop

#
#	backup & restore
#

# need to do it in two steps since
# make cannot assign variables in rules
backup:
	make backup2 BACKUP_DESTINATION="$(BACKUPS)/$(NOW)--`bin/backup-tag`"

backup2:
	mkdir -p "$(BACKUP_DESTINATION)"
	make -C web stop
	make -C db stop
	make -C web backup BACKUP_DESTINATION="$(BACKUP_DESTINATION)/web"
	make -C db backup BACKUP_DESTINATION="$(BACKUP_DESTINATION)/db"
	make -C db start
	make -C web start
	@echo "----------------------------------------------"
	@sudo du -sh "$(BACKUP_DESTINATION)" "$(BACKUPS)"
	@echo "----------------------------------------------"
	@sudo ls -la "$(BACKUPS)" | tail
	@echo "----------------------------------------------"

# need to do it in two steps since
# make cannot assign variables in rules
restore:
	if [ -z "$(RESTORE_SOURCE)" ]; then \
		make restore2 RESTORE_SOURCE="`bin/backup-last \"$(BACKUPS)\"`" \
	; elif [ -d "$(RESTORE_SOURCE)" ]; then \
		make restore2 RESTORE_SOURCE="`readlink -f \"$(RESTORE_SOURCE)\"`" \
	; else \
		echo "!!! Expecting absolute path" \
	; fi
	
restore2:
	@echo "----------------------------------------------"
	@echo "Restoring from: $(RESTORE_SOURCE)"
	@echo "----------------------------------------------"
	make -C web stop
	make -C db stop
	make -C web restore RESTORE_SOURCE="$(RESTORE_SOURCE)/web"
	make -C db restore RESTORE_SOURCE="$(RESTORE_SOURCE)/db"
	make -C db start
	make -C web start

#
#	drush
#

drush_notty:
	make drush DRUSH_FLAGS=-i

drush:
	@docker run \
		$(DRUSH_FLAGS) \
		--rm \
		--name "$(DRUSH_CONTAINER)" \
		--link "$(DB_CONTAINER):$(DB_LINK)" \
		-v "$(WEB_CONF):/etc/apache2/sites-enabled/default.conf" \
		-v "$(WEB_SSMTP):/etc/ssmtp/ssmtp.conf" \
		-v "$(WEB_DATA_DIR)/:/data/" \
		-v "$(WEB_FILES_DIR)/:/data/sites/default/files/" \
		-v "$(WEB_CACHE_DIR)/:/data/cache/" \
		-v "$(WEB_PRIVATE_DIR)/:/private/" \
		-v "$(WEB_LOGS_DIR)/:/logs/" \
		drush \
		$(DRUSH_ARGS)
