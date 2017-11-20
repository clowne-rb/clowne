# frozen_string_literal: true

module Clowne
  module DSL # :nodoc: all
    def adapter(adapter = Clowne.default_adapter)
      @_adapter ||= adapter
    end

    def config(init_config = Clowne::Configuration.new)
      @_config ||= init_config
    end

    # Specify target class for cloner.
    # Used for `#include_all`
    def cloner_for(target_class)
      @_target_class = target_class
    end

    def target_class
      @_target_class
    end

    def include_all
      config.add_include_all
    end

    def include_association(name, scope = nil, **options)
      config.add_included_association(name, scope, options)
    end

    def include_associations(*names)
      names.each do |name|
        config.add_included_association(name)
      end
    end

    def exclude_associations(*names)
      names.each do |name|
        config.add_excluded_association(name)
      end
    end

    alias exclude_association exclude_associations

    def nullify(*attrs)
      attrs.each do |attr|
        config.add_nullify(attr)
      end
    end

    def finalize(&block)
      config.add_finalize(block)
    end

    def trait(name, &block)
      config.add_trait(name, block)
    end
  end
end
