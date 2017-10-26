module Clowne
  module ActiveRecordAdapter
    # o.public_send(:order_items).instance_exec({id: 1}, &Proc.new { |params| where(id: params[:id]) })

    class CloneAssociation
      def self.call(source, record, declaration)
        reflections = record.class.reflections
        reflection = reflections[declaration.association.to_s]
        if reflection.is_a?(::ActiveRecord::Reflection::ThroughReflection)
          record
        else#if reflection.is_a?(::ActiveRecord::Reflection::HasOneReflection)
          CloneHasOneAssociation.call(source, record, declaration)
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
        # child_clone[:"#{reflection.foreign_key}"] = nil # TODO: use nullify ?
        record.__send__(:"#{association}=", child_clone)

        record
      end
    end
  end
end
