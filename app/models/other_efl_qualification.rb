class OtherEflQualification < ApplicationRecord
  has_one :english_proficiency, as: :efl_qualification, touch: true, dependent: nil

  def unique_reference_number
    nil
  end
end
