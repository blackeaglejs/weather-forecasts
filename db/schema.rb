# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_05_01_033954) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "forecasts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.decimal "current_temperature"
    t.decimal "high"
    t.bigint "location_id", null: false
    t.decimal "low"
    t.datetime "time"
    t.string "units"
    t.datetime "updated_at", null: false
    t.index ["location_id"], name: "index_forecasts_on_location_id"
  end

  create_table "locations", force: :cascade do |t|
    t.string "address_one"
    t.string "address_two"
    t.string "city"
    t.string "country"
    t.datetime "created_at", null: false
    t.decimal "latitude"
    t.decimal "longitude"
    t.string "postal_code"
    t.string "province"
    t.datetime "updated_at", null: false
  end

  add_foreign_key "forecasts", "locations"
end
