class CreateRecords < ActiveRecord::Migration
  def change
    create_table :records do |t|
      t.string :record_type
      t.string :record_id
      t.text :data
      t.timestamps
    end
  end
end
