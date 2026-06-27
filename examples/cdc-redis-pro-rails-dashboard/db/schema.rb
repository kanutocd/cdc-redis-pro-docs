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

ActiveRecord::Schema[8.1].define(version: 2026_06_28_000000) do
  create_table "demo_runs", force: :cascade do |t|
    t.text "command"
    t.text "config_path"
    t.datetime "created_at", null: false
    t.decimal "elapsed_seconds", precision: 10, scale: 3
    t.integer "exit_status"
    t.datetime "finished_at"
    t.string "mode", null: false
    t.datetime "started_at"
    t.string "status", default: "queued", null: false
    t.text "stderr"
    t.text "stdout"
    t.text "summary"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["mode"], name: "index_demo_runs_on_mode"
    t.index ["status"], name: "index_demo_runs_on_status"
  end
end
