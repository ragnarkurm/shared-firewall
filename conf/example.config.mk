# general
ID = example
BASE = /www/example

# backup & restore
NOW := $(shell date +'%Y%m%d-%H%M%S')
BACKUPS = $(BASE)/backups

# drush
DRUSH_CONTAINER = $(ID)-drush

# web
WEB_CONTAINER = $(ID)-web
WEB_DOMAIN = example.com
WEB_IP = 11.22.33.44
WEB_PORT = 60001
WEB_DATA_ACCESS = ro
WEB_BASE = $(BASE)/web
WEB_CACHE_DIR = $(WEB_BASE)/cache
WEB_DATA_DIR = $(WEB_BASE)/data
WEB_FILES_DIR = $(WEB_BASE)/files
WEB_LOGS_DIR = $(WEB_BASE)/logs
WEB_PRIVATE_DIR = $(WEB_BASE)/private
WEB_CONF = $(WEB_BASE)/apache2.conf

# db
DB_CONTAINER = $(ID)-db
DB_LINK = mysql
DB_NAME = $(ID)
DB_PASS = $(shell cat "$(DB_PASS_FILE)")
DB_ROOT = $(shell cat "$(DB_ROOT_FILE)")
DB_USER = $(ID)

DB_BASE = $(BASE)/db
DB_DATA_DIR = $(DB_BASE)/data
DB_LOGS_DIR = $(DB_BASE)/logs
DB_CONF = $(DB_BASE)/my.cnf
DB_PASS_FILE = $(DB_BASE)/user.pw
DB_ROOT_FILE = $(DB_BASE)/root.pw
