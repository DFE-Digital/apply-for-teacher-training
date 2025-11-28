require 'rails_helper'

RSpec.describe Subject do
  describe 'validations' do
    it { is_expected.to validate_uniqueness_of(:code) }
  end

  describe 'scopes' do
    describe '#languages' do
      let!(:german) { create(:subject, name: 'German', code: '17') }
      let!(:modern_languages) { create(:subject, name: 'Modern languages (other)', code: '24') }
      let!(:spanish) { create(:subject, name: 'Spanish', code: '22') }
      let!(:russian) { create(:subject, name: 'Russian', code: '21') }
      let!(:mandarin) { create(:subject, name: 'Mandarin', code: '20') }
      let!(:latin) { create(:subject, name: 'Latin', code: 'A0') }
      let!(:japanese) { create(:subject, name: 'Japanese', code: '19') }
      let!(:italian) { create(:subject, name: 'Italian', code: '18') }
      let!(:french) { create(:subject, name: 'French', code: '15') }
      let!(:hebrew) { create(:subject, name: 'Ancient Hebrew', code: 'A2') }
      let!(:greek) { create(:subject, name: 'Ancient Greek', code: 'A1') }
      let!(:english) { create(:subject, name: 'English', code: 'Q3') }
      let(:language_subjects) do
        [
          german,
          modern_languages,
          spanish,
          russian,
          mandarin,
          latin,
          japanese,
          italian,
          french,
          hebrew,
          greek,
          english,
        ]
      end

      let(:maths) { create(:subject, name: 'Mathematics', code: 'M1') }

      before { maths }

      it 'returns only language subjects' do
        expect(described_class.languages).to match_array(language_subjects)
      end
    end

    describe '#physics' do
      let!(:physics) { create(:subject, name: 'Physics', code: 'F3') }
      let(:maths) { create(:subject, name: 'Mathematics', code: 'M1') }

      before { maths }

      it 'returns only language subjects' do
        expect(described_class.physics).to contain_exactly(physics)
      end
    end
  end
end
