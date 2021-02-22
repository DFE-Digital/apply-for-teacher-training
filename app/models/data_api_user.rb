class DataAPIUser < ActiveHash::Base
  include ActiveHash::Associations
  include AuthenticatedUsingMagicLinks

  self.data = [
    { id: 1, name: 'User for testing, not used in production' },
    { id: 2, name: 'DfE TAD' },
  ]

  def self.polymorphic_name
    'DataAPIUser'
  end
end
