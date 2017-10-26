module Clowne
  class Configuration
    attr_reader :config

    def initialize
      @config ||= []
    end

    def raw
    end

    def plan
    end

    def add_association(name, scope)
      config << [name, scope]
    end

    def remove_association()
    end

    def add_nullify()
    end

    def add_finalize(block)
      config << block
    end

    def add_context()
    end

    private

    attr_accessor :config

    def merge
    end
  end
end
