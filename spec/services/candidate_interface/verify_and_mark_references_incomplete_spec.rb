require 'rails_helper'

module CandidateInterface
  RSpec.describe VerifyAndMarkReferencesIncomplete do
    context 'when application is mark as completed' do
      context 'when application has 1 reference' do
        it 'change applications references section as incomplete' do
          application_form = create(:application_form, references_completed: true)
          create(:reference, application_form:)
          described_class.new(application_form).call

          expect(application_form.reload.references_completed?).to be false
        end
      end

      context 'when application has 2 references' do
        it 'keep applications references section as completed' do
          application_form = create(:application_form, references_completed: true)
          create(:reference, application_form:)
          create(:reference, application_form:)
          described_class.new(application_form).call

          expect(application_form.reload.references_completed?).to be true
        end
      end
    end

    context 'when application is not mark as completed' do
      context 'when application has zero reference' do
        it 'returns nil' do
          application_form = create(:application_form, references_completed: false)
          described_class.new(application_form).call

          expect(application_form.reload.references_completed?).to be false
        end
      end
    end
  end
end
