class AddDefaultGroupByFields < ActiveRecord::Migration
  # If destination_lbm_cy_id is null, we should use destination_sub_district or if it is null as well,
  # we should use destination_district as a code. Hence, a new field destination_code is added.

  def change
    add_column :movement_outs, :destination_code, :string

    # update movement outs data
    MovementOut.all.each do |mo|
      if mo.destination_lbm_cy_id.blank?
        if mo.destination_sub_district.blank?
          mo.destination_code = mo.destination_district
        else
          mo.destination_code = mo.destination_sub_district + "_" + mo.destination_district
        end
      else
        mo.destination_code = mo.destination_lbm_cy_id
      end

      mo.save
    end
  end
end
