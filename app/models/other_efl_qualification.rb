class OtherEflQualification < ApplicationRecord
  has_one :english_proficiency, as: :efl_qualification, touch: true

  def unique_reference_number
    nil
  end
end
