class ReasonsForRejectionApplicationsQuery
  attr_accessor :filters
  attr_reader :recruitment_cycle_year

  def initialize(filters)
    @filters = filters
    @recruitment_cycle_year = filters.fetch(:recruitment_cycle_year, RecruitmentCycle.current_year)
  end

  def call
    application_choices = ApplicationChoice
      .where(current_recruitment_cycle_year: recruitment_cycle_year)
      .where.not(structured_rejection_reasons: nil)
      .order(created_at: :desc)
      .page(filters[:page])
      .per(30)

    apply_filters(application_choices)
  end

private

  def apply_filters(application_choices)
    filters[:structured_rejection_reasons].each do |key, value|
      jsonb_query = case key
                    when ReasonsForRejection::OTHER_REASON.to_s
                      "->>:key != ''"
                    when /_y_n$/
                      '->>:key = :value'
                    else
                      '->:key ? :value'
                    end

      application_choices = application_choices.where(
        "application_choices.structured_rejection_reasons#{jsonb_query}", { key: key, value: value }
      )
    end

    application_choices
  end
end
