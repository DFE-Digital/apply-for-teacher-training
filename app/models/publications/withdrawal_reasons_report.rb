module Publications
  class WithdrawalReasonsReport < ApplicationRecord
    belongs_to :provider
    has_one :recruitment_cycle_timetable, primary_key: :recruitment_cycle_year, foreign_key: :recruitment_cycle_year, dependent: nil
  end
end
