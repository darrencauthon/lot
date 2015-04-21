class CreateRecordHistories < ActiveRecord::Migration
  def change
    create_table :record_histories do |t|
      t.string :record_type
      t.integer :record_id
      t.string :record_uuid
      t.hstore :old_data
      t.hstore :new_data

      t.timestamps
    end
  end
end
