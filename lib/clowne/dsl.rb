module Clowne
  module DSL
    def include_association(name, scope = nil)
      config.add_association(name, scope)
    end

    def exclude_association(name)
      config.remove_association(name)
    end

    def finalize(&block)
      config.add_finalize(block)
    end

    def config
      @config ||= Clowne::Configuration.new
    end
  end
end
