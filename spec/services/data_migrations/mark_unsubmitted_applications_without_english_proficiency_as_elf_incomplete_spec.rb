require 'rails_helper'

RSpec.describe DataMigrations::MarkUnsubmittedApplicationsWithoutEnglishProficiencyAsElfIncomplete do
  context 'when efl_complete is marked as true and english proficiency record exists' do
    it 'does not change record' do
      application_form = create(
        :application_form,
        :unsubmitted,
        efl_completed: true,
        efl_completed_at: Time.zone.now,
        english_proficiency: create(:english_proficiency, :with_toefl_qualification),
      )
      described_class.new.change
      expect(application_form.reload.efl_completed).to be(true)
      expect(application_form.reload.efl_completed_at).not_to be_nil
    end
  end

  context 'when english proficiency record does not exists' do
    let(:previous_year) { RecruitmentCycleTimetable.previous_year }

    describe 'application is in an earlier cycle' do
      it 'does not change record' do
        application_form = create(
          :application_form,
          :unsubmitted,
          recruitment_cycle_year: previous_year,
          efl_completed: true,
          efl_completed_at: Time.zone.now,
        )

        described_class.new.change
        expect(application_form.reload.efl_completed).to be(true)
        expect(application_form.reload.efl_completed_at).not_to be_nil
      end
    end

    describe 'application has been submitted' do
      it 'does not change record' do
        application_form = create(
          :application_form,
          :submitted,
          efl_completed: true,
          efl_completed_at: Time.zone.now,
          previous_application_form: create(:application_form, recruitment_cycle_year: previous_year),
        )

        described_class.new.change
        expect(application_form.reload.efl_completed).to be(true)
        expect(application_form.reload.efl_completed_at).not_to be_nil
      end
    end

    describe 'from this year and unsubmitted' do
      it 'updates efl_completed information' do
        application_form = create(
          :application_form,
          :unsubmitted,
          efl_completed: true,
          efl_completed_at: Time.zone.now,
          previous_application_form: create(:application_form, recruitment_cycle_year: previous_year),
        )

        described_class.new.change
        expect(application_form.reload.efl_completed).to be(false)
        expect(application_form.reload.efl_completed_at).to be_nil
      end
    end
  end
end
