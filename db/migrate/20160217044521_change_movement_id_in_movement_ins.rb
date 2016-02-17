class ChangeMovementIdInMovementIns < ActiveRecord::Migration
  def change
    change_column :movement_ins, :movement_id, :string
  end
end
