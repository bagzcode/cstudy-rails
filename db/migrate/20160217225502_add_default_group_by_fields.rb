class AddDefaultGroupByFields < ActiveRecord::Migration
  def change
    add_column :movement_ins, :code, :string
    add_column :movement_outs, :code, :string

    # update movement outs data
    MovementOut.all.each do |mo|
      if mo.origin_code.blank?
        if mo.origin_sub_district.blank?
          mo.code = mo.origin_district
        else
          mo.code = mo.origin_sub_district + "_" + mo.origin_district
        end
      else
        mo.code = mo.origin_code
      end

      mo.save
    end

    # update movement ins data
    MovementIn.all.each do |mi|
      if mi.destination_code.blank?
        if mi.destination_subdistrict.blank?
          mi.code = mi.destination_district
        else
          mi.code = mi.destination_subdistrict + "_" + mi.destination_district
        end
      else
        mi.code = mi.destination_code
      end

      mi.save
    end
  end
end
