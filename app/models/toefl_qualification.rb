class ToeflQualification < ApplicationRecord
  has_one :english_language_proficiency, as: :efl_qualification

  def name
    'TOEFL'
  end
end
