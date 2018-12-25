# frozen_string_literal: true

require 'clowne/utils/source_mapping'

module Clowne
  module Utils
    class Operation # :nodoc: all
      THREAD_KEY = :"#{name}.clowne_operation"
      private_constant :THREAD_KEY

      class << self
        def current
          Thread.current[THREAD_KEY]
        end

        def wrap(operation_class = self)
          return yield if current

          Thread.current[THREAD_KEY] = operation_class.new

          current.tap do |operation|
            operation.clone = yield
            clear!
          end
        end

        def clear!
          Thread.current[THREAD_KEY] = nil
        end
      end

      attr_accessor :clone
      attr_reader :mapper

      def initialize
        @post_processings = []
        @mapper = Utils::SourceMapping.new
      end

      def add_post_processing(block)
        @post_processings.unshift(block)
      end

      def add_mapping(origin, clone)
        @mapper.add(origin, clone)
      end

      def save
        @clone.save
      end

      def do_post_processing!
        @post_processings.each(&:call)
      end
    end
  end
end
