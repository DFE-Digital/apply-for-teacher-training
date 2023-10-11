require 'rails_helper'

RSpec.describe ReferencesPathHelper do
  let(:application_choice) { build_stubbed(:application_choice) }
  let(:reference) { build_stubbed(:reference) }

  describe '#references_type_path' do
    it 'is candidate_interface_references_type_path' do
      expect(helper.references_type_path(referee_type: 'academic', reference_id: 123)).to eq(
        candidate_interface_references_type_path('academic', 123),
      )
    end

    context 'when the step is accept_offer' do
      let(:step) { :accept_offer }

      it 'is candidate_interface_accept_offer_references_type_path' do
        expect(helper.references_type_path(referee_type: 'academic', reference_id: 123, application_choice: application_choice, step: step)).to eq(
          candidate_interface_accept_offer_references_type_path(application_choice, 'academic', 123),
        )
      end
    end

    context 'when the step is request_reference' do
      let(:step) { :request_reference }

      it 'is candidate_interface_request_reference_references_type_path' do
        expect(helper.references_type_path(referee_type: 'academic', reference_id: 123, step: step)).to eq(
          candidate_interface_request_reference_references_type_path('academic', 123),
        )
      end
    end
  end

  describe '#reference_edit_type_path' do
    it 'is candidate_interface_references_edit_type_path' do
      expect(helper.reference_edit_type_path(reference: reference, return_to: { return_to: '/foo' })).to eq(
        candidate_interface_references_edit_type_path(reference.id, return_to: '/foo'),
      )
    end

    context 'when the step is accept_offer' do
      let(:step) { :accept_offer }

      it 'is candidate_interface_accept_offer_references_edit_type_path' do
        expect(
          helper.reference_edit_type_path(
            application_choice: application_choice,
            reference: reference,
            return_to: { return_to: '/foo' },
            step: step,
          ),
        ).to eq(
          candidate_interface_accept_offer_references_edit_type_path(
            application_choice, reference.id, return_to: '/foo'
          ),
        )
      end
    end

    context 'when the step is request_reference' do
      let(:step) { :request_reference }

      it 'is candidate_interface_request_reference_references_edit_type_path' do
        expect(helper.reference_edit_type_path(reference: reference, return_to: { return_to: '/foo' }, step: step)).to eq(
          candidate_interface_request_reference_references_edit_type_path(reference.id, return_to: '/foo'),
        )
      end
    end
  end

  describe '#references_name_path' do
    it 'is candidate_interface_references_name_path' do
      expect(helper.references_name_path(referee_type: 'academic', reference_id: 123)).to eq(
        candidate_interface_references_name_path('academic', 123),
      )
    end

    context 'when the step is accept_offer' do
      let(:step) { :accept_offer }

      it 'is candidate_interface_accept_offer_references_name_path' do
        expect(helper.references_name_path(application_choice: application_choice, referee_type: 'academic', reference_id: 123, step: step)).to eq(
          candidate_interface_accept_offer_references_name_path(application_choice, 'academic', 123),
        )
      end
    end

    context 'when the step is request_reference' do
      let(:step) { :request_reference }

      it 'is candidate_interface_accept_offer_references_name_path' do
        expect(helper.references_name_path(referee_type: 'academic', reference_id: 123, step: step)).to eq(
          candidate_interface_request_reference_references_name_path('academic', 123),
        )
      end
    end
  end

  describe '#reference_edit_name_path' do
    it 'is candidate_interface_references_name_path' do
      expect(helper.reference_edit_name_path(reference: reference, return_to: { return_to: '/foo' })).to eq(
        candidate_interface_references_edit_name_path(reference.id, return_to: '/foo'),
      )
    end

    context 'when the step is accept_offer' do
      let(:step) { :accept_offer }

      it 'is candidate_interface_accept_offer_references_name_path' do
        expect(
          helper.reference_edit_name_path(
            application_choice: application_choice,
            reference: reference,
            return_to: { return_to: '/foo' },
            step: step,
          ),
        ).to eq(
          candidate_interface_accept_offer_references_edit_name_path(application_choice, reference.id, return_to: '/foo'),
        )
      end
    end

    context 'when the step is request_reference' do
      let(:step) { :request_reference }

      it 'is candidate_interface_request_reference_references_name_path' do
        expect(helper.reference_edit_name_path(reference: reference, return_to: { return_to: '/foo' }, step: step)).to eq(
          candidate_interface_request_reference_references_edit_name_path(reference.id, return_to: '/foo'),
        )
      end
    end
  end

  describe '#references_email_address_path' do
    it 'is candidate_interface_references_name_path' do
      expect(helper.references_email_address_path(reference: reference)).to eq(
        candidate_interface_references_email_address_path(reference.id),
      )
    end

    context 'when the step is accept_offer' do
      let(:step) { :accept_offer }

      it 'is candidate_interface_accept_offer_references_email_address_path' do
        expect(helper.references_email_address_path(application_choice: application_choice, reference: reference, step: step)).to eq(
          candidate_interface_accept_offer_references_email_address_path(application_choice, reference.id),
        )
      end
    end

    context 'when the step is request_reference' do
      let(:step) { :request_reference }

      it 'is candidate_interface_accept_offer_references_email_address_path' do
        expect(helper.references_email_address_path(reference: reference, step: step)).to eq(
          candidate_interface_request_reference_references_email_address_path(reference.id),
        )
      end
    end
  end

  describe '#reference_edit_email_address_path' do
    it 'is candidate_interface_references_email_address_path' do
      expect(helper.reference_edit_email_address_path(reference: reference, return_to: { return_to: '/foo' })).to eq(
        candidate_interface_references_edit_email_address_path(reference.id, return_to: '/foo'),
      )
    end

    context 'when the step is accept_offer' do
      let(:step) { :accept_offer }

      it 'is candidate_interface_accept_offer_references_email_address_path' do
        expect(
          helper.reference_edit_email_address_path(
            application_choice: application_choice,
            reference: reference,
            return_to: { return_to: '/foo' },
            step: step,
          ),
        ).to eq(
          candidate_interface_accept_offer_references_edit_email_address_path(application_choice, reference.id, return_to: '/foo'),
        )
      end
    end

    context 'when the step is request_reference' do
      let(:step) { :request_reference }

      it 'is candidate_interface_request_reference_references_name_path' do
        expect(helper.reference_edit_email_address_path(reference: reference, return_to: { return_to: '/foo' }, step: step)).to eq(
          candidate_interface_request_reference_references_edit_email_address_path(reference.id, return_to: '/foo'),
        )
      end
    end
  end

  describe '#references_relationship_path' do
    it 'is candidate_interface_references_relationship_path' do
      expect(helper.references_relationship_path(reference: reference)).to eq(
        candidate_interface_references_relationship_path(reference.id),
      )
    end

    context 'when the step is accept_offer' do
      let(:step) { :accept_offer }

      it 'is candidate_interface_accept_offer_references_relationship_path' do
        expect(helper.references_relationship_path(application_choice: application_choice, reference: reference, step: step)).to eq(
          candidate_interface_accept_offer_references_relationship_path(application_choice, reference.id),
        )
      end
    end

    context 'when the step is request_reference' do
      let(:step) { :request_reference }

      it 'is candidate_interface_accept_offer_references_relationship_path' do
        expect(helper.references_relationship_path(reference: reference, step: step)).to eq(
          candidate_interface_request_reference_references_relationship_path(reference.id),
        )
      end
    end
  end

  describe '#reference_edit_relationship_path' do
    it 'is candidate_interface_references_relationship_path' do
      expect(helper.reference_edit_relationship_path(reference: reference, return_to: { return_to: '/foo' })).to eq(
        candidate_interface_references_edit_relationship_path(reference.id, return_to: '/foo'),
      )
    end

    context 'when the step is accept_offer' do
      let(:step) { :accept_offer }

      it 'is candidate_interface_accept_offer_references_name_path' do
        expect(
          helper.reference_edit_relationship_path(
            application_choice: application_choice,
            reference: reference,
            return_to: { return_to: '/foo' },
            step: step,
          ),
        ).to eq(
          candidate_interface_accept_offer_references_edit_relationship_path(application_choice, reference.id, return_to: '/foo'),
        )
      end
    end

    context 'when the step is request_reference' do
      let(:step) { :request_reference }

      it 'is candidate_interface_request_reference_references_name_path' do
        expect(helper.reference_edit_relationship_path(reference: reference, return_to: { return_to: '/foo' }, step: step)).to eq(
          candidate_interface_request_reference_references_edit_relationship_path(reference.id, return_to: '/foo'),
        )
      end
    end
  end

  describe 'type_previous_path' do
    context 'when the workflow step is accept_offer' do
      it 'is candidate_interface_accept_offer_path' do
        expect(helper.type_previous_path(application_choice: application_choice, step: :accept_offer)).to eq(
          candidate_interface_accept_offer_path(application_choice),
        )
      end
    end

    context 'when the workflow step is request_reference' do
      it 'is candidate_interface_request_reference_references_start_path' do
        expect(helper.type_previous_path(step: :request_reference)).to eq(
          candidate_interface_request_reference_references_start_path,
        )
      end
    end

    context 'without a workflow step' do
      it 'is candidate_interface_references_start_path' do
        expect(helper.type_previous_path).to eq(candidate_interface_references_start_path)
      end
    end
  end

  describe 'reference_workflow_step' do
    it 'is nil when the path does not match a specific case' do
      expect(helper.reference_workflow_step).to be_nil
    end

    context 'when request.path contains /references/accept-offer' do
      it 'is :accept_offer' do
        allow(request).to receive(:path).and_return('/application/1234/references/accept-offer/type/edit/321')
        expect(helper.reference_workflow_step).to eq(:accept_offer)
      end
    end

    context 'when request.path contains /references/request-references' do
      it 'is :accept_offer' do
        allow(request).to receive(:path).and_return('/application/1234/references/request-references/type/321')
        expect(helper.reference_workflow_step).to eq(:request_reference)
      end
    end

    context 'when request.path contains /offer/accept' do
      it 'is :accept_offer' do
        allow(request).to receive(:path).and_return('/application/choice/2345/offer/accept')
        expect(helper.reference_workflow_step).to eq(:accept_offer)
      end
    end
  end
end
