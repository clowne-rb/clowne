# frozen_string_literal: true

module Clowne
  class Operation # :nodoc: all
    THREAD_KEY = :"#{name}.clowne_operation"
    private_constant :THREAD_KEY

    class << self
      def current
        Thread.current[THREAD_KEY]
      end

      def wrap
        return yield if current

        Thread.current[THREAD_KEY] =
          new.tap do |operation|
            operation.clone = yield
            clear!
          end
      end

      def clear!
        Thread.current[THREAD_KEY] = nil
      end
    end

    attr_accessor :clone

    def initialize
      @post_processings = []
      @mapper = {}
    end

    def save
      @clone.save
    end
  end
end
