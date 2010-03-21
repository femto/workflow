class CreateWorkflowTransitionDefinitions < ActiveRecord::Migration
  def self.up
    create_table :workflow_transition_definitions do |t|
      t.string :name
      t.belongs_to :workflow_step_definition
      t.integer :to_step_id
      t.timestamps
    end
  end

  def self.down
    drop_table :workflow_transition_definitions
  end
end
