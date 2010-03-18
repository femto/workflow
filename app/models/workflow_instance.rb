class WorkflowInstance < ActiveRecord::Base
  belongs_to :workflow_definition
  has_many :workflow_steps
  def document
    Object.const_get(document_type).find(document_id)
  end
end
