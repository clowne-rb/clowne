module Clowne
  module ActiveRecordAdapter
    # o.public_send(:order_items).instance_exec({id: 1}, &Proc.new { |params| where(id: params[:id]) })

    class Association
      def self.call(source, record, declaration)
        reflection = CloneAssociation.new(source, declaration).reflection

        if reflection.is_a?(::ActiveRecord::Reflection::ThroughReflection)
          record
        elsif reflection.is_a?(::ActiveRecord::Reflection::HasOneReflection)
          CloneHasOneAssociation.new(source, declaration).call(record)
        elsif reflection.is_a?(::ActiveRecord::Reflection::HasManyReflection)
          CloneHasManyAssociation.new(source, declaration).call(record)
        elsif reflection.is_a?(::ActiveRecord::Reflection::HasAndBelongsToManyReflection)
          CloneHasAndBelongsToManyAssociation.new(source, declaration).call(record)
        else
          warn("Reflection #{reflection.class.name} does not support")
          record
        end
      end
    end

    class CloneAssociation
      # Params:
      # +source+:: Instance of cloned object (ex: User.new(posts: posts))
      # +declaration+:: = Relation description (ex: Clowne::Declarations::IncludeAssociation.new(:posts))
      def initialize(source, declaration)
        @source, @declaration = source, declaration
        @association_name = declaration.name.to_s
      end

      def call(record)
        raise NotImplementedError
      end

      def association
        @_association ||= source.__send__(association_name)
      end

      def reflection
        @_reflection ||= begin
          reflections = Clowne::ActiveRecordAdapter::Adapter.reflections_for(source)
          reflections[association_name]
        end
      end

      def clone_with(child)
        if declaration.custom_cloner
          @_plan ||= Clowne::Planner.compile(declaration.custom_cloner, child, **declaration.options)
          Clowne::ActiveRecordAdapter::Adapter.clone(child, @_plan)
        else
          Clowne::ActiveRecordAdapter::Adapter.plain_clone(child)
        end
      end

      def with_scope
        base_scope = association
        if declaration.scope.is_a?(Symbol)
          base_scope.__send__(declaration.scope)
        elsif declaration.scope.is_a?(Proc)
          base_scope.instance_exec(&declaration.scope)
        else
          base_scope
        end
      end

      private

      attr_reader :source, :declaration, :association_name
    end

    class CloneHasOneAssociation < CloneAssociation
      def call(record)
        child = association
        return record unless child
        warn "Has one association should not has scope" unless declaration.scope.nil?

        child_clone = clone_with(child)
        child_clone[:"#{reflection.foreign_key}"] = nil
        record.__send__(:"#{association_name}=", child_clone)

        record
      end
    end

    class CloneHasManyAssociation < CloneAssociation
      def call(record)
        with_scope.each do |child|
          child_clone = clone_with(child)
          child_clone[:"#{reflection.foreign_key}"] = nil
          record.__send__(association_name) << child_clone
        end

        record
      end
    end

    class CloneHasAndBelongsToManyAssociation < CloneAssociation
      def call(record)
        with_scope.each do |child|
          child_clone = clone_with(child)
          record.__send__(association_name) << child_clone
        end

        record
      end
    end
  end
end
