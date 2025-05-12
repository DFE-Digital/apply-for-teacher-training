class ReasonsForRejectionApplicationsQuery
  include Pagy::Backend

  PAGY_PER_PAGE = 30

  attr_accessor :filters
  attr_reader :recruitment_cycle_year

  def initialize(filters)
    @filters = filters
    @recruitment_cycle_year = filters.fetch(:recruitment_cycle_year, RecruitmentCycleTimetable.current_year)
  end

  def call
    application_choices = ApplicationChoice
      .where(current_recruitment_cycle_year: recruitment_cycle_year)
      .where.not(structured_rejection_reasons: nil)
      .order(created_at: :desc)

    application_choices = apply_filters(application_choices)
    _, results = pagy(application_choices, page: filters[:page], limit: PAGY_PER_PAGE)
    results
  end

private

  def apply_filters(application_choices)
    filters[:structured_rejection_reasons].each do |key, value|
      application_choices = if key == 'id'
                              filter_by_top_level_group(application_choices, value)
                            else
                              filter_by_subgroup(application_choices, key, value)
                            end
    end

    application_choices
  end

  def filter_by_top_level_group(application_choices, top_level_group)
    application_choices
      .where(
        "structured_rejection_reasons->'selected_reasons' @> ?",
        JSON.generate([{ id: top_level_group }]),
      )
  end

  def filter_by_subgroup(application_choices, top_level_group, subgroup)
    filter_by_top_level_group(application_choices, top_level_group)
      .where(
        "structured_rejection_reasons->'selected_reasons' @> ?",
        JSON.generate([{ selected_reasons: [{ id: subgroup }] }]),
      )
  end
end
