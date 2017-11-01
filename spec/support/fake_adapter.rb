class FakeAdapter < Clowne::BaseAdapter::Adapter
  class << self
    def reflections_for(record)
      if record.respond_to?(:reflections)
        record.reflections
      else
        fake_reflections
      end
    end

    private

    def fake_reflections
      {
        "users" => nil,
        "posts" => nil
      }
    end
  end
end
