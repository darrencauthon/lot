module Lot

  class Base

    attr_accessor :id

    attr_reader :record_uuid

    def self.inherited thing
      thing.set_table_name_to 'records'
    end

    def initialize source = nil
      if source
        @data        = HashWithIndifferentAccess.new(source.data_as_hstore || {})
        @id          = source.id
        @record_uuid = source.record_id
      else
        @record_uuid = SecureRandom.uuid
      end
      @data ||= HashWithIndifferentAccess.new({})
    end

    def save
      @dirties = nil
      record = the_data_source.where(id: self.id).first ||
               the_data_source.new.tap { |r| r.record_type = self.class.to_s }
      old_data = record.data_as_hstore || {}
      record.data_as_hstore = @data
      record.record_id = self.record_uuid
      record.save.tap { |_| self.id = record.id }
      RecordHistory.create(record_type: self.class.to_s.underscore,
                           record_id: self.id,
                           record_uuid: self.record_uuid,
                           old_data: old_data,
                           new_data: @data)
    end

    def dirty_properties
      @dirties ||= []
    end

    def history
      RecordHistory.all
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

      attr_reader :table_name
      def set_table_name_to table
        @table_name = table
        eval("class #{the_data_source_for(self)} < ActiveRecord::Base
                self.table_name = '#{@table_name}'
              end")
      end

      def default_schema
        nil
      end

      def schema
        @schema ||= default_schema || []
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
        the_data_source_query.map { |r| new r }
      end

      def the_data_source_query
        the_data_source
          .where(record_type: self.to_s)
      end

      def the_data_source_for thing
        "::#{thing}Base"
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
      self.class.schema << { name: key, type: :string } unless stuff[:field]
      value = stuff[:definition] ? stuff[:definition][:serialize].call(value)
                                 : value
      the_value_did_not_change = value == get_the_value(meth)
      @data[key] = value
      dirty_properties << key unless the_value_did_not_change || dirty_properties.include?(key)
    end

    def pull_the_key_from meth
      meth.to_s.gsub('=', '').to_sym
    end

    def lookup_schema_stuff_for key
      { field: self.class.schema.select { |x| x[:name] == key }.first }.tap do |d|
        d[:definition] = Lot.types[d[:field][:type]] if d[:field]
      end
    end

  end

end
