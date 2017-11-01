module Clowne
  module DSL
    def adapter(adapter = nil)
      @_adapter ||= begin
        adapter || (parent_is_cloner? ? superclass.adapter : nil)
      end
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
      @_config ||= begin
        if parent_is_cloner?
          Clowne::Configuration.new(superclass.config.config.dup)
        else
          Clowne::Configuration.new
        end
      end
    end

    private

    def parent_is_cloner?
      superclass.ancestors.include?(Clowne::Cloner)
    end
  end
end
