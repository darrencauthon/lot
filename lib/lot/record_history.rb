module Lot
  class RecordHistory < ActiveRecord::Base
    self.table_name = 'record_histories'
    alias_attribute :instigator_id, :saver_id
    alias_attribute :instigator_uuid, :saver_uuid
    alias_attribute :instigator_type, :saver_type
  end
end
