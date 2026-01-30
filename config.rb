require 'fileutils'
require 'sqlite3'

DB_NAME = 'sqlite.db'
DB_FOLDER = 'db'
DB_PATH = File.join(__dir__, DB_FOLDER, DB_NAME)

FileUtils.mkdir_p(DB_FOLDER)
