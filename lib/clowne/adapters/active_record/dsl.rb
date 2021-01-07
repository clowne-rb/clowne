# frozen_string_literal: true

module Clowne
  module Adapters
    # Extend ActiveRecord with Clowne DSL and methods
    module ActiveRecordDSL
      module InstanceMethods # :nodoc:
        # Shortcut to call class's cloner call with self
        def clowne(**args, &block)
          self.class.cloner_class.call(self, **args, &block)
        end
      end

      module ClassMethods # :nodoc:
        def clowne_config(options = {}, &block)
          if options.delete(:inherit) != false && superclass.respond_to?(:cloner_class)
            parent_cloner = superclass.cloner_class
          end

          parent_cloner ||= Clowne::Cloner
          cloner = instance_variable_set(:@_clowne_cloner, Class.new(parent_cloner))
          cloner.adapter :active_record
          cloner.instance_exec(&block)
        end
      end
    end
  end
end

ActiveSupport.on_load(:active_record) do
  ::ActiveRecord::Base.extend Clowne::Adapters::ActiveRecordDSL::ClassMethods
  ::ActiveRecord::Base.include Clowne::Adapters::ActiveRecordDSL::InstanceMethods
end
