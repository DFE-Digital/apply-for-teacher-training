require 'rails_helper'

RSpec.describe ProviderInterface::SummerRecruitmentBanner do
  subject(:result) { render_inline(described_class.new) }

  around do |example|
    travel_temporarily_to(time) { example.run }
  end

  context 'when before banner opening date' do
    let(:time) { Time.zone.local(2022, 6, 30) }

    it 'does not render' do
      expect(result.text).to be_empty
    end
  end

  context 'when apply one closes' do
    let(:time) { Time.zone.local(2022, 9, 6, 18, 0, 1) }

    it 'does not render' do
      expect(result.text).to be_empty
    end
  end

  describe 'rendering the banner header' do
    context 'when starts to show the banner' do
      let(:time) { Time.zone.local(2022, 7, 1) }

      it 'renders the before global rbd content' do
        expect(result.text).to include('Important')
        expect(result.text).to include(t('summer_recruitment_banner.header'))
        expect(result.text).to include(t('summer_recruitment_banner.body', end_date: '28 September'))
      end
    end

    context 'before apply 1 closes' do
      let(:time) { CycleTimetable.apply_1_deadline(2023) - 1.second }

      it 'renders banner' do
        expect(result.text).to include('Important')
        expect(result.text).to include(t('summer_recruitment_banner.header'))
        expect(result.text).to include(t('summer_recruitment_banner.body', end_date: '27 September'))
      end
    end
  end
end
