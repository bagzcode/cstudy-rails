class Movement < ActiveRecord::Base
  enum category: [ :in, :out ]

  def self.autocomplete(keyword, source_type)
    if source_type == "cy_code"
      puts ">>>>>>>>>> cy_code #{source_type}"
      where("lower(source_code) LIKE (?) AND category = ?", "%#{keyword}%", 1)
    elsif source_type == "cy_sub_district"
      puts ">>>>>>>>>> cy_sub_district #{source_type}"
      where("lower(source_sub_district_name) LIKE (?) AND category = ?", "%#{keyword}%", 1)
    elsif source_type == "origin_district"
      puts ">>>>>>>>>> origin_district #{source_type}"
      where("lower(source_district_name) LIKE (?) AND category = ?", "%#{keyword}%", 0)
    end
  end
end
