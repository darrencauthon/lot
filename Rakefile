require "bundler/gem_tasks"
require 'active_record'
require 'yaml'

def setup_db options = {}
  options.merge!( {
                    adapter: 'postgresql',
                    host:    'localhost',
                    encoding: 'unicode',
                    database: 'lot_test',
                    pool: '5',
                    username: 'darrencauthon',
                    min_messages: 'warning',
                  } )
  ActiveRecord::Base.establish_connection options 
end

desc "Migrate the database through scripts in db/migrate. Target specific version with VERSION=x"
task :migrate do
  setup_db
  ActiveRecord::Migrator.migrate 'db/migrate'
end
