module Clowne
  module ActiveRecordAdapter
    # o.public_send(:order_items).instance_exec({id: 1}, &Proc.new { |params| where(id: params[:id]) })

    class CloneAssociation
      def self.call(source, record, declaration)
        reflections = record.class.reflections
        reflection = reflections[declaration.association.to_s]
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

    class CloneHasOneAssociation
      def self.call(source, record, declaration)
        reflections = record.class.reflections
        association = declaration.association
        reflection = reflections[declaration.association.to_s]
        child = source.__send__(association)
        return record unless child
        child_clone = child.dup # TODO: use cloner!
        child_clone[:"#{reflection.foreign_key}"] = nil # TODO: use nullify ?
        record.__send__(:"#{association}=", child_clone)

        record
      end
    end

    class CloneHasManyAssociation
      def self.call(source, record, declaration)
        reflections = record.class.reflections
        association = declaration.association
        reflection = reflections[declaration.association.to_s]

        source.__send__(association).each do |child|
          child_clone = child.dup # TODO: use cloner!
          child_clone[:"#{reflection.foreign_key}"] = nil # TODO: use nullify ?
          record.__send__(association) << child_clone
        end

        record
      end
    end

    class CloneHasAndBelongsToManyAssociation
      def self.call(source, record, declaration)
        reflections = record.class.reflections
        association = declaration.association
        reflection = reflections[declaration.association.to_s]

        source.__send__(association).each do |child|
          child_clone = child.dup # TODO: use cloner!
          record.__send__(association) << child_clone
        end

        record
      end
    end
  end
end
