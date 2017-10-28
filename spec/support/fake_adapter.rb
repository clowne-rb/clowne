class FakeAdapter < Clowne::BaseAdapter::Adapter
  class << self
    def reflections_for(record)
      {
        "posts" => nil,
        "users" => nil
      }
    end
  end
end
