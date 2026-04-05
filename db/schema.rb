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

ActiveRecord::Schema[8.1].define(version: 2026_04_05_152126) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "admin_users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "companies", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.string "site_link"
    t.datetime "updated_at", null: false
  end

  create_table "feedbacks", force: :cascade do |t|
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.string "feedback_type", null: false
    t.bigint "interview_stage_id", null: false
    t.datetime "updated_at", null: false
    t.index ["interview_stage_id", "feedback_type"], name: "index_feedbacks_on_interview_stage_id_and_feedback_type", unique: true
    t.index ["interview_stage_id"], name: "index_feedbacks_on_interview_stage_id"
  end

  create_table "interview_stages", force: :cascade do |t|
    t.string "calendar_link"
    t.datetime "created_at", null: false
    t.text "notes"
    t.bigint "position_id", null: false
    t.datetime "scheduled_at"
    t.string "stage_type", null: false
    t.string "status", default: "planned", null: false
    t.datetime "updated_at", null: false
    t.index ["position_id", "stage_type"], name: "index_interview_stages_on_position_id_and_stage_type"
    t.index ["position_id"], name: "index_interview_stages_on_position_id"
  end

  create_table "jwt_denylist", force: :cascade do |t|
    t.datetime "exp", null: false
    t.string "jti", null: false
    t.index ["jti"], name: "index_jwt_denylist_on_jti", unique: true
  end

  create_table "positions", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.bigint "resume_id"
    t.string "status", default: "active", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.string "vacancy_url"
    t.index ["company_id"], name: "index_positions_on_company_id"
    t.index ["resume_id"], name: "index_positions_on_resume_id"
    t.index ["user_id"], name: "index_positions_on_user_id"
  end

  create_table "resume_analyses", force: :cascade do |t|
    t.text "content"
    t.datetime "created_at", null: false
    t.text "error_message"
    t.string "model"
    t.bigint "resume_id", null: false
    t.string "status", default: "pending", null: false
    t.integer "tokens_used"
    t.datetime "updated_at", null: false
    t.index ["resume_id"], name: "index_resume_analyses_on_resume_id", unique: true
  end

  create_table "resumes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "default", default: false, null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id", "name"], name: "index_resumes_on_user_id_and_name", unique: true
    t.index ["user_id"], name: "index_resumes_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "confirmation_sent_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "feedbacks", "interview_stages"
  add_foreign_key "interview_stages", "positions"
  add_foreign_key "positions", "companies"
  add_foreign_key "positions", "resumes", on_delete: :nullify
  add_foreign_key "positions", "users"
  add_foreign_key "resume_analyses", "resumes"
  add_foreign_key "resumes", "users"
end
