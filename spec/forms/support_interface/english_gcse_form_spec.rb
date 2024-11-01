require 'rails_helper'

RSpec.describe SupportInterface::EnglishGcseForm do
  let(:qualification) { create(:application_qualification) }

  subject(:form) { described_class.build_from_qualification(qualification) }

  describe 'validations' do
    it { is_expected.to validate_length_of(:grade).is_at_most(256) }

    it 'validates with SafeChoiceUpdateValidator' do
      expect(form.class.validators.map(&:class)).to include(SafeChoiceUpdateValidator)
    end
  end
end
