class GenerateRecruitmentPerformanceReports
  def self.call
    new.call
  end

  def call
    return if HostingEnvironment.production?

    recruitment_cycle_year = RecruitmentCycleTimetable.current_year
    cycle_week = RecruitmentCycleTimetable.current_cycle_week

    previous_cycle = RecruitmentCycleTimetable.previous_year
    last_national_report = Publications::NationalRecruitmentPerformanceReport
      .last_in_year(previous_cycle)
    previous_cycle_week = last_national_report&.cycle_week || 52

    ActiveRecord::Base.transaction do
      reports_for_cycle(cycle_week, recruitment_cycle_year)
      reports_for_cycle(previous_cycle_week, previous_cycle)

      Provider.all.each do |provider|
        FactoryBot.create(:provider_edi_report, provider:, recruitment_cycle_year:, cycle_week:)
        FactoryBot.create(:provider_edi_report, :disability, provider:, recruitment_cycle_year:, cycle_week:)
        FactoryBot.create(:provider_edi_report, :disability_declaration, provider:, recruitment_cycle_year:, cycle_week:)
        FactoryBot.create(:provider_edi_report, :ethnic_group, provider:, recruitment_cycle_year:, cycle_week:)
        FactoryBot.create(:provider_edi_report, :age_group, provider:, recruitment_cycle_year:, cycle_week:)
        FactoryBot.create(:provider_recruitment_performance_report, provider:, recruitment_cycle_year:, cycle_week:)

        FactoryBot.create(
          :provider_edi_report,
          provider:,
          recruitment_cycle_year: previous_cycle,
          cycle_week: previous_cycle_week,
        )
        FactoryBot.create(
          :provider_edi_report,
          :disability,
          provider:,
          recruitment_cycle_year: previous_cycle,
          cycle_week: previous_cycle_week,
        )
        FactoryBot.create(
          :provider_edi_report,
          :disability_declaration,
          provider:,
          recruitment_cycle_year: previous_cycle,
          cycle_week: previous_cycle_week,
        )
        FactoryBot.create(
          :provider_edi_report,
          :ethnic_group,
          provider:,
          recruitment_cycle_year: previous_cycle,
          cycle_week: previous_cycle_week,
        )
        FactoryBot.create(
          :provider_edi_report,
          :age_group,
          provider:,
          recruitment_cycle_year: previous_cycle,
          cycle_week: previous_cycle_week,
        )
        FactoryBot.create(
          :provider_recruitment_performance_report,
          provider:,
          recruitment_cycle_year: previous_cycle,
          cycle_week: previous_cycle_week,
        )
      end
    end
  end

  def reports_for_cycle(cycle_week, recruitment_cycle_year)
    FactoryBot.create(:regional_edi_report, recruitment_cycle_year:, cycle_week:)
    FactoryBot.create(:regional_edi_report, :disability, recruitment_cycle_year:, cycle_week:)
    FactoryBot.create(:regional_edi_report, :disability_declaration, recruitment_cycle_year:, cycle_week:)
    FactoryBot.create(:regional_edi_report, :ethnic_group, recruitment_cycle_year:, cycle_week:)
    FactoryBot.create(:regional_edi_report, :age_group, recruitment_cycle_year:, cycle_week:)

    FactoryBot.create(:regional_edi_report, region: :london, recruitment_cycle_year:, cycle_week:)
    FactoryBot.create(:regional_edi_report, :disability, region: :london, recruitment_cycle_year:, cycle_week:)
    FactoryBot.create(:regional_edi_report, :disability_declaration, region: :london, recruitment_cycle_year:, cycle_week:)
    FactoryBot.create(:regional_edi_report, :ethnic_group, region: :london, recruitment_cycle_year:, cycle_week:)
    FactoryBot.create(:regional_edi_report, :age_group, region: :london, recruitment_cycle_year:, cycle_week:)

    FactoryBot.create(:regional_recruitment_performance_report, recruitment_cycle_year:, cycle_week:)
    FactoryBot.create(:national_recruitment_performance_report, recruitment_cycle_year:, cycle_week:)
  end

  def self.delete_all
    return if HostingEnvironment.production?

    ActiveRecord::Base.transaction do
      Publications::RegionalEdiReport.delete_all
      Publications::RegionalRecruitmentPerformanceReport.delete_all
      Publications::NationalRecruitmentPerformanceReport.delete_all
      Publications::ProviderEdiReport.delete_all
      Publications::ProviderRecruitmentPerformanceReport.delete_all
    end
  end
end
