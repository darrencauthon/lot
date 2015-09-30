module Lot

  class Base

    attr_accessor :id

    attr_reader :record_uuid

    def self.inherited thing
      thing.set_table_name_to 'records'
      @types ||= []
      @types << thing
    end

    def initialize source = nil
      if source
        @data        = HashWithIndifferentAccess.new(source.data_as_hstore || {})
        @id          = source.id
        @record_uuid = source.record_id
      else
        @record_uuid = SecureRandom.uuid
      end
      @deserialized_stuff = {}
      @data ||= HashWithIndifferentAccess.new({})
    end

    def record_type
      self.class.to_s.underscore.gsub(' ', '_')
    end

    def self.where options
      the_data_source_query
        .where(options)
        .map { |r| new r }
    end

    def delete_by instigator
      DeletedRecord.create(record_type: record_type,
                           record_id:   id,
                           record_uuid: record_uuid,
                           data:        JSON.dump(@data))
      the_data_source.where(id: self.id).first.delete
    end

    def create!
      save!
    end

    def save_by instigator
      return false unless instigator
      save!( { instigator: instigator } )
    end

    def save! options = {}
      instigator = options[:instigator]
      @dirties = nil
      record = find_or_new_up_record
      persisted = record.persisted?
      stamp_the_history_for(record, instigator) do
        record.data_as_hstore = @data
        record.record_id      = self.record_uuid

        @data.select { |k, _| record.respond_to?(k) }
             .each   { |k, v| record.send("#{k}=", v) }

        record.save.tap do |_|
          self.id = record.id
          the_data = @data.dup.merge('record_id' => record.id)
          Lot::Event.publish("#{self.class.to_s}: #{persisted ? 'Updated' : 'Created'}", the_data, instigator)
        end
      end
    end

    def dirty_properties
      @dirties ||= []
    end

    def history
      RecordHistory.where(record_type: self.record_type,
                          record_id:   self.id,
                          record_uuid: self.record_uuid)
    end

    def method_missing meth, *args, &blk
      set_the_value(meth, args[0]) if setting_a_value? meth
      this_is_an_event_call(meth) ? publish_the_event(meth, args)
                                  : get_the_value(meth)
    end

    def created_at
      if record = the_data_source.where(id: self.id).first
        record.created_at
      end
    end

    def updated_at
      if record = the_data_source.where(id: self.id).first
        record.updated_at
      end
    end

    def the_data_source
      @the_data_source ||= self.class.the_data_source
    end

    class << self

      attr_accessor :schema

      def types
        @types || []
      end

      attr_reader :table_name
      def set_table_name_to table
        @table_name = table
        @this_was_loaded = false
      end

      def default_schema
        nil
      end

      def schema
        @schema ||= default_schema || []
      end

      def the_data_source
        @the_data_source ||= the_data_source_for(self).tap do |ds|
                               unless @this_was_loaded
                                 eval("class #{ds} < ActiveRecord::Base
                                         self.table_name = '#{@table_name}'
                                       end")
                                 @this_was_loaded = true
                               end
                             end.constantize
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

    def this_is_an_event_call meth
      meth.to_s.end_with? '!'
    end

    def publish_the_event meth, args
      instigator = args[0].is_a?(Hash) ? nil : args[0]
      event      = self.class.to_s + ': ' + meth.to_s.gsub('!', '').gsub('_', ' ').capitalize
      data       = ((args[0].is_a?(Hash) ? args[0] : args[1]) || {} ).merge( { 'record_id' => self.id } )

      Lot::Event.publish event, data, instigator
    end

    def stamp_the_history_for record, instigator = nil
      old_data = record.data_as_hstore || {}
      yield.tap do
        RecordHistory.create(record_type: self.record_type,
                             record_id:   self.id,
                             record_uuid: self.record_uuid,
                             old_data:    old_data,
                             new_data:    @data,
                             saver_id:    instigator ? instigator.id          : nil,
                             saver_uuid:  instigator ? instigator.record_uuid : nil,
                             saver_type:  instigator ? instigator.record_type : nil)
      end
    end

    def find_or_new_up_record
      the_data_source.where(id: self.id).first ||
      the_data_source.new.tap { |r| r.record_type = self.class.to_s }
    end

    def setting_a_value? meth
      meth.to_s[-1] == '='
    end

    def get_the_value meth
      key   = pull_the_key_from meth
      stuff = lookup_schema_stuff_for key
      stuff[:definition] ? deserialize_the(key, stuff)
                         : @data[key]
    end

    def deserialize_the key, stuff
      return @deserialized_stuff[key] if @deserialized_stuff[key]
      @deserialized_stuff[key] = stuff[:definition][:deserialize].call(@data[key])
    end

    def set_the_value meth, value
      key   = pull_the_key_from meth
      stuff = lookup_schema_stuff_for key
      self.class.schema << { name: key, type: :string } unless stuff[:field]
      value = stuff[:definition] ? stuff[:definition][:serialize].call(value)
                                 : value
      the_value_did_not_change = value == get_the_value(meth)
      @data[key] = value
      @deserialized_stuff[key] = nil
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
