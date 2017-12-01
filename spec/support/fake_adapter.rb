class FakeAdapter < Clowne::Adapters::Base
end

FakeAdapter.register_copier(Proc.new { |source| source.dup })
