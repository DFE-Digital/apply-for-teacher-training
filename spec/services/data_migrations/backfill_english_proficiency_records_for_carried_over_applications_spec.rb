require 'rails_helper'

RSpec.describe DataMigrations::BackfillEnglishProficiencyRecordsForCarriedOverApplications do
  let(:data_migration) { described_class.new.change }
  let(:current_year) { RecruitmentCycleTimetable.current_year }
  let(:previous_year) { RecruitmentCycleTimetable.previous_year }

  before do
    # This test ony relevant for 2024. We were backfilling data that was missed when carrying over previous applications
    TestSuiteTimeMachine.travel_permanently_to(mid_cycle(2024))
  end

  context 'when efl_complete is marked as true and english proficiency record exists', time: mid_cycle(2024) do
    it 'does not change the application' do
      create(
        :application_form,
        :unsubmitted,
        efl_completed: true,
        efl_completed_at: Time.zone.now,
        english_proficiency: create(:english_proficiency, :with_toefl_qualification),
        previous_application_form: create(:application_form, recruitment_cycle_year: current_year),
      )
      expect { data_migration }.to not_change(EnglishProficiency, :count)
    end
  end

  context 'when efl_complete is marked as true without proficiency record, but one exists on previous application' do
    describe 'an efl_qualification exists' do
      it 'copies english proficiency and associated efl qualification' do
        previous_application_form = create(:application_form, recruitment_cycle_year: previous_year)
        previous_english_proficiency = create(
          :english_proficiency,
          :with_toefl_qualification,
          application_form: previous_application_form,
        )

        application_form = create(
          :application_form,
          :unsubmitted,
          efl_completed: true,
          efl_completed_at: Time.zone.now,
          previous_application_form:,
        )
        expect { data_migration }.to change(EnglishProficiency, :count).by(1)
        expect(application_form.english_proficiency.efl_qualification.present?).to be(true)
        expect(application_form.english_proficiency.efl_qualification_type).to eq previous_english_proficiency.efl_qualification_type
      end
    end

    describe 'an efl_qualification does NOT exists' do
      it 'copies the english proficiency record without an efl qualifications' do
        previous_application_form = create(:application_form, recruitment_cycle_year: previous_year)
        create(:english_proficiency, :no_qualification, application_form: previous_application_form)

        application_form = create(
          :application_form,
          :unsubmitted,
          efl_completed: true,
          efl_completed_at: Time.zone.now,
          previous_application_form:,
        )
        expect { data_migration }.to change(EnglishProficiency, :count).by(1)
        expect(application_form.english_proficiency.efl_qualification.present?).to be(false)
        expect(application_form.english_proficiency.qualification_status).to eq('no_qualification')
      end
    end
  end

  context 'where previous application does not exists' do
    it 'does not create an english proficiency' do
      create(
        :application_form,
        :unsubmitted,
        efl_completed: true,
        efl_completed_at: Time.zone.now,
      )

      expect { data_migration }.to not_change(EnglishProficiency, :count)
    end
  end

  context 'when efl_complete is marked as true and english proficiency record does not exists on previous application' do
    it 'does not add an english proficiency' do
      create(
        :application_form,
        :unsubmitted,
        efl_completed: true,
        efl_completed_at: Time.zone.now,
        previous_application_form: create(:application_form, recruitment_cycle_year: previous_year),
      )

      expect { data_migration }.to not_change(EnglishProficiency, :count)
    end
  end

  context 'application from earlier cycle' do
    it 'does not add an english proficiency' do
      previous_application_form = create(:application_form, recruitment_cycle_year: previous_year - 1)
      create(:english_proficiency, :no_qualification, application_form: previous_application_form)

      create(
        :application_form,
        :unsubmitted,
        recruitment_cycle_year: previous_year,
        efl_completed: true,
        efl_completed_at: Time.zone.now,
        previous_application_form:,
      )

      expect { data_migration }.to not_change(EnglishProficiency, :count)
    end
  end

  describe 'submitted application' do
    it 'does not create an english proficiency record' do
      previous_application_form = create(:application_form, recruitment_cycle_year: previous_year)
      create(:english_proficiency, :no_qualification, application_form: previous_application_form)

      create(
        :application_form,
        :submitted,
        efl_completed: true,
        efl_completed_at: Time.zone.now,
        previous_application_form:,
      )

      expect { data_migration }.to not_change(EnglishProficiency, :count)
    end
  end
end
