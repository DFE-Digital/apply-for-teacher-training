module CandidateInterface
  class WorkHistoryBreakForm
    include ActiveModel::Model
    include DateValidationHelper

    attr_accessor :start_date_day, :start_date_month, :start_date_year,
                  :end_date_day, :end_date_month, :end_date_year, :reason

    validate :start_date_valid
    validate :end_date_valid, unless: :end_date_blank?
    validate :end_date_before_current_year_and_month, if: :end_date_valid?
    validate :start_date_before_end_date, if: :start_date_and_end_date_valid?

    validates :reason, presence: true, word_count: { maximum: 400 }

    def start_date
      valid_or_invalid_start_date(start_date_year, start_date_month)
    end

    def end_date
      valid_end_date_or_nil(end_date_year, end_date_month)
    end
  end
end
