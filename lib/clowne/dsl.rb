module Clowne
  module DSL
    def include_association(name, scope = nil)
      config.add_association(name, scope)
    end

    def exclude_association(name)
      config.remove_association(name)
    end

    def config
      @config ||= []
    end
  end
end
