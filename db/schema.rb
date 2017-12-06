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

ActiveRecord::Schema.define(version: 20171203200212) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "assignments", force: :cascade do |t|
    t.bigint "course_id"
    t.string "title"
    t.text "description"
    t.datetime "due_date"
    t.boolean "completed", default: false
    t.bigint "primary_assignment_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_assignments_on_course_id"
    t.index ["primary_assignment_id"], name: "index_assignments_on_primary_assignment_id"
  end

  create_table "courses", force: :cascade do |t|
    t.integer "crse_id"
    t.string "subject"
    t.integer "catalog_nbr"
    t.string "title"
    t.string "description"
    t.integer "units_minimum"
    t.integer "units_maximum"
    t.string "session_begin_dt"
    t.string "session_end_dt"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "events", force: :cascade do |t|
    t.string "title"
    t.string "description"
    t.boolean "due_date", default: false
    t.boolean "assignment_to_do", default: false
    t.datetime "start_date"
    t.datetime "end_date"
    t.string "color"
    t.integer "student_course_id"
    t.integer "student_assignment_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "instructors", force: :cascade do |t|
    t.string "net_id"
    t.string "first_name"
    t.string "last_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "stud_course_comp_events", force: :cascade do |t|
    t.bigint "event_id"
    t.bigint "student_course_component_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_stud_course_comp_events_on_event_id"
    t.index ["student_course_component_id"], name: "index_stud_course_comp_events_on_student_course_component_id"
  end

  create_table "student_assignment_events", force: :cascade do |t|
    t.bigint "event_id"
    t.bigint "student_assignment_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_student_assignment_events_on_event_id"
    t.index ["student_assignment_id"], name: "index_student_assignment_events_on_student_assignment_id"
  end

  create_table "student_assignments", force: :cascade do |t|
    t.bigint "assignment_id"
    t.bigint "student_course_id"
    t.boolean "completed", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assignment_id"], name: "index_student_assignments_on_assignment_id"
    t.index ["student_course_id"], name: "index_student_assignments_on_student_course_id"
  end

  create_table "student_course_components", force: :cascade do |t|
    t.bigint "student_course_id"
    t.string "title"
    t.string "component"
    t.string "section"
    t.string "time_start"
    t.string "time_end"
    t.string "pattern"
    t.string "facility_descr"
    t.string "facility_descr_short"
    t.string "color"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["student_course_id"], name: "index_student_course_components_on_student_course_id"
  end

  create_table "student_course_events", force: :cascade do |t|
    t.bigint "event_id"
    t.bigint "student_course_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_student_course_events_on_event_id"
    t.index ["student_course_id"], name: "index_student_course_events_on_student_course_id"
  end

  create_table "student_course_instructors", force: :cascade do |t|
    t.bigint "student_course_id"
    t.bigint "instructor_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["instructor_id"], name: "index_student_course_instructors_on_instructor_id"
    t.index ["student_course_id"], name: "index_student_course_instructors_on_student_course_id"
  end

  create_table "student_courses", force: :cascade do |t|
    t.bigint "course_id"
    t.bigint "student_id"
    t.boolean "completed", default: false
    t.string "section"
    t.string "time_start"
    t.string "time_end"
    t.string "pattern"
    t.string "facility_descr"
    t.string "facility_descr_short"
    t.string "color"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_student_courses_on_course_id"
    t.index ["student_id"], name: "index_student_courses_on_student_id"
  end

  create_table "students", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "assignments", "courses"
  add_foreign_key "stud_course_comp_events", "events"
  add_foreign_key "stud_course_comp_events", "student_course_components"
  add_foreign_key "student_assignment_events", "events"
  add_foreign_key "student_assignment_events", "student_assignments"
  add_foreign_key "student_assignments", "assignments"
  add_foreign_key "student_assignments", "student_courses"
  add_foreign_key "student_course_components", "student_courses"
  add_foreign_key "student_course_events", "events"
  add_foreign_key "student_course_events", "student_courses"
  add_foreign_key "student_course_instructors", "instructors"
  add_foreign_key "student_course_instructors", "student_courses"
  add_foreign_key "student_courses", "courses"
  add_foreign_key "student_courses", "students"
end
