require 'active_record'
require 'active_support/inflector'
Dir[File.dirname(__FILE__) + '/lot/*.rb'].each { |f| require f }

module Lot

  def self.types
    @types ||= {}
  end

end
