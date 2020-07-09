class IeltsQualification < ApplicationRecord
  has_one :english_language_proficiency, as: :efl_qualification
end
