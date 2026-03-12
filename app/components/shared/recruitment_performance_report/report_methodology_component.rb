module RecruitmentPerformanceReport
  class ReportMethodologyComponent < ApplicationComponent
    def initialize(
      provider_report:,
      comparison_link:,
      region: ReportSharedEnums.all_of_england_key
    )
      @provider_report = provider_report
      @current_timetable = provider_report.recruitment_cycle_timetable
      @region = region
      @comparison_link = comparison_link
    end

    def description
      if @provider_report.current_cycle?
        I18n.t(
          'shared.recruitment_performance_report.report_description_component.regional.this_report_shows',
          start_date: @provider_report.relative_previous_year,
          end_date: @provider_report.recruitment_cycle_year,
        )
      elsif @provider_report.previous_cycle?
        I18n.t(
          'shared.recruitment_performance_report.report_description_component.regional.previous_cycle_description',
          start_date: @provider_report.relative_previous_year,
          end_date: @provider_report.recruitment_cycle_year,
        )
      end
    end

    def links_list
      list = [
        govuk_link_to(t('shared.recruitment_performance_report.report_description_component.candidates_who_have_submitted_applications'), '#candidates_who_have_submitted_applications', no_visited_state: true),
        govuk_link_to(t('shared.recruitment_performance_report.report_description_component.candidates_with_an_offer'), '#candidates_with_an_offer', no_visited_state: true),
        govuk_link_to(t('shared.recruitment_performance_report.report_description_component.proportion_of_candidates_with_an_offer'), '#proportion_of_candidates_with_an_offer', no_visited_state: true),
        govuk_link_to(t('shared.recruitment_performance_report.report_description_component.offers_accepted'), '#offers_accepted', no_visited_state: true),
        govuk_link_to(t('shared.recruitment_performance_report.report_description_component.candidate_deferrals'), '#candidate_deferrals', no_visited_state: true),
        govuk_link_to(t('shared.recruitment_performance_report.report_description_component.candidates_rejected'), '#candidates_rejected', no_visited_state: true),
        govuk_link_to(t('shared.recruitment_performance_report.report_description_component.proportion_of_candidates_who_have_waited_30_days_or_more_for_a_response'), '#proportion_with_inactive_applications_table_component', no_visited_state: true),
      ]

      if FeatureFlag.active?(:provider_edi_report)
        list << govuk_link_to(t('shared.recruitment_performance_report.report_description_component.edi_title'), '#sex_disability_and_ethnicity_tables', no_visited_state: true)
      end

      list
    end
  end
end
