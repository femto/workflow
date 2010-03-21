require File.join(File.dirname(__FILE__), "workflow_store.rb")

class WorkflowEngine
  attr_accessor :workflow_definitions, :running_instances, :map_workflow_definitions, :store

  DEFAULT_OPTIONS = {:store => :persistent}

  def initialize(options = {})
    @workflow_definitions = []
    @map_workflow_definitions = {}
    @running_instances = []


    options = (DEFAULT_OPTIONS.merge(options))
    @store = AbstractWorkflowStore.stores[options[:store]].new
  end

  def load_definition(definition, name=nil, participant_resolvance=nil, version="1.0")
    workflow_definition = Workflow::WorkflowDefinition.new(self, name, participant_resolvance)
    @workflow_definitions << workflow_definition
    workflow_definition.parse(definition)
    @map_workflow_definitions[workflow_definition.name] = workflow_definition


    @store.load_workflow_definition(workflow_definition)
    workflow_definition
  end
  def load_workflow_definition_if_not_exist(definition, name=nil, participant_resolvance=nil, version="1.0")
    #etc
  end
  def load_workflow_definition_file(file)
    workflow_definition = Workflow::WorkflowDefinition.new(self, nil, nil)
    @workflow_definitions << workflow_definition
    workflow_definition.parse(File.read(file))
    @map_workflow_definitions[workflow_definition.name] = workflow_definition
    @store.load_workflow_definition(workflow_definition)
    workflow_definition
  end

#  def can_start_workflow_definitions(current_user)
#    result = []
#    @workflow_definitions.each do |workflow_definition|
#      p workflow_definition.start_node
#      if workflow_definition.start_node.participant_contains?(current_user)
#        result << workflow_definition
#      end
#    end
#    result
#  end

  #delegate to store

  def can_start_workflow_definitions(user)
    store.can_start_workflow_definitions(user)
  end
  def get_workflow_definitions(workflow_name)
    store.get_workflow_definitions(workflow_name) #@map_workflow_definitions[workflow_name]
  end

  def get_transitions(arg)
    store.get_transitions(arg)
  end

  def applicable_workflow_steps(current_user)
    store.applicable_workflow_steps(current_user)
  end

  def running_workflow_instances(current_user)
    WorkflowInstance.find(:all)
  end

  def transit(step, transition, document)
    store.transit(step, transition, document)
  end
  

end
class Workflow
  class WorkflowDefinition

    attr_accessor :engine, :nodes, :start_node, :name, :version, :document_cls, :participant_resolvance

    def initialize(engine, name=nil, participant_resolvance=nil)
      @engine = engine
      @name = name
      @nodes = []
      @participant_resolvance = participant_resolvance
    end

    def parse(definition)

      index = 0
      node_index = 0
      current_node = nil
      @transitions = []
      @map_nodes = {}
      definition.each_line do |line|
        if line =~ /^!/
          name = line.scan(/^!(.*)/)
          if !name.empty?
            name = name[0][0]
            @name, @version = name.split
          end
        end

        if line=~ /^-/
          @document_cls = line.scan(/^(\-.*)/)
          if !@document_cls.empty?
            @document_cls = @document_cls[0][0]
            @document_cls.gsub!(/^(\s)*\-/, "")
          else
            @document_cls = nil
          end
        end

        if line=~ /\s*%/
          nodes = line.scan(/\s*%.*/)
          parts = line.split()
          nodetype = nil
          nodename = parts[0]
          if parts[1]
            nodetype = parts[1]
          end
          if node_index == 0 || nodetype == "start" #start type node
            #we set participant_expression in Node.new
            @start_node = Node.new(self, nodename)
            current_node = @start_node
            @nodes << @start_node
          else
            #we set participant_expression in Node.new
            current_node = Node.new(self, nodename)
            @nodes << current_node
          end
          @map_nodes[current_node.nodename] = current_node
          current_node.nodetype = nodetype
          node_index += 1

        end

        if line=~ /\s+-/ #transition definitions
           puts line
           transition_name, to_node_name = line.scan(/\s+-\s*(\S*)\s+(\S*)/)[0]
           p [transition_name, to_node_name]
           transition = Transition.new(current_node, transition_name, to_node_name)
           @transitions << transition #todo: fix all to_node_name
           current_node.add_transition_it(transition)
        end


        index +=1
      end

      @transitions.each do |transition|
         transition.to = @map_nodes[transition.to]
      end

      

      #@nodes.each_with_index do |node, index|

      #  node.add_transition("agree", @nodes[index + 1])
      #  node.add_transition("reject", @nodes[index - 1])

      #end

      @nodes
    end

    def participant_contains?(participant_definition, participant)
      return true if @participant_resolvance.nil? #participant_expression not specified
      @participant_resolvance.participant_contains?(participant_definition, participant)
    end

    def start(transition, document)
      #puts transition
      #puts 
      engine.store.start(self, transition, document)
    end

  end
end
class Workflow
  class Node
    attr_accessor :workflow_defintion, :nodename, :participant_definition, :condition, :transitions, :nodetype

    def initialize(workflow_defintion, nodename)

      @workflow_defintion = workflow_defintion
      nodename = nodename.scan(/^%(\{.*?\})?(.*)/)[0]

      @condition = nodename[0]
      nodename = nodename[1]

      @nodename, @participant_definition = nodename.scan(/([^\(]+)(\(.+\))?/)[0]

      @nodename.gsub!(/^%/, "")
      
      @participant_definition.gsub!(/^\(/, "").gsub!(/\)$/, "") if @participant_definition
      @transitions = []

      #p @participant_definition
    end

    def participant_contains?(participant)
      @workflow_defintion.participant_contains?(@participant_definition, participant)
      #puts "#@participant_definition contains #{participant}"

    end

    def add_transition(transition_name, to)
      @transitions << Transition.new(self, transition_name, to)
    end

    def add_transition_it(transition)
      @transitions << transition
    end



  end

  class Transition
    attr_accessor :node, :name, :to

    def initialize(node, name, to)
      @node = node
      @name = name
      @to = to
    end

    def from
      node
    end

  end
end