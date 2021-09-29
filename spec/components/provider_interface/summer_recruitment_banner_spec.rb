require 'rails_helper'

RSpec.describe ProviderInterface::SummerRecruitmentBanner do
  before { FeatureFlag.activate('summer_recruitment_banner') }

  subject(:result) { render_inline(described_class.new) }

  context 'when the provider information banner feature flag is on' do
    it 'renders the banner title' do
      expect(result.text).to include('Important')
    end

    describe 'rendering the banner header' do
      around do |example|
        Timecop.freeze(time) { example.run }
      end

      context 'before the global reject by default date passes' do
        let(:time) { CycleTimetable.reject_by_default(2021) - 1.hour }

        it 'renders the before global rbd content' do
          expect(result.text).to include(t('summer_recruitment_banner.before_global_rbd.header'))
        end
      end

      context 'after the global reject by default date passes' do
        let(:time) { CycleTimetable.reject_by_default(2021) + 1.hour }

        it 'renders the after global rbd content' do
          expect(result.text).to include(t('summer_recruitment_banner.after_global_rbd.header'))
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
