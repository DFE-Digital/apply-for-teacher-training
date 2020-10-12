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
      let(:type_double) { instance_double(CandidateInterface::Reference::RefereeTypeForm) }
      let(:name_double) { instance_double(CandidateInterface::Reference::RefereeNameForm) }
      let(:relationship_double) { instance_double(CandidateInterface::Reference::RefereeRelationshipForm) }
      let(:email_address_double) { instance_double(CandidateInterface::Reference::RefereeEmailAddressForm) }

      before do
        allow(CandidateInterface::Reference::RefereeTypeForm).to receive(:build_from_reference).with(reference).and_return(type_double)
        allow(CandidateInterface::Reference::RefereeNameForm).to receive(:build_from_reference).with(reference).and_return(name_double)
        allow(CandidateInterface::Reference::RefereeRelationshipForm).to receive(:build_from_reference).with(reference).and_return(relationship_double)
        allow(CandidateInterface::Reference::RefereeEmailAddressForm).to receive(:build_from_reference).with(reference).and_return(email_address_double)
        allow(type_double).to receive(:valid?).and_return true
        allow(name_double).to receive(:valid?).and_return true
        allow(relationship_double).to receive(:valid?).and_return true
        allow(email_address_double).to receive(:valid?).and_return true
      end

      it 'builds the referee attribute forms and checks they are valid' do
        described_class.new(submit: 'yes', reference_id: reference.id).valid?

        expect(CandidateInterface::Reference::RefereeTypeForm).to have_received(:build_from_reference).with(reference)
        expect(CandidateInterface::Reference::RefereeNameForm).to have_received(:build_from_reference).with(reference)
        expect(CandidateInterface::Reference::RefereeRelationshipForm).to have_received(:build_from_reference).with(reference)
        expect(CandidateInterface::Reference::RefereeEmailAddressForm).to have_received(:build_from_reference).with(reference)
        expect(type_double).to have_received(:valid?)
        expect(name_double).to have_received(:valid?)
        expect(relationship_double).to have_received(:valid?)
        expect(email_address_double).to have_received(:valid?)
      end
    end
  end
end
