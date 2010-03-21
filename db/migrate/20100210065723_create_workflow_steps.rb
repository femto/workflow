class CreateWorkflowSteps < ActiveRecord::Migration
  def self.up
    create_table :workflow_steps do |t|
      t.belongs_to :workflow_instance
      t.belongs_to :workflow_step_definition

      t.string :document_type
      t.integer :document_id

      t.timestamps
    end
  end

  def self.down
    drop_table :workflow_steps
  end
end
