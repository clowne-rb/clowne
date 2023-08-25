# frozen_string_literal: true

module Clowne
  module Adapters # :nodoc: all
    class Base
      class Association
        # Params:
        # +reflection+:: Association eflection object
        # +source+:: Instance of cloned object (ex: User.new(posts: posts))
        # +declaration+:: = Relation description
        #                   (ex: Clowne::Declarations::IncludeAssociation.new(:posts))
        # +adapter+:: Clowne adapter
        # +params+:: = Instance of Hash
        def initialize(reflection, source, declaration, adapter, params)
          @source = source
          @declaration = declaration
          @adapter = adapter
          @params = params
          @association_name = declaration.name.to_s
          @reflection = reflection
        end

        def call(_record)
          raise NotImplementedError
        end

        def association
          @_association ||= source.__send__(association_name)
        end

        def clone_one(child)
          cloner = cloner_for(child)
          cloner ? cloner.call(child, **cloner_options) : dup_record(child)
        end

        def with_scope
          scope = declaration.scope
          if scope.is_a?(Symbol)
            init_scope.__send__(scope)
          elsif scope.is_a?(Proc)
            init_scope.instance_exec(params, &scope) || init_scope
          else
            init_scope
          end.to_a
        end

        private

        def dup_record(record)
          adapter.class.dup_record(record)
        end

        def init_scope
          raise NotImplementedError
        end

        def cloner_for(child)
          return declaration.clone_with if declaration.clone_with

          child.class.cloner_class if child.class.respond_to?(:cloner_class)
        end

        def cloner_options
          return @_cloner_options if defined?(@_cloner_options)

          @_cloner_options = declaration.params_proxy.permit(
            params: params, parent: source
          ).tap do |options|
            options[:adapter] = adapter
            options.merge!(traits: declaration.traits) if declaration.traits
          end
        end

        attr_reader :source, :declaration, :adapter, :params, :association_name, :reflection
      end
    end
  end
end
