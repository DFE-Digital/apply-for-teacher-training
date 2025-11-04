require 'rails_helper'

module ProviderInterface
  RSpec.describe DiversityDataByProvider do
    let(:provider) { create(:provider) }
    let(:diversity_data_by_provider) { described_class.new(provider: [provider.id], recruitment_cycle_year: current_year) }

    describe '#total_submitted_applications' do
      it 'returns the number of application forms that have been submitted' do
        application_choices = [create(:application_choice, :offered, provider_ids: [provider.id]), create(:application_choice, :inactive, provider_ids: [provider.id])]
        create(:application_form, recruitment_cycle_year: current_year, submitted_at: Time.zone.now, application_choices: application_choices)
        create(:application_form, recruitment_cycle_year: current_year, submitted_at: nil, application_choices: [create(:application_choice, :unsubmitted, provider_ids: [provider.id])])
        expect(diversity_data_by_provider.total_submitted_applications).to eq(2)
      end
    end

    describe '#ethnicity_data' do
      it 'returns the ethnicity data for the provider' do
        create(:application_form, submitted_at: Time.zone.now, recruitment_cycle_year: current_year, equality_and_diversity: { 'ethnic_group' => 'Mixed or multiple ethnic groups' }, application_choices: [create(:application_choice, :offered, provider_ids: [provider.id])])
        expect(diversity_data_by_provider.ethnicity_data).to eq([
          {
            header: 'Asian or Asian British',
            values: [0, 0, 0, '-'],
          },
          {
            header: 'Black, African, Black British or Caribbean',
            values: [0, 0, 0, '-'],
          },
          {
            header: 'Mixed or multiple ethnic groups',
            values: [1, 1, 0, '0%'],
          },
          {
            header: 'White',
            values: [0, 0, 0, '-'],
          },
          {
            header: 'Another ethnic group',
            values: [0, 0, 0, '-'],
          },
          {
            header: 'Prefer not to say',
            values: [0, 0, 0, '-'],
          },
        ])
      end
    end

    describe '#age_data' do
      it 'returns the age data for the provider' do
        create(:application_form, submitted_at: Time.zone.now, recruitment_cycle_year: current_year, date_of_birth: Date.new(25.years.ago.year, 1, 1), application_choices: [create(:application_choice, :offered, provider_ids: [provider.id])])
        create(:application_form, submitted_at: Time.zone.now, recruitment_cycle_year: current_year, date_of_birth: Date.new(45.years.ago.year, 1, 1), application_choices: [create(:application_choice, :recruited, provider_ids: [provider.id])])
        create(:application_form, submitted_at: Time.zone.now, recruitment_cycle_year: current_year, date_of_birth: Date.new(45.years.ago.year, 1, 1), application_choices: [create(:application_choice, :recruited, provider_ids: [provider.id])])
        expect(diversity_data_by_provider.age_data).to eq([
          {
            header: '18 to 24',
            values: [0, 0, 0, '-'],
          },
          {
            header: '25 to 34',
            values: [1, 1, 0, '0%'],
          },
          {
            header: '35 to 44',
            values: [0, 0, 0, '-'],
          },
          {
            header: '45 to 54',
            values: [2, 2, 2, '100%'],
          },
          {
            header: '55 to 64',
            values: [0, 0, 0, '-'],
          },
          {
            header: '65 or over',
            values: [0, 0, 0, '-'],
          },
        ])
      end
    end

    describe '#sex_data' do
      it 'returns the sex data for the provider' do
        create(:application_form, submitted_at: Time.zone.now, recruitment_cycle_year: current_year, equality_and_diversity: { 'sex' => 'female' }, application_choices: [create(:application_choice, :offered, provider_ids: [provider.id])])
        create(:application_form, submitted_at: Time.zone.now, recruitment_cycle_year: current_year, equality_and_diversity: { 'sex' => 'female' }, application_choices: [create(:application_choice, :recruited, provider_ids: [provider.id])])
        create(:application_form, submitted_at: Time.zone.now, recruitment_cycle_year: current_year, equality_and_diversity: { 'sex' => 'male' }, application_choices: [create(:application_choice, :awaiting_provider_decision, provider_ids: [provider.id])])
        expect(diversity_data_by_provider.sex_data).to eq([
          {
            header: 'Female',
            values: [2, 2, 1, '50%'],
          },
          {
            header: 'Male',
            values: [1, 0, 0, '0%'],
          },
          {
            header: 'Other',
            values: [0, 0, 0, '-'],
          },
          {
            header: 'Prefer not to say',
            values: [0, 0, 0, '-'],
          },
        ])
      end
    end

    describe '#disability_data' do
      it 'returns the disability data for the provider' do
        create(:application_form, submitted_at: Time.zone.now, recruitment_cycle_year: current_year, equality_and_diversity: { 'disabilities' => ['Long-term illness'] }, application_choices: [create(:application_choice, :interviewing, provider_ids: [provider.id])])
        create(:application_form, submitted_at: Time.zone.now, recruitment_cycle_year: current_year, equality_and_diversity: { 'disabilities' => ['Long-term illness', 'Mental health condition'] }, application_choices: [create(:application_choice, :interviewing, provider_ids: [provider.id])])
        create(:application_form, submitted_at: Time.zone.now, recruitment_cycle_year: current_year, equality_and_diversity: { 'disabilities' => ['Autistic spectrum condition or another condition affecting speech, language, communication or social skills'] }, application_choices: [create(:application_choice, :accepted, provider_ids: [provider.id])])
        create(:application_form, submitted_at: Time.zone.now, recruitment_cycle_year: current_year, equality_and_diversity: { 'disabilities' => ['Autistic spectrum condition or another condition affecting speech, language, communication or social skills'] }, application_choices: [create(:application_choice, :recruited, provider_ids: [provider.id])])
        expect(diversity_data_by_provider.disability_data).to eq([
          {
            header: 'At least 1 disability or health condition declared',
            values: [4, 2, 1, '25%'],
          },
          {
            header: 'Autistic spectrum condition or another condition affecting speech, language, communication or social skills',
            values: [2, 2, 1, '50%'],
          },
          {
            header: 'Blindness or a visual impairment not corrected by glasses',
            values: [0, 0, 0, '-'],
          },
          {
            header: 'Condition affecting motor, cognitive, social and emotional skills, speech or language since childhood',
            values: [0, 0, 0, '-'],
          },
          {
            header: 'Deafness or a serious hearing impairment',
            values: [0, 0, 0, '-'],
          },
          {
            header: 'Dyslexia, dyspraxia or attention deficit hyperactivity disorder (ADHD) or another learning difference',
            values: [0, 0, 0, '-'],
          },
          {
            header: 'Long-term illness',
            values: [2, 0, 0, '0%'],
          },
          {
            header: 'Mental health condition',
            values: [1, 0, 0, '0%'],
          },
          {
            header: 'Physical disability or mobility issue',
            values: [0, 0, 0, '-'],
          },
          {
            header: 'Another disability, health condition or impairment affecting daily life',
            values: [0, 0, 0, '-'],
          },
          {
            header: 'I do not have any of these disabilities or health conditions',
            values: [0, 0, 0, '-'],
          },
          {
            header: 'Prefer not to say',
            values: [0, 0, 0, '-'],
          },
        ])
      end

      it 'returns handles missing equality and disability data' do
        create(
          :application_form,
          submitted_at: Time.zone.now,
          recruitment_cycle_year: current_year,
          equality_and_diversity: nil,
          application_choices: [
            create(:application_choice, :interviewing, provider_ids: [provider.id]),
          ],
        )

        expect(diversity_data_by_provider.disability_data).to eq([
          {
            header: 'At least 1 disability or health condition declared',
            values: [0, 0, 0, '-'],
          },
          {
            header: 'Autistic spectrum condition or another condition affecting speech, language, communication or social skills',
            values: [0, 0, 0, '-'],
          },
          {
            header: 'Blindness or a visual impairment not corrected by glasses',
            values: [0, 0, 0, '-'],
          },
          {
            header: 'Condition affecting motor, cognitive, social and emotional skills, speech or language since childhood',
            values: [0, 0, 0, '-'],
          },
          {
            header: 'Deafness or a serious hearing impairment',
            values: [0, 0, 0, '-'],
          },
          {
            header: 'Dyslexia, dyspraxia or attention deficit hyperactivity disorder (ADHD) or another learning difference',
            values: [0, 0, 0, '-'],
          },
          {
            header: 'Long-term illness',
            values: [0, 0, 0, '-'],
          },
          {
            header: 'Mental health condition',
            values: [0, 0, 0, '-'],
          },
          {
            header: 'Physical disability or mobility issue',
            values: [0, 0, 0, '-'],
          },
          {
            header: 'Another disability, health condition or impairment affecting daily life',
            values: [0, 0, 0, '-'],
          },
          {
            header: 'I do not have any of these disabilities or health conditions',
            values: [0, 0, 0, '-'],
          },
          {
            header: 'Prefer not to say',
            values: [0, 0, 0, '-'],
          },
        ])
      end
    end
  end
end
