# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 13) do

  create_table "pieces", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "tracker_id", :default => 0
    t.text     "text_raw",   :default => "NULL"
    t.string   "error"
    t.integer  "bytecount"
    t.float    "duration"
    t.text     "text"
  end

  create_table "trackers", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "uri",        :default => "NULL"
    t.string   "xpath",      :default => "NULL"
    t.string   "name"
    t.string   "md5sum"
    t.text     "web_hook"
  end

end
