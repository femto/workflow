class CreateWorkflowStepDefinitions < ActiveRecord::Migration
  def self.up
    create_table :workflow_step_definitions do |t|
      t.string :name
      t.string :participant_definition
      t.string :condition
      t.string :nodetype
      t.belongs_to :workflow_definition
      t.timestamps
    end
  end

  def self.down
    drop_table :workflow_step_definitions
  end
end
