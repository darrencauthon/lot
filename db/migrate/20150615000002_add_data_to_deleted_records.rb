class AddDataToDeletedRecords < ActiveRecord::Migration
  def change
    add_column :deleted_records, :data, :string
  end
end
