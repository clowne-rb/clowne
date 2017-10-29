module Clowne
  class Params
    attr_reader :params

    def initialize(params = {}, strategy = WarningStrategy)
      @params, @strategy = params, strategy
    end

    def [](key)
      if params.has_key?(key)
        params.fetch(key)
      else
        @strategy.execute(key)
      end
    end

    class WarningStrategy
      def self.execute(key)
        warn "You use params[#{key}] but this key is not defined. Skipped to nil"
        nil
      end
    end
  end
end
