class MonthlyStatisticsController < ApplicationController
  def show
    @monthly_statistics_report = MonthlyStatisticsReport.last
    @statistics = @monthly_statistics_report.statistics
    @academic_year_name = RecruitmentCycle.cycle_name(CycleTimetable.next_year)
    @current_cycle_name = RecruitmentCycle.verbose_cycle_name
    @candidates_by_status_export = DataExport.where(export_type: 'monthly_statistics_candidates_by_status').order(:created_at).last
    @applications_by_status_export = DataExport.where(export_type: 'monthly_statistics_applications_by_status').order(:created_at).last
    @candidates_by_age_group_export = DataExport.where(export_type: 'monthly_statistics_candidates_by_age_group').order(:created_at).last
    @candidates_by_sex_export = DataExport.where(export_type: 'monthly_statistics_candidates_by_sex').order(:created_at).last
    @candidates_by_area_export = DataExport.where(export_type: 'monthly_statistics_candidates_by_area').order(:created_at).last
    @applications_by_course_type_exportage_group_export = DataExport.where(export_type: 'monthly_statistics_applications_by_course_age_group').order(:created_at).last
    @applications_by_course_type_export = DataExport.where(export_type: 'monthly_statistics_applications_by_course_type').order(:created_at).last
    @applications_by_primary_specialist_subject_export = DataExport.where(export_type: 'monthly_statistics_applications_by_primary_specialist_subject').order(:created_at).last
    @applications_by_secondary_subject_export = DataExport.where(export_type: 'monthly_statistics_applications_by_secondary_subject').order(:created_at).last
    @applications_by_provider_area_export = DataExport.where(export_type: 'monthly_statistics_applications_by_provider_area').order(:created_at).last
    @candidates_export = DataExport.where(export_type: 'external_report_candidates').order(:created_at).last
    @applications_export = DataExport.where(export_type: 'external_report_applications').order(:created_at).last
  end
end
