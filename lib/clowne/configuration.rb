module Clowne
  module Configuration
    attr_reader :config

    def initialize
      @config ||= []
    end

    def raw
    end

    def plan
    end

    def add_association()
    end

    def remove_association()
    end

    def add_nullify()
    end

    def add_finalize()
    end

    def add_context()
    end

    private

    def merge
    end
  end
end
