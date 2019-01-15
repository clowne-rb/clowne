# frozen_string_literal: true

require 'clowne/version'
require 'clowne/declarations'
require 'clowne/cloner'

require 'clowne/adapters/base'

# Declarative models cloning
module Clowne
  # List of built-in adapters
  # rubocop:disable AlignHash
  ADAPTERS = {
    base:          'Base',
    active_record: 'ActiveRecord',
    sequel:        'Sequel'
  }.freeze
  # rubocop:enable AlignHash

  class << self
    attr_reader :default_adapter, :raise_on_override

    # Set default adapters for all cloners
    def default_adapter=(adapter)
      @default_adapter = resolve_adapter(adapter)
    end

    def resolve_adapter(adapter)
      if adapter.is_a?(Class)
        adapter.new
      elsif adapter.is_a?(Symbol)
        adapter_class = ADAPTERS[adapter]
        raise "Unknown adapter: #{adapter}" if adapter_class.nil?

        Clowne::Adapters.const_get(adapter_class).new
      else
        adapter
      end
    end
  end
end

require 'clowne/adapters/active_record' if defined?(::ActiveRecord)
require 'clowne/adapters/sequel' if defined?(::Sequel)
