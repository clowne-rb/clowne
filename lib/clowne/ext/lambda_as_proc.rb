# frozen_string_literal: true

module Clowne
  module Ext
    # Add to_proc method for lambda
    module LambdaAsProc
      refine Proc do
        def to_proc
          return self unless lambda?
          this = self
          proc { |*args| this.call(*args.take(this.arity)) }
        end
      end
    end
  end
end
