class PossiblePreviousTeacherTraining < ApplicationRecord
  belongs_to :candidate
  belongs_to :provider, optional: true

  validates :provider_name, :started_on, :ended_on, presence: true
  validates :ended_on, presence: true, comparison: { greater_than_or_equal_to: :started_on }

  def formatted_dates
    "From #{started_on.to_fs(:month_and_year)} to #{ended_on.to_fs(:month_and_year)}"
  end
end
