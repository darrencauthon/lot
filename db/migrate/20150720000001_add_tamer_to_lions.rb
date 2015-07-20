class AddTamerToLions < ActiveRecord::Migration
  def change
    add_column :lions, :tamer, :string
  end
end
