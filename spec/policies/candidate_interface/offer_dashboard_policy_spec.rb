require 'rails_helper'

RSpec.describe CandidateInterface::OfferDashboardPolicy do
  subject(:policy) { described_class }

  permissions :show? do
    context 'when there is no accepted offer' do
      it 'denies access' do
        application_form = create(:application_form)
        expect(policy).not_to permit(application_form.candidate, nil)
      end
    end

    context 'when application is not recruited' do
      it 'denies access' do
        application_form = create(
          :application_form,
          :completed,
          submitted_application_choices_count: 1,
        )
        expect(policy).not_to permit(application_form.candidate, nil)
      end
    end

    context 'when there is accepted offer' do
      it 'grants access' do
        application_form = create(:application_form, :with_accepted_offer)

        expect(policy).to permit(application_form.candidate, nil)
      end
    end

    context 'when the application form is recruited' do
      it 'grants access' do
        application_form = create(:application_form, :completed)
        _choice = create(:application_choice, :recruited, application_form:)

        expect(policy).to permit(application_form.candidate, nil)
      end
    end

    context 'when the application choice is deffered' do
      it 'grants access' do
        application_form = create(:application_form, :completed)
        _choice = create(:application_choice, :offer_deferred, application_form:)

        expect(policy).to permit(application_form.candidate, nil)
      end
    end
  end

  describe 'scope' do
    describe '#resolve' do
      it 'resolves the scope' do
        application_form = create(:application_form)
        first_reference = create(:reference, application_form:)
        second_reference = create(:reference, application_form:, created_at: 1.day.ago)
        _another_reference = create(:reference)

        scope = described_class::Scope.new(
          application_form.candidate,
          ApplicationReference,
        ).resolve

        expect(scope).to eq([first_reference, second_reference])
      end
    end
  end
end
