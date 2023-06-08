module ProviderReportsHelper
  def mid_cycle_report_present_for?(provider)
    Publications::ProviderMidCycleReport.exists?(provider: provider)
  end

  def mid_cycle_report_label_for(provider)
    report = Publications::ProviderMidCycleReport.where(provider: provider).last
    report ? "#{cycle_year_for(report)} recruitment cycle performance" : ''
  end

  def cycle_year_for(mid_cycle_report)
    recruitment_cycle_year = CycleTimetable.current_year(mid_cycle_report.publication_date)
    "#{recruitment_cycle_year - 1} to #{recruitment_cycle_year}"
  end
end
