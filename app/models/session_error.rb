class SessionError < ApplicationRecord
  belongs_to :candidate, optional: true
end
