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
        @data = HashWithIndifferentAccess.new(source.data_as_hstore || {})
        @id   = source.id
      end
      @data ||= HashWithIndifferentAccess.new({})
    end

    def save
      record = the_data_source.where(id: self.id).first ||
               the_data_source.new.tap { |r| r.record_type = self.class.to_s }
      record.data_as_hstore = @data
      record.save.tap { |_| self.id = record.id }
    end

    def method_missing meth, *args, &blk
      set_the_value(meth, args[0]) if setting_a_value? meth
      get_the_value meth
    end

    def the_data_source
      @the_data_source ||= self.class.the_data_source
    end

    class << self

      attr_accessor :schema

      def schema
        @schema ||= []
      end

      def the_data_source_for thing
        "::#{thing}Base"
      end

      def the_data_source
        @the_data_source ||= the_data_source_for(self).constantize
      end

      def count
        the_data_source.where(record_type: self.to_s).count
      end

      def delete_all
        the_data_source.delete_all
      end

      def find id
        new the_data_source.find(id)
      end

      def all
        the_data_source
          .where(record_type: self.to_s)
          .map { |r| new r }
      end

    end

    private

    def setting_a_value? meth
      meth.to_s[-1] == '='
    end

    def get_the_value meth
      key   = pull_the_key_from meth
      stuff = lookup_schema_stuff_for key
      stuff[:definition] ? stuff[:definition][:deserialize].call(@data[key])
                         : @data[key]
    end

    def set_the_value meth, value
      key   = pull_the_key_from meth
      stuff = lookup_schema_stuff_for key
      self.class.schema << { name: key, type: :string } unless stuff[:schema_record]
      @data[key] = stuff[:definition] ? stuff[:definition][:serialize].call(value)
                                      : value
    end

    def pull_the_key_from meth
      meth.to_s.gsub('=', '').to_sym
    end

    def lookup_schema_stuff_for key
      {}.tap do |d|
        if d[:schema_record] = self.class.schema.select { |x| x[:name] == key }.first
          d[:definition] = Lot.types[d[:schema_record][:type]]
        end
      end
    end

  end

end
