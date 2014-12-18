class CreateRecords < ActiveRecord::Migration
  def change
    execute "CREATE EXTENSION IF NOT EXISTS hstore"
    create_table :records do |t|
      t.string :record_type
      t.string :record_id
      t.text :data_as_hash
      t.hstore :data_as_hstore

      t.timestamps
    end
  end
end
