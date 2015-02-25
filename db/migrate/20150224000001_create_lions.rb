class CreateLions < ActiveRecord::Migration
  def change
    create_table :lions do |t|
      t.string :record_type
      t.string :record_id
      t.text :data_as_hash
      t.hstore :data_as_hstore

      t.timestamps
    end
  end
end
