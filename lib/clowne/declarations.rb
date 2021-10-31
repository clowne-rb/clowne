# frozen_string_literal: true

require "clowne/dsl"
require "clowne/utils/plan"

module Clowne
  module Declarations # :nodoc:
    module_function

    def add(id, declaration = nil, &block)
      declaration = block if block

      if declaration.is_a?(Class)
        DSL.send(:define_method, id) do |*args, **hargs, &inner_block|
          declarations.push declaration.new(*args, **hargs, &inner_block)
        end
      elsif declaration.is_a?(Proc)
        DSL.send(:define_method, id, &declaration)
      else
        raise ArgumentError, "Unsupported declaration type: #{declaration.class}"
      end
    end
  end
end

require "clowne/declarations/base"
require "clowne/declarations/init_as"
require "clowne/declarations/exclude_association"
require "clowne/declarations/finalize"
require "clowne/declarations/include_association"
require "clowne/declarations/nullify"
require "clowne/declarations/trait"
require "clowne/declarations/after_persist"
require "clowne/declarations/after_clone"
