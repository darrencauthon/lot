require 'json'
require 'active_record'
require 'active_support/inflector'
Dir[File.dirname(__FILE__) + '/lot/*.rb'].each { |f| require f }
Dir[File.dirname(__FILE__) + '/lot/types/*.rb'].each { |f| require f }

module Lot

  def self.types
    @types ||= {}.merge!(Lot::HasOne.definition)
                 .merge!(Lot::HasMany.definition)
  end

  def self.class_from_record_type record_type
    record_type.to_s.camelcase.constantize
  end

end
