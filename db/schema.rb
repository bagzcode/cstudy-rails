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

ActiveRecord::Schema.define(version: 20151229064143) do

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
