require_relative '../lib/lot'
require 'minitest/autorun'
require 'minitest/spec'
require 'mocha/setup'

def setup_db options = {}

  # reset the event subscribers, so there is no bleed between tests
  Lot::EventSubscriber.instance_eval { @types = nil }

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
