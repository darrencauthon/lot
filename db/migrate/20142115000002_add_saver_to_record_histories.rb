class AddSaverToRecordHistories < ActiveRecord::Migration
  def change
    add_column :record_histories, :saver_id, :integer
    add_column :record_histories, :saver_uuid, :string
    add_column :record_histories, :saver_type, :string
  end
end
