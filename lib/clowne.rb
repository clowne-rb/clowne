require 'clowne/version'
require 'clowne/dsl'
require 'clowne/configuration'
require 'clowne/cloner'

require 'clowne/declarations/exclude_association'
require 'clowne/declarations/finalize'
require 'clowne/declarations/include_all'
require 'clowne/declarations/include_association'
require 'clowne/declarations/nullify'

require 'clowne/base_adapter/finalize'
require 'clowne/base_adapter/nullify'
require 'clowne/base_adapter/adapter'

require 'clowne/active_record_adapter/clone_association'
require 'clowne/active_record_adapter/adapter'


class PostCloner < Clowne::Cloner
  include_association :comments
  include_association :posts, -> (params) { where.not(user_id: params[:user_id]) }

  finalize do |source, record, params|
    record.user_id = params[:user_id]
  end
end
