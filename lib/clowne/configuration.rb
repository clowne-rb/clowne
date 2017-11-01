module Clowne
  class Configuration
    attr_reader :declarations

    def initialize(init_declarations = [])
      @declarations = init_declarations
    end

    def add_include_all
      @declarations.push(Clowne::Declarations::IncludeAll.new)
    end

    def add_included_association(name, scope, options)
      @declarations.push(Clowne::Declarations::IncludeAssociation.new(name, scope, options))
    end

    def add_excluded_association(name)
      @declarations.push(Clowne::Declarations::ExcludeAssociation.new(name))
    end

    def add_nullify(attrs)
      @declarations.push(Clowne::Declarations::Nullify.new(attrs))
    end

    def add_finalize(block)
      @declarations.push(Clowne::Declarations::Finalize.new(block))
    end

    def add_trait(name, block)
      @declarations.push(Clowne::Declarations::Trait.new(name, block))
    end
  end
end
