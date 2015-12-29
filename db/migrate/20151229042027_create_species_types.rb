class CreateSpeciesTypes < ActiveRecord::Migration
  def change
    create_table :species_types do |t|
      t.string :code
      t.string :name

      t.timestamps null: false
    end
  end
end
