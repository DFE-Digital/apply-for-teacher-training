require 'rails_helper'

RSpec.describe 'Course factory' do
  subject(:record) { |attrs: {}| create(factory, *traits, **attributes, **attrs) }

  let(:traits) { [] }
  let(:attributes) { {} }

  factory :course do
    it 'creates one course' do
      expect { record }.to change { Course.count }.by(1)
    end

    it 'creates one provider' do
      expect { record }.to change { Provider.count }.by(1)
    end

    it 'creates one course subject' do
      expect { record }.to change { CourseSubject.count }.by(1)
    end

    field :age_range, type: String
    field :applications_open_from, value: current_timetable.find_opens_at
    field :code, type: String
    field :course_length, value: 'OneYear'
    field :description, type: String
    field :funding_type, one_of: %w[fee salary apprenticeship]
    field :level, value: 'primary'
    field :name, type: String
    field :program_type, value: 'scitt_programme'
    field :qualifications, value: %w[qts pgce]
    field :start_date, presence: true
    field :withdrawn, value: false

    it 'associates a course subject' do
      expect(record.course_subjects).to be_present
    end

    trait :unavailable do
      field :exposed_in_find?, value: false
    end

    trait :with_accredited_provider do
      field :accredited_provider, presence: true

      it 'creates two providers' do
        expect { record }.to change { Provider.count }.by(2)
      end
    end

    trait :with_provider_relationship_permissions do
      it_behaves_like 'trait :with_accredited_provider'

      it 'creates one provider relationship permission' do
        expect { record }.to change { ProviderRelationshipPermissions.count }.by(1)
      end

      it 'associates the provider relationship permission with the training provider' do
        expect(record.provider).to eq(ProviderRelationshipPermissions.last.training_provider)
      end

      it 'associates the provider relationship permission with the accredited provider' do
        expect(record.accredited_provider).to eq(ProviderRelationshipPermissions.last.ratifying_provider)
      end
    end

    trait :with_both_study_modes do
      field :study_mode, value: 'full_time_or_part_time'
    end

    trait :full_time do
      field :study_mode, value: 'full_time'
    end

    trait :part_time do
      field :study_mode, value: 'part_time'
    end

    trait :uuid do
      field :uuid, presence: true
    end

    trait :previous_year do
      field :recruitment_cycle_year, value: previous_year
    end

    trait :available_the_year_after do
      it 'creates two courses' do
        expect { record }.to change { Course.count }.by(2)
      end

      it 'creates a second course with the next recruitment cycle year' do
        expect(Course.last).not_to eq(record)
        expect(Course.last.recruitment_cycle_year).to eq(record.recruitment_cycle_year + 1)
      end
    end

    trait :previous_year_but_still_available do
      it_behaves_like 'trait :previous_year'
      it_behaves_like 'trait :available_the_year_after'
    end

    trait :available_in_current_and_next_year do
      field :recruitment_cycle_year, value: current_year
      it_behaves_like 'trait :available_the_year_after'
    end

    trait :fee_paying do
      field :funding_type, value: 'fee'
    end

    trait :salaried do
      field :funding_type, value: 'salary'
    end

    trait :apprenticeship do
      field :funding_type, value: 'apprenticeship'
    end

    trait :with_course_options do
      field :course_options, presence: true

      it 'creates two course options' do
        expect { record }.to change { CourseOption.count }.by(2)
      end
    end
  end
end
