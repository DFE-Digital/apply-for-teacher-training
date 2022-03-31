require 'rails_helper'

RSpec.describe ProviderInterface::KeyDatesBanner do
  subject(:result) { render_inline(described_class.new) }

  context 'when Christmas period' do
    let(:christmas_period) { "#{CycleTimetable.holidays[:christmas].first.to_fs(:day_and_month)} to #{CycleTimetable.holidays[:christmas].last.to_fs(:govuk_date)}" }

    describe 'rendering the banner content' do
      around do |example|
        Timecop.freeze(time) { example.run }
      end

      context 'up to 20 days after the cycle opens' do
        let(:time) { 10.business_days.after(CycleTimetable.apply_opens).end_of_day }

        it 'does not render the non working period content' do
          expect(result.text).not_to include(t('key_dates_banner.christmas.header'))
          expect(result.text).not_to include(t('key_dates_banner.christmas.body', non_working_days_period: christmas_period))
        end
      end

      context '20 days, or more, after the cycle opens' do
        let(:time) { 20.business_days.after(CycleTimetable.apply_opens).end_of_day }

        it 'renders the banner title' do
          expect(result.text).to include('Important')
        end

        it 'renders the non working period content' do
          expect(result.text).to include(t('key_dates_banner.christmas.header'))
          expect(result.text).to include(t('key_dates_banner.christmas.body', non_working_days_period: christmas_period))
        end
      end

      context 'after the end of the christmas period' do
        let(:time) { 1.business_days.after(CycleTimetable.holidays[:christmas].last).end_of_day }

        it 'does not render the non working period content' do
          expect(result.text).not_to include(t('key_dates_banner.christmas.header'))
          expect(result.text).not_to include(t('key_dates_banner.christmas.body', non_working_days_period: christmas_period))
        end
      end
    end
  end

  context 'when Easter period' do
    let(:easter_period) { "#{CycleTimetable.holidays[:easter].first.to_fs(:day_and_month)} to #{CycleTimetable.holidays[:easter].last.to_fs(:govuk_date)}" }

    describe 'rendering the banner content' do
      around do |example|
        Timecop.freeze(time) { example.run }
      end

      context '11 days before easter period' do
        let(:time) { 11.business_days.before(CycleTimetable.holidays[:easter].first).end_of_day }

        it 'does not render the non working period content' do
          expect(result.text).not_to include(t('key_dates_banner.easter.header', non_working_days_period: easter_period))
          expect(result.text).not_to include(t('key_dates_banner.easter.body'))
        end
      end

      context 'within easter period' do
        let(:time) { CycleTimetable.holidays[:easter].first + 1.hour }

        it 'renders the banner title' do
          expect(result.text).to include('Important')
        end

        it 'renders the non working period content' do
          expect(result.text).to include(t('key_dates_banner.easter.header', non_working_days_period: easter_period))
          expect(result.text).to include(t('key_dates_banner.easter.body'))
        end
      end

      context 'after the end of the Easter period' do
        let(:time) { 1.business_days.after(CycleTimetable.holidays[:easter].last).end_of_day }

        it 'does not render the non working period content' do
          expect(result.text).not_to include(t('key_dates_banner.easter.header', non_working_days_period: easter_period))
          expect(result.text).not_to include(t('key_dates_banner.easter.body'))
        end
      end
    end
  end
end
