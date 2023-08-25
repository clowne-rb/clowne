# frozen_string_literal: true

%i[active_record sequel].each do |adapter|
  shared_context "adapter:#{adapter}" do
    before(:all) do
      @was_adapter = Clowne.default_adapter
      Clowne.default_adapter = adapter
    end

    after(:all) do
      Clowne.default_adapter = @was_adapter
    end
  end
end
