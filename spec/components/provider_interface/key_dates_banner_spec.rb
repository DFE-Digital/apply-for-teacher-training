require 'rails_helper'

RSpec.describe ProviderInterface::KeyDatesBanner do
  subject(:result) { render_inline(described_class.new) }

  let(:christmas_period) { "#{CycleTimetable.holidays[:christmas].first.to_s(:govuk_date)} to #{CycleTimetable.holidays[:christmas].last.to_s(:govuk_date)}" }

  it 'renders the banner title' do
    expect(result.text).to include('Important')
  end

  describe 'rendering the banner content' do
    around do |example|
      Timecop.freeze(time) { example.run }
    end

    context 'up to 20 days after the cycle opens' do
      let(:time) { 10.business_days.after(CycleTimetable.apply_opens).end_of_day }

      it 'does renders the non working period content' do
        expect(result.text).not_to include(t('key_dates_banner.christmas_header'))
        expect(result.text).not_to include(t('key_dates_banner.christmas_body', non_working_days_period: christmas_period))
      end
    end

    context '20 days, or more, after the cycle opens' do
      let(:time) { 20.business_days.after(CycleTimetable.apply_opens).end_of_day }

      it 'renders the non working period content' do
        expect(result.text).to include(t('key_dates_banner.christmas_header'))
        expect(result.text).to include(t('key_dates_banner.christmas_body', non_working_days_period: christmas_period))
      end
    end

    context 'after the end of the christmas period' do
      let(:time) { 1.business_days.after(CycleTimetable.holidays[:christmas].last).end_of_day }

      it 'does renders the non working period content' do
        expect(result.text).not_to include(t('key_dates_banner.christmas_header'))
        expect(result.text).not_to include(t('key_dates_banner.christmas_body', non_working_days_period: christmas_period))
      end
    end
  end
end
