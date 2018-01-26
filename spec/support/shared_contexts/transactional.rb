# frozen_string_literal: true

shared_context 'transactional:active_record', transactional: :active_record do
  prepend_before(:each) do
    ActiveRecord::Base.connection.begin_transaction(joinable: false)
  end

  append_after(:each) do
    ActiveRecord::Base.connection.rollback_transaction
  end
end

shared_context 'transactional:sequel', transactional: :sequel do
  prepend_before(:each) do
    @conn = SEQUEL_DB.pool.send :acquire, Thread.current
    SEQUEL_DB.send(:add_transaction, @conn, {})
    SEQUEL_DB.send(:begin_transaction, @conn, savepoint: true)
  end

  append_after(:each) do
    SEQUEL_DB.send(:rollback_transaction, @conn, savepoint: true)
    SEQUEL_DB.send(:remove_transaction, @conn, false)
    SEQUEL_DB.pool.send(:sync) { SEQUEL_DB.pool.send(:release, Thread.current) }
  end
end
