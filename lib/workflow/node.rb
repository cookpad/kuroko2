module Workflow
  class Node
    PATH_REGEXP = %r(\A(?:/|(?:/\d+-[a-z0-9_]+)+)\z)
    TASK_REGISTORY = {
      root:                  Task::Sequence,
      noop:                  Task::Noop,
      sequence:              Task::Sequence,
      auto_skip_error:       Task::AutoSkipError,
      fork:                  Task::Fork,
      env:                   Task::Env,
      execute:               Task::Execute,
      queue:                 Task::Queue,
      sub_process:           Task::SubProcess,
      subprocess:            Task::SubProcess,
      timeout:               Task::Timeout,
      expected_time:         Task::ExpectedTime,
      wait:                  Task::Wait,
      sleep:                 Task::Sleep,
      rails_env:             Task::RailsEnv,
    }

    attr_reader :type, :option, :children
    attr_accessor :parent

    def self.register(key: nil, klass:)
      key ||= klass.to_s.demodulize.underscore.to_sym

      unless TASK_REGISTORY.has_key?(key)
        TASK_REGISTORY.store(key, klass)
      else
        Kuroko2.logger.warn("Unable to add '#{klass}' to task registory. '#{TASK_REGISTORY[key]}' is already registered.")
      end
    end

    def self.deregister(key)
      TASK_REGISTORY.delete(key)
    end

    def initialize(type, option = nil)
      @type       = type.to_sym
      @task_klass = TASK_REGISTORY.fetch(@type, nil)
      @option     = option.try(:strip)
      @parent     = nil
      @children   = []

      raise AssertionError, "`#{@type}` is not registered in task repository." unless @task_klass
    end

    def append_child(child)
      child.parent = self
      @children << child
    end

    def execute(token)
      Kuroko2.logger.debug { "(token #{token.uuid}) Execute #{@type} with option '#{@option}'." }
      @task_klass.new(self, token).execute.tap do |result|
        Kuroko2.logger.debug("(token #{token.uuid}) Result is '#{result}'.")
      end
    end

    def find(path)
      raise AssertionError, "path query('#{path}') is invalid." unless PATH_REGEXP === path

      query = path.split('/')
      query.shift # drop first empty string.

      traverse(query)
    end

    def next(index = 0)
      if (child = children[index])
        child
      else
        next_sibling
      end
    end

    def next_sibling
      if parent
        parent.next(current_index + 1)
      else
        nil
      end
    end

    def path
      if parent
        parent.path + "/#{current_index}-#{type}"
      else
        ''
      end
    end

    def to_script(indent = 0)
      "#{'  ' * indent}#{type}: #{option}\n" + children.map { |child| child.to_script(indent + 1) }.join
    end

    def validate_all
      @task_klass.new(self, nil).validate
      @children.each do |child|
        child.validate_all
      end
    end

    protected

    def current_index
      @_current_index = parent.children.index(self)
    end

    def traverse(query)
      return self if query.empty?

      first    = query.shift
      index, _ = first.split('-')

      @children[index.to_i].traverse(query)
    end

  end
end
