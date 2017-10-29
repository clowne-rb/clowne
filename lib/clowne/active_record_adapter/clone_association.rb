module Clowne
  module ActiveRecordAdapter
    # o.public_send(:order_items).instance_exec({id: 1}, &Proc.new { |params| where(id: params[:id]) })

    class Association
      def self.call(source, record, declaration)
        reflection = CloneAssociation.get_reflection(source, declaration)

        if reflection.is_a?(::ActiveRecord::Reflection::ThroughReflection)
          record
        elsif reflection.is_a?(::ActiveRecord::Reflection::HasOneReflection)
          CloneHasOneAssociation.call(source, record, declaration)
        elsif reflection.is_a?(::ActiveRecord::Reflection::HasManyReflection)
          CloneHasManyAssociation.call(source, record, declaration)
        elsif reflection.is_a?(::ActiveRecord::Reflection::HasAndBelongsToManyReflection)
          CloneHasAndBelongsToManyAssociation.call(source, record, declaration)
        else
          warn("Reflection #{reflection.class.name} does not support")
          record
        end
      end
    end

    class CloneAssociation
      class << self
        def clone_with(source, declaration)
          if declaration.custom_cloner
            plan = Clowne::Planner.compile(declaration.custom_cloner, source, **declaration.options).values
            Clowne::ActiveRecordAdapter::Adapter.clone(source, plan)
          else
            Clowne::ActiveRecordAdapter::Adapter.plain_clone(source)
          end
        end

        def with_scope(source, declaration)
          base_scope = get_association(source, declaration)
          if declaration.scope.is_a?(Symbol)
            base_scope.__send__(declaration.scope)
          elsif declaration.scope.is_a?(Proc)
            base_scope.instance_exec(&declaration.scope)
          else
            base_scope
          end
        end

        def get_association(source, declaration)
          source.__send__(declaration.name.to_s)
        end

        def get_reflection(source, declaration)
          reflections = Clowne::ActiveRecordAdapter::Adapter.reflections_for(source)
          reflection = reflections[declaration.name.to_s]
        end
      end
    end

    class CloneHasOneAssociation < CloneAssociation
      def self.call(source, record, declaration)
        reflection = get_reflection(source, declaration)

        child = get_association(source, declaration)
        return record unless child
        warn "Has one association should not has scope" unless declaration.scope.nil?

        child_clone = clone_with(child, declaration)
        child_clone[:"#{reflection.foreign_key}"] = nil
        record.__send__(:"#{declaration.name}=", child_clone)

        record
      end
    end

    class CloneHasManyAssociation < CloneAssociation
      def self.call(source, record, declaration)
        reflection = get_reflection(source, declaration)

        with_scope(source, declaration).each do |child|
          child_clone = clone_with(child, declaration)
          child_clone[:"#{reflection.foreign_key}"] = nil
          record.__send__(declaration.name) << child_clone
        end

        record
      end
    end

    class CloneHasAndBelongsToManyAssociation < CloneAssociation
      def self.call(source, record, declaration)
        reflection = get_reflection(source, declaration)

        with_scope(source, declaration).each do |child|
          child_clone = clone_with(child, declaration)
          record.__send__(declaration.name) << child_clone
        end

        record
      end
    end
  end
end
