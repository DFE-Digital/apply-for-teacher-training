require 'rails_helper'

RSpec.describe Publications::V2::MonthlyStatisticsPresenter do
  let(:report) do
    create(:monthly_statistics_report,
           :v2,
           generation_date: 1.week.ago.beginning_of_day,
           publication_date: Time.zone.now.beginning_of_day)
  end

  subject(:presenter) { described_class.new(report) }

  describe '#publication_date' do
    it 'returns correct date' do
      expect(presenter.publication_date).to eq(report.publication_date)
    end
  end

  describe 'cycle year names', time: Date.new(2023, 11, 12) do
    describe '#current_cycle_name' do
      it 'returns string' do
        expect(presenter.current_cycle_name).to eq('2023 to 2024')
      end
    end

    describe '#academic_year_name' do
      it 'returns string' do
        expect(presenter.academic_year_name).to eq('2024 to 2025')
      end
    end

    describe '#current_cycle_verbose_name' do
      it 'returns string' do
        expect(presenter.current_cycle_verbose_name).to eq('October 2023 to September 2024')
      end
    end
  end

  describe '#current_year' do
    it 'returns correct year' do
      expect(presenter.current_year).to eq(2024)
    end
  end

  describe '#current_reporting_period' do
    it 'returns correct year' do
      expect(presenter.current_reporting_period).to eq('From 2 October 2023 to 12 November 2023')
    end
  end

  describe '#headline_stats' do
    it 'returns headline_stats', :aggregate_failures do
      scope = 'publications.itt_monthly_report_generator.status'
      expected = [{
        title: 'Submitted',
        summary: I18n.t('.submitted.summary', scope:),
        this_cycle: Numeric,
        last_cycle: Numeric,
      }, {
        title: 'With offers',
        summary: I18n.t('.with_offers.summary', scope:),
        this_cycle: Numeric,
        last_cycle: Numeric,
      }, {
        title: 'Accepted',
        summary: I18n.t('.accepted.summary', scope:),
        this_cycle: Numeric,
        last_cycle: Numeric,
      }, {
        title: 'All applications rejected',
        summary: I18n.t('.rejected.summary', scope:),
        this_cycle: Numeric,
        last_cycle: Numeric,
      }, {
        title: 'Reconfirmed from previous cycle',
        summary: I18n.t('.reconfirmed.summary', scope:),
        this_cycle: Numeric,
        last_cycle: Numeric,
      }, {
        title: 'Deferred',
        summary: I18n.t('.deferred.summary', scope:),
        this_cycle: Numeric,
        last_cycle: Numeric,
      }, {
        title: 'Withdrawn',
        summary: I18n.t('.withdrawn.summary', scope:),
        this_cycle: Numeric,
        last_cycle: Numeric,
      }, {
        title: 'Offer conditions not met',
        summary: I18n.t('.conditions_not_met.summary', scope:),
        this_cycle: Numeric,
        last_cycle: Numeric,
      }]

      presenter.headline_stats.each_with_index do |stat, index|
        expect(stat).to include(expected[index])
      end
    end
  end

  describe '#by_age' do
    it 'returns by_age' do
      expect(presenter.by_age).to include({
        title: I18n.t('publications.itt_monthly_report_generator.age_group.title'),
        data: Hash,
      })
    end
  end

  describe '#by_sex' do
    it 'returns by_sex' do
      expect(presenter.by_sex).to include({
        title: I18n.t('publications.itt_monthly_report_generator.sex.title'),
        data: Hash,
      })
    end
  end

  describe '#by_area' do
    it 'returns by_area' do
      expect(presenter.by_area).to include({
        title: I18n.t('publications.itt_monthly_report_generator.area.title'),
        data: Hash,
      })
    end
  end

  describe '#by_phase' do
    it 'returns by_phase' do
      expect(presenter.by_phase).to include({
        title: I18n.t('publications.itt_monthly_report_generator.phase.title'),
        data: Hash,
      })
    end
  end

  describe '#by_route' do
    it 'returns by_route' do
      expect(presenter.by_route).to include({
        title: I18n.t('publications.itt_monthly_report_generator.route_into_teaching.title'),
        data: Hash,
      })
    end
  end

  describe '#by_primary_subject' do
    it 'returns by_primary_subject' do
      expect(presenter.by_primary_subject).to include({
        title: I18n.t('publications.itt_monthly_report_generator.primary_subject.title'),
        data: Hash,
      })
    end
  end

  describe '#by_secondary_subject' do
    it 'returns by_secondary_subject' do
      expect(presenter.by_secondary_subject).to include({
        title: I18n.t('publications.itt_monthly_report_generator.secondary_subject.title'),
        data: Hash,
      })
    end
  end

  describe '#by_provider_region' do
    it 'returns by_provider_region' do
      expect(presenter.by_provider_region).to include({
        title: I18n.t('publications.itt_monthly_report_generator.provider_region.title'),
        data: Hash,
      })
    end
  end
end
