class CreateDeletedRecords < ActiveRecord::Migration
  def change
    execute "CREATE EXTENSION IF NOT EXISTS hstore"
    create_table :deleted_records do |t|
      t.string :record_type
      t.string :record_id
      t.text :data_as_hash

      t.timestamps
    end
  end
end
