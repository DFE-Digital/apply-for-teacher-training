class OtherEflQualification < ApplicationRecord
  has_one :english_proficiency, as: :efl_qualification
end
