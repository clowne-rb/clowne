# frozen_string_literal: true

module Clowne
  module DSL # :nodoc: all
    def adapter(adapter = nil)
      @_adapter ||= adapter
    end

    def config(init_config = Clowne::Configuration.new)
      @_config ||= init_config
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
  end
end
