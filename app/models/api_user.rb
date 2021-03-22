# ActiveHash allows you to create ActiveRecord-like objects that are hard
# coded. This saves us from having to make changes to the database to create
# this model.
#
# To obtain an API token for a user, run this in the console:
#
#   APIUser.tad_user.create_magic_link_token!
class APIUser < ActiveHash::Base
  include ActiveHash::Associations
  include AuthenticatedUsingMagicLinks

  self.data = [
    { id: 1, name: 'User for testing, not used in production', api_type: 'TestAPI' },
    { id: 2, name: 'DfE TAD', api_type: 'DataAPI' },
    { id: 3, name: 'DfE Register', api_type: 'RegisterAPI' },
  ]

  def self.test_data_user
    find(1)
  end

  def self.tad_user
    find(2)
  end

  def self.register_user
    find(3)
  end

  # Fix a bug in ActiveHash that causes the user_type in a AuthenticationToken to
  # be set to `ActiveHash::Base` instead of `APIUser`.
  def self.polymorphic_name
    'APIUser'
  end
end
