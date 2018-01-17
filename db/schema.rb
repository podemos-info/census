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

ActiveRecord::Schema.define(version: 20171120095545) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"
  end

  create_table "admins", force: :cascade do |t|
    t.bigint "person_id", null: false
    t.integer "role", null: false
    t.bigint "scope_id"
    t.string "username", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.integer "failed_attempts", default: 0, null: false
    t.datetime "locked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["person_id"], name: "index_admins_on_person_id"
    t.index ["scope_id"], name: "index_admins_on_scope_id"
    t.index ["username"], name: "index_admins_on_username", unique: true
  end

  create_table "attachments", force: :cascade do |t|
    t.bigint "procedure_id"
    t.string "file", null: false
    t.string "content_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["procedure_id"], name: "index_attachments_on_procedure_id"
  end

  create_table "bics", force: :cascade do |t|
    t.string "country", null: false
    t.string "bank_code", null: false
    t.string "bic", null: false
    t.index ["country", "bank_code"], name: "index_bics_on_country_and_bank_code", unique: true
  end

  create_table "campaigns", force: :cascade do |t|
    t.string "campaign_code", null: false
    t.bigint "payee_id"
    t.string "description"
    t.index ["campaign_code"], name: "index_campaigns_on_campaign_code", unique: true
    t.index ["payee_id"], name: "index_campaigns_on_payee_id"
  end

  create_table "downloads", force: :cascade do |t|
    t.bigint "person_id"
    t.string "file", null: false
    t.string "content_type"
    t.datetime "expires_at", null: false
    t.jsonb "information", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["person_id"], name: "index_downloads_on_person_id"
  end

  create_table "events", force: :cascade do |t|
    t.integer "visit_id"
    t.bigint "admin_id"
    t.string "name"
    t.jsonb "properties"
    t.datetime "time"
    t.index ["admin_id", "name"], name: "index_events_on_admin_id_and_name"
    t.index ["admin_id"], name: "index_events_on_admin_id"
    t.index ["name", "time"], name: "index_events_on_name_and_time"
    t.index ["visit_id", "name"], name: "index_events_on_visit_id_and_name"
  end

  create_table "issue_objects", force: :cascade do |t|
    t.bigint "issue_id"
    t.string "object_type"
    t.bigint "object_id"
    t.index ["issue_id"], name: "index_issue_objects_on_issue_id"
    t.index ["object_type", "object_id"], name: "index_issue_objects_on_object_type_and_object_id"
  end

  create_table "issue_unreads", force: :cascade do |t|
    t.bigint "admin_id"
    t.bigint "issue_id"
    t.index ["admin_id", "issue_id"], name: "index_issue_unreads_on_admin_id_and_issue_id", unique: true
    t.index ["issue_id"], name: "index_issue_unreads_on_issue_id"
  end

  create_table "issues", force: :cascade do |t|
    t.string "issue_type", null: false
    t.string "description"
    t.integer "role"
    t.integer "level", null: false
    t.bigint "assigned_to_id"
    t.jsonb "information", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "fixed_at"
    t.index ["assigned_to_id", "fixed_at"], name: "index_issues_on_assigned_to_id_and_fixed_at"
    t.index ["assigned_to_id"], name: "index_issues_on_assigned_to_id"
    t.index ["information"], name: "index_issues_on_information", using: :gin
    t.index ["issue_type", "fixed_at"], name: "index_issues_on_issue_type_and_fixed_at"
  end

  create_table "orders", force: :cascade do |t|
    t.bigint "person_id", null: false
    t.bigint "payment_method_id", null: false
    t.bigint "orders_batch_id"
    t.string "currency", null: false
    t.integer "amount", null: false
    t.string "description", null: false
    t.bigint "processed_by_id"
    t.datetime "processed_at"
    t.string "response_code"
    t.string "state"
    t.jsonb "information", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.bigint "campaign_id"
    t.index ["campaign_id"], name: "index_orders_on_campaign_id"
    t.index ["orders_batch_id"], name: "index_orders_on_orders_batch_id"
    t.index ["payment_method_id"], name: "index_orders_on_payment_method_id"
    t.index ["person_id"], name: "index_orders_on_person_id"
    t.index ["processed_by_id"], name: "index_orders_on_processed_by_id"
  end

  create_table "orders_batches", force: :cascade do |t|
    t.string "description", null: false
    t.bigint "processed_by_id"
    t.datetime "processed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["processed_by_id"], name: "index_orders_batches_on_processed_by_id"
  end

  create_table "payees", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "scope_id"
    t.string "iban"
    t.index ["scope_id"], name: "index_payees_on_scope_id"
  end

  create_table "payment_methods", force: :cascade do |t|
    t.bigint "person_id", null: false
    t.string "name", null: false
    t.string "type", null: false
    t.integer "flags", default: 0, null: false
    t.string "payment_processor", null: false
    t.string "response_code"
    t.jsonb "information", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["information"], name: "index_payment_methods_on_information", using: :gin
    t.index ["person_id"], name: "index_payment_methods_on_person_id"
  end

  create_table "people", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name1"
    t.string "last_name2"
    t.integer "document_type"
    t.string "document_id"
    t.bigint "document_scope_id"
    t.date "born_at"
    t.integer "gender"
    t.string "address"
    t.bigint "address_scope_id"
    t.string "postal_code"
    t.string "email"
    t.string "phone"
    t.bigint "scope_id"
    t.string "membership_level"
    t.integer "verifications", default: 0, null: false
    t.integer "flags", default: 0, null: false
    t.jsonb "extra", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["address_scope_id"], name: "index_people_on_address_scope_id"
    t.index ["document_scope_id"], name: "index_people_on_document_scope_id"
    t.index ["extra"], name: "index_people_on_extra", using: :gin
    t.index ["scope_id"], name: "index_people_on_scope_id"
    t.index ["verifications"], name: "index_people_on_verifications"
  end

  create_table "procedures", force: :cascade do |t|
    t.bigint "person_id"
    t.string "type", null: false
    t.string "state"
    t.jsonb "information", default: {}, null: false
    t.bigint "processed_by_id"
    t.datetime "processed_at"
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "depends_on_id"
    t.index ["depends_on_id"], name: "index_procedures_on_depends_on_id"
    t.index ["person_id"], name: "index_procedures_on_person_id"
    t.index ["processed_by_id"], name: "index_procedures_on_processed_by_id"
  end

  create_table "scope_types", force: :cascade do |t|
    t.jsonb "name", default: {}, null: false
    t.jsonb "plural", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "scopes", force: :cascade do |t|
    t.jsonb "name", default: {}, null: false
    t.bigint "scope_type_id", null: false
    t.bigint "parent_id"
    t.string "code", null: false
    t.integer "part_of", default: [], null: false, array: true
    t.integer "children_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_scopes_on_code", unique: true
    t.index ["parent_id"], name: "index_scopes_on_parent_id"
    t.index ["part_of"], name: "index_scopes_on_part_of", using: :gin
    t.index ["scope_type_id"], name: "index_scopes_on_scope_type_id"
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.jsonb "object"
    t.jsonb "object_changes"
    t.datetime "created_at"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  create_table "visits", force: :cascade do |t|
    t.string "visit_token"
    t.string "visitor_token"
    t.string "ip"
    t.text "user_agent"
    t.text "referrer"
    t.text "landing_page"
    t.bigint "admin_id"
    t.string "referring_domain"
    t.string "search_keyword"
    t.string "browser"
    t.string "os"
    t.string "device_type"
    t.integer "screen_height"
    t.integer "screen_width"
    t.string "country"
    t.string "region"
    t.string "city"
    t.string "postal_code"
    t.decimal "latitude"
    t.decimal "longitude"
    t.string "utm_source"
    t.string "utm_medium"
    t.string "utm_term"
    t.string "utm_content"
    t.string "utm_campaign"
    t.datetime "started_at"
    t.index ["admin_id"], name: "index_visits_on_admin_id"
    t.index ["visit_token"], name: "index_visits_on_visit_token", unique: true
  end

  add_foreign_key "attachments", "procedures"
  add_foreign_key "issues", "people", column: "assigned_to_id"
  add_foreign_key "orders", "admins", column: "processed_by_id"
  add_foreign_key "orders_batches", "admins", column: "processed_by_id"
  add_foreign_key "people", "scopes", column: "address_scope_id"
  add_foreign_key "people", "scopes", column: "document_scope_id"
  add_foreign_key "procedures", "admins", column: "processed_by_id"
  add_foreign_key "procedures", "procedures", column: "depends_on_id"
  add_foreign_key "scopes", "scope_types"
  add_foreign_key "scopes", "scopes", column: "parent_id"
end
