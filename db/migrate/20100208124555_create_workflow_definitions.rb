class CreateWorkflowDefinitions < ActiveRecord::Migration
  def self.up
    create_table :workflow_definitions do |t|
      t.string :name
      t.string :version
      t.string :document_cls
      t.timestamps
    end
  end

  def self.down
    drop_table :workflow_definitions
  end
end
