class CreateWorkflowInstances < ActiveRecord::Migration
  def self.up
    create_table :workflow_instances do |t|
      t.belongs_to :workflow_definition
      t.string :workflow_name
      t.string :status
      t.timestamps
    end
  end

  def self.down
    drop_table :workflow_instances
  end
end
