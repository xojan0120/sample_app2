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

ActiveRecord::Schema.define(version: 20190225012322) do

  create_table "direct_message_stats", force: :cascade do |t|
    t.integer "direct_message_id"
    t.integer "user_id"
    t.boolean "display"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["direct_message_id"], name: "index_direct_message_stats_on_direct_message_id"
    t.index ["user_id"], name: "index_direct_message_stats_on_user_id"
  end

  create_table "direct_messages", force: :cascade do |t|
    t.string "content"
    t.string "picture"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.integer "room_id"
    t.index ["room_id"], name: "index_direct_messages_on_room_id"
    t.index ["user_id"], name: "index_direct_messages_on_user_id"
  end

  create_table "follower_notification_logs", force: :cascade do |t|
    t.integer "follower_id"
    t.datetime "mail_sent_at"
    t.integer "follower_notification_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["follower_notification_id"], name: "index_follower_notification_logs_on_follower_notification_id"
  end

  create_table "follower_notifications", force: :cascade do |t|
    t.boolean "enabled"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_follower_notifications_on_user_id"
  end

  create_table "microposts", force: :cascade do |t|
    t.text "content"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "picture"
    t.index ["user_id", "created_at"], name: "index_microposts_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_microposts_on_user_id"
  end

  create_table "relationships", force: :cascade do |t|
    t.integer "follower_id"
    t.integer "followed_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["followed_id"], name: "index_relationships_on_followed_id"
    t.index ["follower_id", "followed_id"], name: "index_relationships_on_follower_id_and_followed_id", unique: true
    t.index ["follower_id"], name: "index_relationships_on_follower_id"
  end

  create_table "replies", force: :cascade do |t|
    t.integer "reply_to"
    t.integer "micropost_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["micropost_id"], name: "index_replies_on_micropost_id"
  end

  create_table "rooms", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_rooms", force: :cascade do |t|
    t.integer "user_id"
    t.integer "room_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["room_id"], name: "index_user_rooms_on_room_id"
    t.index ["user_id"], name: "index_user_rooms_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.string "remember_digest"
    t.boolean "admin", default: false
    t.string "activation_digest"
    t.boolean "activated", default: false
    t.datetime "activated_at"
    t.string "reset_digest"
    t.datetime "reset_sent_at"
    t.string "unique_name", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["unique_name"], name: "index_users_on_unique_name", unique: true
  end

end
