module ClowneHelpers
  def use_adapter(adapter)
    was_adapter = Clowne.default_adapter
    Clowne.default_adapter = adapter
    yield
  ensure
    Clowne.default_adapter = was_adapter
  end
end
