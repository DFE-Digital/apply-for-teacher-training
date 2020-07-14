class IeltsQualification < ApplicationRecord
  has_one :english_proficiency, as: :efl_qualification

  def name
    'IELTS'
  end
end
