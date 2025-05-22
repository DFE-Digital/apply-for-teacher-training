class CandidatePoolApplication < ApplicationRecord
  belongs_to :application_form
  belongs_to :candidate
end
