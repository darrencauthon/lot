require 'active_record'
require 'activerecord-postgres-hstore'
Dir[File.dirname(__FILE__) + '/lot/*.rb'].each { |f| require f }

module Lot
end
