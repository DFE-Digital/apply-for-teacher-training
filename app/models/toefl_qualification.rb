class ToeflQualification < ApplicationRecord
  has_one :english_proficiency, as: :efl_qualification, touch: true

  def name
    'TOEFL'
  end

  def grade
    total_score
  end

  def unique_reference_number
    registration_number
  end
end
