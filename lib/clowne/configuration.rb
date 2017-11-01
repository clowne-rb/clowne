module Clowne
  class Configuration
    attr_reader :config

    def initialize(init_conf = [])
      @config = init_conf
    end

    def add_include_all
      @config.push(Clowne::Declarations::IncludeAll.new)
    end

    def add_included_association(name, scope, options)
      @config.push(Clowne::Declarations::IncludeAssociation.new(name, scope, options))
    end

    def add_excluded_association(name)
      @config.push(Clowne::Declarations::ExcludeAssociation.new(name))
    end

    def add_nullify(attrs)
      @config.push(Clowne::Declarations::Nullify.new(attrs))
    end

    def add_finalize(block)
      @config.push(Clowne::Declarations::Finalize.new(block))
    end

    def add_trait(name, block)
      @config.push(Clowne::Declarations::Trait.new(name, block))
    end
  end
end
