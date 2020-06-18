require 'rails_helper'

RSpec.describe SupportInterface::ApplicationCommentForm, type: :model, with_audited: true do
  let(:form_data) do
    {
      comment: Faker::Lorem.paragraph_by_chars(number: 200),
    }
  end

  describe '#save' do
    it 'returns false if not valid' do
      application_form = FactoryBot.create(:application_form)
      expect(described_class.new.save(application_form)).to be false
    end

    it 'updates the provided ApplicationForm audit trail with the new comment if valid' do
      application_form = FactoryBot.create(:application_form)
      expect(described_class.new(form_data).save(application_form)).to be true
      expect(application_form.reload.audits.last.comment).to eq form_data[:comment]
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:comment) }
  end
end
