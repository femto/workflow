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

ActiveRecord::Schema.define(:version => 20100321060029) do

  create_table "refund_requests", :force => true do |t|
    t.integer  "amount"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "shou_wen_documents", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "workflow_definitions", :force => true do |t|
    t.string   "name"
    t.string   "version"
    t.string   "document_cls"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "workflow_instances", :force => true do |t|
    t.integer  "workflow_definition_id"
    t.string   "workflow_name"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "workflow_step_definitions", :force => true do |t|
    t.string   "name"
    t.string   "participant_definition"
    t.string   "condition"
    t.string   "nodetype"
    t.integer  "workflow_definition_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "workflow_steps", :force => true do |t|
    t.integer  "workflow_instance_id"
    t.integer  "workflow_step_definition_id"
    t.string   "document_type"
    t.integer  "document_id"
    t.string   "steptype"
    t.integer  "join_count"
    t.integer  "should_join_count"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "workflow_transition_definitions", :force => true do |t|
    t.string   "name"
    t.integer  "workflow_step_definition_id"
    t.integer  "to_step_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
