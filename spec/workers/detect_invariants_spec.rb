require 'rails_helper'

RSpec.describe DetectInvariants do
  before { allow(Raven).to receive(:capture_exception) }

  describe '#perform' do
    it 'detects application choices in deprecated states' do
      application_choice_bad = create(:application_choice)
      application_choice_bad.update_columns(status: 'application_complete')
      application_choice_bad_too = create(:application_choice)
      application_choice_bad_too.update_columns(status: 'awaiting_references')

      DetectInvariants.new.perform

      expect(Raven).to have_received(:capture_exception).with(
        DetectInvariants::ApplicationInRemovedState.new(
          <<~MSG,
            One or more application choices are still in `awaiting_references` or
            `application_complete` state, but all these states have been removed:

            http://localhost:3000/support/application_choices/#{application_choice_bad.id}
            http://localhost:3000/support/application_choices/#{application_choice_bad_too.id}
          MSG
        ),
      )
    end

    it 'detects outstanding references on submitted applications' do
      weird_application_form = create(:completed_application_form)
      create(:submitted_application_choice, application_form: weird_application_form)
      create(:reference, :feedback_requested, application_form: weird_application_form)
      create(:reference, :feedback_provided, application_form: weird_application_form)

      # Two further applications with no reference weirdness
      ok_form_one = create(:completed_application_form)
      create(:submitted_application_choice, application_form: ok_form_one)
      create(:reference, :feedback_provided, application_form: ok_form_one)
      ok_form_two = create(:application_form)
      create(:reference, :feedback_requested, application_form: ok_form_two)

      DetectInvariants.new.perform

      expect(Raven).to have_received(:capture_exception).with(
        DetectInvariants::OutstandingReferencesOnSubmittedApplication.new(
          <<~MSG,
            One or more references are still pending on these applications,
            even though they've already been submitted:

            http://localhost:3000/support/applications/#{weird_application_form.id}
          MSG
        ),
      )
    end

    it 'detects unauthorised edits on data associated with an application form', with_audited: true do
      honest_bob = create(:candidate)
      nefarious_jim = create(:candidate)
      suspect_form = build(:application_form, candidate: honest_bob)
      ok_form = build(:application_form, candidate: nefarious_jim)

      Audited.audit_class.as_user(honest_bob) do
        suspect_form.save!
        create(:gcse_qualification, application_form: suspect_form, grade: 'A')
        suspect_form.application_qualifications.first.update(grade: 'A*')
      end
      Audited.audit_class.as_user(nefarious_jim) do
        ok_form.save!
        create(:gcse_qualification, application_form: ok_form, grade: 'B')
        ok_form.application_qualifications.first.update(grade: 'C')
        suspect_form.application_qualifications.first.update(grade: 'F')
      end

      DetectInvariants.new.perform

      expect(Raven).to have_received(:capture_exception).with(
        DetectInvariants::ApplicationEditedByWrongCandidate.new(
          <<~MSG,
            The following application forms have had unauthorised edits:

            http://localhost:3000/support/applications/#{suspect_form.id}
          MSG
        ),
      )
    end
  end
end
