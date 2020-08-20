require 'rails_helper'

RSpec.describe CarryOverUnsubmittedApplicationsWorker do
  around do |example|
    Timecop.freeze(Time.zone.local(2020, 10, 15)) do
      example.run
    end
  end

  describe '#perform' do
    it 'duplicates any unsubmitted applications from the last cycle' do
      unsubmitted_application_from_last_year = create(
        :completed_application_form,
        submitted_at: nil,
      )
      create(
        :application_choice,
        status: :unsubmitted,
        application_form: unsubmitted_application_from_last_year,
      )

      unsubmitted_application_from_this_year = create(
        :completed_application_form,
        submitted_at: nil,
      )
      create(
        :application_choice,
        status: :unsubmitted,
        application_form: unsubmitted_application_from_this_year,
        course_option: create(:course_option, course: create(:course, recruitment_cycle_year: 2021)),
      )

      rejected_application_from_last_year = create(
        :completed_application_form,
      )
      create(
        :application_choice,
        status: :rejected,
        application_form: rejected_application_from_last_year,
      )

      described_class.new.perform

      expect(unsubmitted_application_from_last_year.reload.subsequent_application_form).to be_present
      expect(unsubmitted_application_from_this_year.reload.subsequent_application_form).not_to be_present
      expect(rejected_application_from_last_year.reload.subsequent_application_form).not_to be_present

      carried_over_application_form = unsubmitted_application_from_last_year.reload.subsequent_application_form

      expect(carried_over_application_form.application_choices).to be_empty
      expect(carried_over_application_form).to be_apply_1

      expect { described_class.new.perform }.not_to(change { ApplicationForm.count })
    end
  end
end
