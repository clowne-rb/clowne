module Clowne
  class Plan
    Step = Struct.new(:key, :declaration)

    def initialize
      @steps = []
    end

    def validate!
      dups = @steps.group_by(&:key).select { |_step, count| count.size > 1 }.map(&:first)
      if dups.any?
        raise Clowne::ConfigurationError.new("You have duplicate configurations with keys: #{dups.join(', ')}")
      else
        true
      end
    end

    def get(key)
      key = key.to_sym
      @steps.detect { |step| step.key == key }
    end

    def add(key, declaration)
      @steps << Step.new(key.to_sym, declaration)
      self
    end

    def update(key, declaration)
      position = @steps.index(get(key))
      if position
        @steps[position] = Step.new(key, declaration)
        self
      else
        add(key, declaration)
      end
    end

    def delete(key)
      key = key.to_sym
      @steps.reject! { |step| step.key == key }
      self
    end

    def declarations
      @steps.map(&:declaration)
    end
  end
end
