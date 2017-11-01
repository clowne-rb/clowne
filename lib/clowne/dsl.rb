module Clowne
  module DSL
    def adapter(adapter = nil)
      @_adapter ||= (adapter || init_adapter)
    end

    def include_all
      config.add_include_all
    end

    def include_association(name, scope = nil, **options)
      config.add_included_association(name, scope, options)
    end

    def exclude_association(name)
      config.add_excluded_association(name)
    end

    def nullify(*attrs)
      config.add_nullify(attrs)
    end

    def finalize(&block)
      config.add_finalize(block)
    end

    def trait(name, &block)
      config.add_trait(name, block)
    end

    def config
      @_config ||= Clowne::Configuration.new(init_declarations)
    end

    private

    def init_adapter
      superclass.adapter if parent_is_cloner?
    end

    def init_declarations
      parent_is_cloner? ? superclass.config.declarations.dup : []
    end

    def parent_is_cloner?
      superclass.ancestors.include?(Clowne::Cloner)
    end
  end
end
