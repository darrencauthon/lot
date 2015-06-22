class AddRecordUuidToDeletedRecords < ActiveRecord::Migration
  def change
    add_column :deleted_records, :record_uuid, :string
  end
end
