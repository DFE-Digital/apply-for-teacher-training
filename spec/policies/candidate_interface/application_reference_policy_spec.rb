require 'rails_helper'

RSpec.describe CandidateInterface::ApplicationReferencePolicy do
  subject(:policy) { described_class }

  permissions :show_cancel_link? do
    context 'when no references sent' do
      it 'does not show cancel link' do
        expect(policy).not_to permit(nil, build(:reference))
      end
    end

    context 'when references sent' do
      it 'shows cancel link', :with_audited do
        reference = create(:reference)
        reference.update(feedback_status: 'feedback_requested')

        expect(policy).to permit(nil, reference)
      end
    end
  end

  permissions :cancel? do
    context 'when there are no feedback_provided references' do
      it 'does not permit cancelling' do
        application_form = create(:application_form)
        _reference = create(
          :application_reference,
          :not_requested_yet,
          application_form:,
        )

        expect(policy).not_to permit(application_form.candidate, nil)
      end
    end

    context 'when there is only 1 feedback_requested reference' do
      it 'does not permit cancelling' do
        application_form = create(:application_form)
        _reference = create(
          :application_reference,
          :feedback_requested,
          application_form:,
        )

        expect(policy).not_to permit(application_form.candidate, nil)
      end
    end

    context 'when there are feedback_provided references' do
      it 'does not permit cancelling' do
        application_form = create(:application_form)
        _reference = create(
          :application_reference,
          :feedback_provided,
          application_form:,
        )

        expect(policy).to permit(application_form.candidate, nil)
      end
    end

    context 'when there are more than 1 feedback_requested reference' do
      it 'does not permit cancelling' do
        application_form = create(:application_form)
        _reference = create(
          :application_reference,
          :feedback_requested,
          application_form:,
        )
        _second_reference = create(
          :application_reference,
          :feedback_requested,
          application_form:,
        )

        expect(policy).to permit(application_form.candidate, nil)
      end
    end
  end

  describe 'scope' do
    describe '#resolve' do
      it 'resolves the scope' do
        application_form = create(:application_form)
        scoped_reference = create(:reference, application_form:)
        _another_reference = create(:reference)

        scope = described_class::Scope.new(
          application_form.candidate,
          ApplicationReference,
        ).resolve

        expect(scope).to eq([scoped_reference])
      end
    end
  end
end
