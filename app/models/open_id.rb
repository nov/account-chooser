class OpenId < ActiveRecord::Base
  attr_accessible :identifier

  belongs_to :account
  belongs_to :open_id_providers
end
