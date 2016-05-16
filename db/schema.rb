# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160217225502) do

  create_table "collector_types", force: :cascade do |t|
    t.string   "code"
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "collector_yards", force: :cascade do |t|
    t.string   "code"
    t.string   "code_old"
    t.string   "name"
    t.string   "owner_name"
    t.string   "address"
    t.string   "sub_district_name"
    t.string   "district_name"
    t.float    "longitude"
    t.float    "latitude"
    t.boolean  "is_cluster"
    t.string   "cluster_name"
    t.integer  "category"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  create_table "movement_ins", force: :cascade do |t|
    t.string   "movement_id"
    t.string   "origin_district"
    t.integer  "collector_type_id"
    t.integer  "species_type_id"
    t.integer  "number"
    t.integer  "weekly_volume"
    t.string   "destination_code"
    t.string   "destination_name"
    t.float    "destination_x"
    t.float    "destination_y"
    t.string   "destination_district"
    t.string   "destination_subdistrict"
    t.float    "point_x_subdistrict_destination"
    t.float    "point_y_subdistrict_destination"
    t.string   "object_id_subdistrict_destination"
    t.float    "in_km_distance_origin_district_destination"
    t.string   "destination_in_cluster"
    t.string   "destination_cluster_name"
    t.string   "cy_id"
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
  end

  create_table "movement_outs", force: :cascade do |t|
    t.string   "movement_id"
    t.string   "origin_code"
    t.string   "origin_name"
    t.string   "origin_district"
    t.string   "origin_sub_district"
    t.string   "origin_x"
    t.string   "origin_y"
    t.integer  "species_type_id"
    t.integer  "number"
    t.integer  "weekly_volume"
    t.integer  "collector_type_id"
    t.string   "name_destination"
    t.string   "destination_lbm_cy_id"
    t.string   "destination_district"
    t.string   "destination_sub_district"
    t.float    "destination_x_original"
    t.float    "destination_y_original"
    t.string   "xy"
    t.float    "point_x_subdistrict"
    t.float    "point_y_subdistrict"
    t.string   "object_id_destination"
    t.float    "in_km_distance_origin_destination"
    t.string   "origin_in_cluster"
    t.string   "cluster_name"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.string   "destination_code"
  end

  create_table "movements", force: :cascade do |t|
    t.string   "code"
    t.string   "source_code"
    t.string   "source_sub_district_name"
    t.string   "source_district_name"
    t.string   "destination_code"
    t.string   "destination_sub_district_name"
    t.string   "destination_district_name"
    t.integer  "weekly_volume"
    t.integer  "number_of_connectivity"
    t.integer  "category"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.integer  "species_type_id"
  end

  create_table "species_types", force: :cascade do |t|
    t.string   "code"
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
