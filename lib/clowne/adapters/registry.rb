# frozen_string_literal: true

module Clowne
  module Adapters
    class Registry # :nodoc: all
      module Container
        def self.included(base)
          base.extend ClassMethods

          base.class_eval do
            self.registry = Registry.new

            def registry
              self.class.registry
            end

            def resolver_for(type)
              self.class.resolver_for(type)
            end
          end
        end

        module ClassMethods
          attr_reader :registry

          def inherited(subclass)
            # Duplicate registry
            subclass.registry = registry.dup
          end

          def resolver_for(type)
            registry.mapping[type] || raise("Uknown resolver #{type} for #{self}")
          end

          def register_resolver(type, resolver, after: nil, before: nil, prepend: nil)
            registry.mapping[type] = resolver

            if prepend
              registry.unshift type
            elsif after
              registry.insert_after after, type
            elsif before
              registry.insert_before before, type
            else
              registry.append type
            end
          end

          protected

          attr_writer :registry
        end
      end

      attr_reader :actions, :mapping

      def initialize
        @actions = []
        @mapping = {}
      end

      def insert_after(after, action)
        actions.delete(action)

        after_index = actions.find_index(after)

        raise "Plan action not found: #{after}" if after_index.nil?

        actions.insert(after_index + 1, action)
      end

      def insert_before(before, action)
        actions.delete(action)

        before_index = actions.find_index(before)

        raise "Plan action not found: #{before}" if before_index.nil?

        actions.insert(before_index, action)
      end

      def append(action)
        actions.delete(action)
        actions.push action
      end

      def unshift(action)
        actions.delete(action)
        actions.unshift action
      end

      def dup
        self.class.new.tap do |duped|
          actions.each { |act| duped.append(act) }
          duped.mapping = mapping.dup
        end
      end

      protected

      attr_writer :mapping
    end
  end
end
