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

ActiveRecord::Schema.define(version: 2019_08_21_164718) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "pokemons", force: :cascade do |t|
    t.string "name"
    t.integer "face_id"
    t.integer "body_id"
    t.integer "mother_id"
    t.integer "father_id"
    t.string "gender"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "image_url"
    t.integer "level"
    t.integer "loyalty"
    t.integer "hp"
    t.integer "attack"
    t.integer "defense"
    t.integer "special_attack"
    t.integer "special_defense"
    t.integer "speed"
    t.string "face_type"
    t.string "body_type"
    t.boolean "alive"
    t.integer "current_hp"
    t.integer "nourishment"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "facility_tier", default: 1
    t.integer "authority", default: 100
    t.integer "facility_cleanliness", default: 100
  end

  create_table "wildmons", force: :cascade do |t|
    t.integer "species_id"
    t.string "habitat"
    t.integer "minimum_level"
    t.integer "capture_rate"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
