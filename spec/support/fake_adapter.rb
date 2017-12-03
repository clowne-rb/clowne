class FakeAdapter < Clowne::Adapters::Base
end

FakeAdapter.register_copier(proc { |source| source.dup })
