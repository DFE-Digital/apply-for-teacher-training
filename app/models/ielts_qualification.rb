class IeltsQualification < ApplicationRecord
  VALID_SCORES = %w[
    0.0
    0.5
    1.0
    1.5
    2.0
    2.5
    3.0
    3.5
    4.0
    4.5
    5.0
    5.5
    6.0
    6.5
    7.0
    7.5
    8.0
    8.5
    9.0
  ].freeze

  has_one :english_proficiency, as: :efl_qualification, touch: true

  def name
    'IELTS'
  end

  def grade
    band_score
  end

  def unique_reference_number
    trf_number
  end
end
