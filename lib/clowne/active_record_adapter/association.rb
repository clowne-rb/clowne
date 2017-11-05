module Clowne
  module ActiveRecordAdapter
    class Association
      def self.call(source, record, declaration, params)
        reflection = CloneAssociation.new(source, declaration, params).reflection

        if reflection.is_a?(::ActiveRecord::Reflection::ThroughReflection)
          record
        elsif reflection.is_a?(::ActiveRecord::Reflection::HasOneReflection)
          CloneHasOneAssociation.new(source, declaration, params).call(record)
        elsif reflection.is_a?(::ActiveRecord::Reflection::HasManyReflection)
          CloneHasManyAssociation.new(source, declaration, params).call(record)
        elsif reflection.is_a?(::ActiveRecord::Reflection::HasAndBelongsToManyReflection)
          CloneHasAndBelongsToManyAssociation.new(source, declaration, params).call(record)
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
      # +params+:: = Instance of Clowne::Params
      def initialize(source, declaration, params)
        @source, @declaration, @params = source, declaration, params
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
          @_plan ||= build_plan(child)
          Clowne::ActiveRecordAdapter::Adapter.clone(child, @_plan, params)
        else
          Clowne::ActiveRecordAdapter::Adapter.plain_clone(child)
        end
      end

      def with_scope
        base_scope = association
        if declaration.scope.is_a?(Symbol)
          base_scope.__send__(declaration.scope)
        elsif declaration.scope.is_a?(Proc)
          base_scope.instance_exec(params, &declaration.scope)
        else
          base_scope
        end
      end

      private

      attr_reader :source, :declaration, :params, :association_name

      def build_plan(child)
        plan = Clowne::Planner.compile(declaration.custom_cloner, child, **declaration.options)
        plan.validate!
        plan
      end
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
