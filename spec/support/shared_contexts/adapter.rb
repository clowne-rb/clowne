shared_context 'adapter:active_record' do
  before(:all) do
    @was_adapter = Clowne.default_adapter
    Clowne.default_adapter = :active_record
  end

  after(:all) do
    Clowne.default_adapter = @was_adapter
  end
end
