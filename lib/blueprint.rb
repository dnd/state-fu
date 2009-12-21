module StateFu
  module Blueprint
    def self.load_yaml(yaml)
      yaml = YAML.load(yaml) if yaml.is_a?(String)
      returning Machine.new(yaml[:options]) do |machine|
        yaml[:states].each do |h|
          s = State.new(machine, h[:name], h[:options])
          # cheap hacks to get around the data structures used for hooks and requirements
          h[:hooks].each { |k, hooks| hooks.each { |hook| s.hooks[k] << hook }}
          h[:requirements].each { |r| s.requirements << r }
          machine.states << s
        end
        yaml[:events].each do |h|          
          e = Event.new(machine, h[:name], h[:options])
          e.origins = h[:origins]
          e.targets = h[:targets]
          # cheap hacks to get around the data structures used for hooks and requirements
          h[:hooks].each { |k, hooks| hooks.each { |hook| e.hooks[k] << hook }}
          h[:requirements].each { |r| e.requirements << r }
          machine.events << e
        end
        yaml[:requirement_messages].each { |k,v| machine.requirement_messages[k] = v }
        machine.initial_state = yaml[:initial_state]
      end
    end
    
    def self.to_hash(machine)
      raise TypeError unless machine.serializable?
      returning({
        :states               => machine.states.map{ |s| state s }, 
        :events               => machine.events.map{ |e| event e },        
        :options              => machine.options,
        :requirement_messages => machine.requirement_messages
      }) do |h|
        h[:initial_state] = machine.initial_state.name if machine.initial_state        
        h[:helpers]       = machine.helpers            if !machine.helpers.empty?
        h[:tools]         = machine.tools              if !machine.tools.empty?
      end
    end
    
    def self.to_yaml(machine)
      to_hash(machine).to_yaml
    end
   
    private
    
    def self.state(state)
      {
        :name         => state.name,
        :hooks        => state.hooks,
        :requirements => state.requirements,
        :options      => state.options
      }
    end
    
    def self.event(event)
      {
        :name         => event.name,
        :origins      => event.origins.names,
        :targets      => event.targets.names,
        :hooks        => event.hooks,
        :requirements => event.requirements,
        :options      => event.options
      }      
    end
  end
end