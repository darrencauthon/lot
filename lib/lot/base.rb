module Lot

  class Base

    attr_accessor :id

    def self.inherited thing
      eval("class #{the_data_source_for(thing)} < ActiveRecord::Base
              self.table_name = 'records'
            end")
    end

    def initialize source = nil
      if source
        @data = source.data_as_hstore
        @id = source.id
      end
      @data = {} unless @data
    end

    def save
      record = eval("#{self.class}Base").where(id: self.id).first
      unless record
        record = eval("#{self.class}Base").new
        record.record_type = self.class.to_s
      end
      record.data_as_hstore = @data
      save_result = record.save
      self.id = record.id
      save_result
    end

    def self.find id
      record = the_data_source.find id
      new record
    end

    def self.all
      the_data_source
        .where(record_type: self.to_s)
        .map { |r| new r }
    end

    def self.count
      the_data_source.where(record_type: self.to_s).count
    end

    def self.delete_all
      the_data_source.delete_all
    end

    class << self
      attr_accessor :schema
    end

    def self.schema
      @schema ||= []
    end

    def method_missing meth, *args, &blk
      key = meth.to_s.gsub('=', '')
      value = args[0]
      if meth.to_s[-1] == '='
        if schema_record = self.class.schema.select { |x| x[:name] == key.to_sym }.first
          if definition = Lot.types[schema_record[:type]]
            value = definition[:serialize].call value
          end
        else
          self.class.schema << { name: key.to_sym, type: :string }
        end
        @data[key] = value
      end
      value = @data[key]
      schema_record = self.class.schema.select { |x| x[:name] == key.to_sym }.first
      if schema_record
        if definition = Lot.types[schema_record[:type]]
          value = definition[:deserialize].call value
        end
      end
      value
    end

    def self.the_data_source_for thing
      "::#{thing}Base"
    end

    def self.the_data_source
      @the_data_source ||= eval("#{self}Base")
    end

  end

end
