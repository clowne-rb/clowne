# frozen_string_literal: true

require 'clowne/utils/clone_mapper'

module Clowne
  module Utils
    class Operation # :nodoc: all
      THREAD_KEY = :"#{name}.clowne_operation"
      DEFAULT_MAPPER = Utils::CloneMapper

      private_constant :THREAD_KEY

      class << self
        def current
          Thread.current[THREAD_KEY]
        end

        def wrap(mapper: nil)
          return yield if current

          Thread.current[THREAD_KEY] = new(mapper || DEFAULT_MAPPER.new)

          current.tap do |operation|
            operation.clone = yield
            clear!
          end
        end

        def clear!
          Thread.current[THREAD_KEY] = nil
        end
      end

      attr_writer :clone
      attr_reader :mapper

      def initialize(mapper)
        @after_clone_blocks = []
        @after_persist_blocks = []
        @mapper = mapper
      end

      def add_after_persist(block)
        @after_persist_blocks.unshift(block)
      end

      def add_after_clone(block)
        @after_clone_blocks.unshift(block)
      end

      def add_mapping(origin, clone)
        @mapper.add(origin, clone)
      end

      def to_record
        return @_record if defined?(@_record)

        @_record = @clone.tap do
          run_after_clone
        end
      end

      def persist!
        to_record.save!.tap do
          run_after_persist
        end
      end

      def persist
        to_record.save.tap do |result|
          next unless result

          run_after_persist
        end
      end

      def save
        warn '[DEPRECATION] `save` is deprecated.  Please use `persist` instead.'
        @clone.save
      end

      def save!
        warn '[DEPRECATION] `save!` is deprecated.  Please use `persist!` instead.'
        @clone.save!
      end

      def run_after_persist
        @after_persist_blocks.each(&:call)
      end

      def run_after_clone
        @after_clone_blocks.each(&:call)
      end
    end
  end
end
