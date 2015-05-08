require_relative '../lib/lot'
require 'minitest/autorun'
require 'minitest/spec'
require 'mocha/setup'

def setup_db options = {}
  options.merge!( {
                    adapter: 'postgresql',
                    host:    '::1',
                    encoding: 'unicode',
                    database: 'lot_test',
                    pool: '5',
                    username: 'darrencauthon',
                    min_messages: 'warning',
                  } )
  ActiveRecord::Base.establish_connection options 
end

def random_string
  SecureRandom.uuid
end
