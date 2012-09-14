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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120914054937) do

  create_table "accounts", :force => true do |t|
    t.string   "email",           :null => false
    t.string   "name",            :null => false
    t.string   "photo"
    t.string   "password_digest"
    t.string   "identifier"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "accounts", ["email"], :name => "index_accounts_on_email", :unique => true
  add_index "accounts", ["identifier"], :name => "index_accounts_on_identifier", :unique => true

  create_table "open_id_providers", :force => true do |t|
    t.string   "issuer",                 :null => false
    t.string   "identifier"
    t.string   "secret"
    t.string   "authorization_endpoint"
    t.string   "token_endpoint"
    t.string   "x509_url"
    t.datetime "expires_at"
    t.datetime "created_at",             :null => false
    t.datetime "updated_at",             :null => false
  end

  create_table "open_ids", :force => true do |t|
    t.integer  "account_id"
    t.integer  "open_id_provider_id"
    t.string   "identifier"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

end
