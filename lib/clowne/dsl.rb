module Clowne
  module DSL
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

    def context(name, &block)
      config.add_context(name, block)
    end

    def config
      @config ||= Clowne::Configuration.new
    end
  end
end
