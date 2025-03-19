# frozen_string_literal: true

shared_context "transactional:active_record", transactional: :active_record do
  prepend_before(:each) do
    ActiveRecord::Base.connection.begin_transaction(joinable: false)
  end

  append_after(:each) do
    ActiveRecord::Base.connection.rollback_transaction
  end
end

shared_context "transactional:sequel", transactional: :sequel do
  around(:each) do |example|
    SEQUEL_DB.transaction(rollback: :always, auto_savepoint: true) { example.run }
  end
end
