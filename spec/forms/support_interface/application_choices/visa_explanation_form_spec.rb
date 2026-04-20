require 'rails_helper'

module SupportInterface
  RSpec.describe ApplicationChoices::VisaExplanationForm, type: :model do
    subject(:form) do
      described_class.new(application_choice)
    end
    let(:application_choice) { create(:application_choice) }

    describe 'validations' do
      it { is_expected.to validate_presence_of(:visa_explanation) }
      it { is_expected.to validate_presence_of(:audit_comment) }

      context "when visa_explanation is 'other'" do
        before do
          form.visa_explanation = 'other'
        end

        it { is_expected.to validate_presence_of(:visa_explanation_details) }
      end
    end

    describe '#save' do
      it 'saves visa_expred_at on application_choice', :with_audited do
        form.visa_explanation = 'other'
        form.visa_explanation_details = 'details'
        form.audit_comment = 'comment'

        expect { form.save }.to change(application_choice, :visa_explanation).from(nil).to('other')
          .and change(application_choice, :visa_explanation_details).from(nil).to('details')
        expect(application_choice.audits.last.comment).to eq('comment')
      end

      context 'with invalid form' do
        let(:application_choice) { build(:application_choice) }

        it 'returns nil' do
          form.visa_explanation = nil

          expect(form.save).to be_nil
        end
      end
    end
  end
end
