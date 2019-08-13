class Candidate < ApplicationRecord
  passwordless_with :email
end
