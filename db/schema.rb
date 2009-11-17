# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20091117194544) do

  create_table "members", :force => true do |t|
    t.string   "role"
    t.string   "email"
    t.string   "hashed_password"
    t.string   "reset_password_token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "full_name"
    t.string   "invitation_token"
    t.string   "time_zone",            :default => "UTC"
  end

  create_table "memberships", :force => true do |t|
    t.integer  "member_id"
    t.integer  "room_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "last_seen_at"
    t.boolean  "mute_audio",   :default => false
  end

  add_index "memberships", ["member_id"], :name => "index_memberships_on_member_id"
  add_index "memberships", ["room_id"], :name => "index_memberships_on_room_id"

  create_table "messages", :force => true do |t|
    t.integer  "room_id"
    t.integer  "author_id"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "messages", ["author_id"], :name => "index_messages_on_author_id"
  add_index "messages", ["room_id"], :name => "index_messages_on_room_id"

  create_table "rooms", :force => true do |t|
    t.string   "label"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
