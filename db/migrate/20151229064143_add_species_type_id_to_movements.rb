class AddSpeciesTypeIdToMovements < ActiveRecord::Migration
  def change
    add_column :movements, :species_type_id, :integer
  end
end
