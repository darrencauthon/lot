module Lot
  class DeletedRecord < ActiveRecord::Base
    self.table_name = 'deleted_records'
  end
end
