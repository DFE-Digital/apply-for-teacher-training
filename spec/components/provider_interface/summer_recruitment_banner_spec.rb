require 'rails_helper'

RSpec.describe ProviderInterface::SummerRecruitmentBanner do
  before { FeatureFlag.activate('summer_recruitment_banner') }

  subject(:result) { render_inline(described_class.new) }

  context 'when the provider information banner feature flag is on' do
    it 'renders the banner title' do
      expect(result.text).to include('Important')
    end

    it 'renders the banner header' do
      expect(result.text).to include(t('summer_recruitment_banner.header'))
    end

    describe 'rendering the banner content' do
      around do |example|
        Timecop.freeze(time) { example.run }
      end

      context 'when the current time is before the apply 2 deadline' do
        let(:time) { CycleTimetable.apply_2_deadline(RecruitmentCycle.current_year) - 1.day }

        it 'renders the banner content' do
          expect(result.text).to include(t('summer_recruitment_banner.body'))
          expect(page).to have_selector('.govuk-body')
        end
      end

      context 'when the current time is after the apply 2 deadline' do
        let(:time) { CycleTimetable.apply_2_deadline(RecruitmentCycle.current_year) + 1.day }

        it 'does not render the banner content' do
          expect(result.text).not_to include(t('summer_recruitment_banner.body'))
          expect(page).not_to have_css('.govuk-body')
        end
      end
    end
  end

  context 'when the provider information banner feature flag is off' do
    it 'does not render the banner' do
      FeatureFlag.deactivate('summer_recruitment_banner')

      expect(result.text).to be_empty
    end
  end
end
