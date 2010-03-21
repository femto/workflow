require 'rubygems'
require 'active_record'
class AbstractWorkflowStore
  STORES = {} if(!defined?(STORES))

  def self.register(type, store_cls)
    STORES[type] = store_cls
  end

  def self.stores
    STORES
  end
end
class PersistentWorkflowStore < AbstractWorkflowStore
  register(:persistent, self)

  class WorkflowDefinition < ActiveRecord::Base
  end

  def load_workflow_definition(workflow_definition)
    workflow = WorkflowDefinition.new
    workflow.save
  end
end

class MemoryWorkflowStore < AbstractWorkflowStore
  register(:memory, self)

  def load_workflow_definition(workflow_definition)
    @workflow_definitions ||= []
    @workflow_definitions << workflow_definition
  end
end