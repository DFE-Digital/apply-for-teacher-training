class GenerateRecruitmentPerformanceReports
  def self.call
    new.call
  end

  def call
    return if HostingEnvironment.production?

    recruitment_cycle_year = RecruitmentCycleTimetable.current_year
    cycle_week = 32
    ActiveRecord::Base.transaction do
      FactoryBot.create(:regional_edi_report, recruitment_cycle_year:, cycle_week:)
      FactoryBot.create(:regional_edi_report, :disability, recruitment_cycle_year:, cycle_week:)
      FactoryBot.create(:regional_edi_report, :ethnic_group, recruitment_cycle_year:, cycle_week:)
      FactoryBot.create(:regional_edi_report, :age_group, recruitment_cycle_year:, cycle_week:)

      FactoryBot.create(:regional_edi_report, region: :london, recruitment_cycle_year:, cycle_week:)
      FactoryBot.create(:regional_edi_report, :disability, region: :london, recruitment_cycle_year:, cycle_week:)
      FactoryBot.create(:regional_edi_report, :ethnic_group, region: :london, recruitment_cycle_year:, cycle_week:)
      FactoryBot.create(:regional_edi_report, :age_group, region: :london, recruitment_cycle_year:, cycle_week:)

      FactoryBot.create(:regional_recruitment_performance_report, recruitment_cycle_year:, cycle_week:)
      FactoryBot.create(:national_recruitment_performance_report, recruitment_cycle_year:, cycle_week:)

      Provider.all.each do |provider|
        FactoryBot.create(:provider_edi_report, provider:, recruitment_cycle_year:, cycle_week:)
        FactoryBot.create(:provider_edi_report, :disability, provider:, recruitment_cycle_year:, cycle_week:)
        FactoryBot.create(:provider_edi_report, :ethnic_group, provider:, recruitment_cycle_year:, cycle_week:)
        FactoryBot.create(:provider_edi_report, :age_group, provider:, recruitment_cycle_year:, cycle_week:)
        FactoryBot.create(:provider_recruitment_performance_report, provider:, recruitment_cycle_year:, cycle_week:)
      end
    end
  end
end
