require 'rails_helper'

RSpec.describe CandidateInterface::Reference::SubmitRefereeForm, type: :model do
  describe 'validations' do
    describe 'submit' do
      let(:form) { subject }

      before do
        allow(form).to receive(:all_details_provided?).and_return true
      end

      it { is_expected.to validate_presence_of(:submit) }
    end

    describe '.all_details_provided?' do
      let(:reference) { create(:reference) }
      let(:type_double) { instance_double(CandidateInterface::References::TypeStep) }
      let(:name_double) { instance_double(CandidateInterface::References::NameStep) }
      let(:email_address_double) { instance_double(CandidateInterface::References::EmailAddressStep) }
      let(:relationship_double) { instance_double(CandidateInterface::References::RelationshipStep) }
      let(:reference_wizard) { instance_double(CandidateInterface::ReferenceWizard, current_step: email_address_double) }

      before do
        allow(CandidateInterface::References::TypeStep).to receive(:new).with(referee_type: reference.referee_type).and_return(type_double)
        allow(CandidateInterface::References::NameStep).to receive(:new).with(name: reference.name, referee_type: reference.referee_type).and_return(name_double)
        allow(CandidateInterface::ReferenceWizard).to receive(:new).and_return(reference_wizard)
        allow(CandidateInterface::References::RelationshipStep).to receive(:new).with(relationship: reference.relationship).and_return(relationship_double)

        allow(type_double).to receive(:valid?).and_return true
        allow(name_double).to receive(:valid?).and_return true
        allow(relationship_double).to receive(:valid?).and_return true
        allow(email_address_double).to receive(:valid?).and_return true
      end

      it 'builds the referee attribute forms and checks they are valid' do
        described_class.new(submit: 'yes', reference_id: reference.id).valid?

        expect(CandidateInterface::References::TypeStep).to have_received(:new).with(referee_type: reference.referee_type)
        expect(CandidateInterface::References::NameStep).to have_received(:new).with(name: reference.name, referee_type: reference.referee_type)
        expect(CandidateInterface::References::RelationshipStep).to have_received(:new).with(relationship: reference.relationship)
        expect(type_double).to have_received(:valid?)
        expect(name_double).to have_received(:valid?)
        expect(relationship_double).to have_received(:valid?)
        expect(email_address_double).to have_received(:valid?)
      end
    end
  end
end
