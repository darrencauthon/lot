require 'minitest/autorun'
require 'minitest/spec'

require_relative '../lib/lot'

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
