class DfESigninSession < ApplicationRecord
  belongs_to :user, polymorphic: true
end
