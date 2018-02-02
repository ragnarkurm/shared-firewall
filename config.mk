# general
ID = blackout
BASE_DIR = /home/ragnar/blackout

# backup & restore
NOW := $(shell date +'%Y%m%d-%H%M%S')
BACKUPS = $(BASE_DIR)/backups

# drush
DRUSH_CONTAINER = $(ID)-drush

# web
WEB_CONTAINER = $(ID)-web
WEB_DOMAIN = dev.blackout.local
WEB_IP = 127.0.0.1
WEB_PORT = 60011
WEB_DATA_ACCESS = ro
WEB_BASE = $(BASE_DIR)/web
WEB_CACHE_DIR = $(WEB_BASE)/cache
WEB_DATA_DIR = $(WEB_BASE)/data
WEB_FILES_DIR = $(WEB_BASE)/files
WEB_LOGS_DIR = $(WEB_BASE)/logs
WEB_PRIVATE_DIR = $(WEB_BASE)/private
WEB_CONF = $(WEB_BASE)/apache2.conf
WEB_SSMTP = $(WEB_BASE)/ssmtp.conf

# db
DB_CONTAINER = $(ID)-db
DB_LINK = db
