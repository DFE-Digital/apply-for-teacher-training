class AuthenticationToken < ApplicationRecord
  belongs_to :authenticable, polymorphic: true
end
