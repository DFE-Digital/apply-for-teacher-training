require 'rails_helper'

RSpec.describe 'ApplicationForm factory' do
  subject(:record) { |attrs: {}| create(factory, *traits, **attributes, **attrs) }

  let(:factory) { :application_form }
  let(:traits) { [] }
  let(:attributes) { {} }

  factory :application_form do
    it 'creates one form' do
      expect { record }.to change { ApplicationForm.count }.by(1)
    end

    it 'creates one candidate' do
      expect { record }.to change { Candidate.count }.by(1)
    end

    field :candidate, presence: true
    field :address_type, value: 'uk'
  end

  trait :minimum_info do
    field :address_line1, presence: true
    field :country, presence: true
    field :date_of_birth, presence: true
    field :first_name, presence: true
    field :first_nationality, presence: true
    field :last_name, presence: true
    field :phone_number, presence: true
    field :second_nationality, presence: true

    field :interview_preferences, type: String
    field :safeguarding_issues_status, value: 'no_safeguarding_issues_to_declare'

    it 'sets `submitted_at` to after `created_at`' do
      expect(record.submitted_at).to be > record.created_at
    end
  end

  trait :submitted, aliased_to: :minimum_info

  trait :duplicate_candidates do
    context 'with an existing application form' do
      before do
        create(:application_form, date_of_birth: '1990-01-01', postcode: 'SW1A 1AA')
      end

      field :date_of_birth, value: Date.parse('1990-01-01')
      field :postcode, value: 'SW1A 1AA'
      field :last_name, value: 'Thompson'
    end

    context 'without an existing application form' do
      field :date_of_birth, presence: true
      field :postcode, presence: true
      field :last_name, value: 'Thompson'
    end
  end

  trait :international_address do
    field :address_type, value: 'international'
    field :country, presence: true
  end

  trait :with_safeguarding_issues_never_asked do
    field :safeguarding_issues_status, value: 'never_asked'
  end

  trait :with_degree do
    it 'creates one degree' do
      expect { record }.to change { ApplicationQualification.degrees.count }.by(1)
    end

    it 'associates the degree' do
      expect(record.application_qualifications.degrees).to be_present
    end
  end

  trait :with_gcses do
    it 'creates three GCSEs' do
      expect { record }.to change { ApplicationQualification.gcses.count }.by(3)
    end

    it 'associates the GCSEs' do
      expect(record.application_qualifications.gcses.count).to eq(3)
    end
  end

  trait :with_a_levels do
    it 'creates between one and three A levels' do
      expect { record }.to change { ApplicationQualification.a_levels.count }.by(1..3)
    end

    it 'associates the A levels' do
      expect(record.application_qualifications.a_levels.count).to be_between(1, 3)
    end
  end

  trait :with_degree_and_gcses do
    it 'creates one degree' do
      expect { record }.to change { ApplicationQualification.degrees.count }.by(1)
    end

    it 'creates some GCSEs' do
      expect { record }.to change { ApplicationQualification.gcses.count }.by(1..)
    end

    it 'associates the degree and GCSEs' do
      expect(record.application_qualifications.degrees).to be_present
      expect(record.application_qualifications.gcses).to be_present
    end
  end

  trait :with_completed_references do
    it 'creates two references' do
      expect { record }.to change { ApplicationReference.count }.by(2)
    end

    field :application_references, presence: true
    field :references_completed?, value: true

    it 'marks the references as provided' do
      expect(record.application_references.map(&:feedback_status).uniq).to eq(['feedback_provided'])
    end
  end

  trait :with_feedback_completed do
    field :feedback_satisfaction_level, one_of: ApplicationForm.feedback_satisfaction_levels.values
    field :feedback_suggestions, type: String
  end

  trait :with_equality_and_diversity_data do
    it 'sets regular and HESA E&D data' do
      expect(record.equality_and_diversity).to be_present
      expect(record.equality_and_diversity['disabilities']).to be_an(Array)
      expect(record.equality_and_diversity['ethnic_background']).to be_present
      expect(record.equality_and_diversity['ethnic_group']).to be_present
      expect(record.equality_and_diversity['hesa_disabilities']).to be_an(Array)
      expect(record.equality_and_diversity['hesa_ethnicity']).to be_present
      expect(record.equality_and_diversity['sex']).to be_present
      expect(record.equality_and_diversity['hesa_sex']).to be_present
    end
  end

  trait :eligible_for_free_school_meals do
    field :first_nationality, one_of: %w[British Irish]
    field :date_of_birth, value: 20.years.ago.to_date
  end

  trait :with_safeguarding_issues_disclosed do
    field :safeguarding_issues_status, value: 'has_safeguarding_issues_to_declare'
    field :safeguarding_issues, type: String
  end

  trait :with_accepted_offer do
    it 'adds an application choice with an accepted offer' do
      expect { record }.to change { ApplicationChoice.count }.by(1)
      expect(record.application_choices.first.status).to eq('pending_conditions')
    end
  end

  trait :completed do |phase: nil|
    it_behaves_like 'trait :minimum_info'

    field :support_reference, presence: true
    field :further_information, type: String
    field :disclose_disability, one_of: [true, false]

    context 'if `disclose_disability` is true' do
      let(:attributes) { { disclose_disability: true } }

      field :disability_disclosure, type: String
    end

    context 'if `disclose_disability` is false' do
      let(:attributes) { { disclose_disability: false } }

      field :disability_disclosure, presence: false
    end

    field :address_line3, type: String
    field :address_line4, type: String
    field :postcode, type: String
    field :becoming_a_teacher, type: String
    field :work_history_explanation, type: String
    field :volunteering_experience, one_of: [true, false, nil]
    field :phase, value: phase || 'apply_1'

    context "if `first_nationality` is 'British'" do
      let(:attributes) { { first_nationality: 'British' } }

      field :right_to_work_or_study, presence: false
    end

    context 'if `first_nationality` is something else' do
      let(:attributes) { { first_nationality: 'Irish' } }

      field :right_to_work_or_study, one_of: %(yes no)
    end

    context "if `right_to_work_or_study` is 'yes'" do
      let(:attributes) { { right_to_work_or_study: 'yes' } }

      field :immigration_status, one_of: %w[eu_settled eu_pre_settled other]
    end

    context 'if `right_to_work_or_study` is anything else' do
      let(:attributes) { { right_to_work_or_study: 'no' } }

      field :immigration_status, presence: false
    end

    context "if `immigration_status` is 'other'" do
      let(:attributes) { { immigration_status: 'other' } }

      field :right_to_work_or_study_details, value: 'Indefinite leave to remain'
    end

    context 'if `immigration_status` is anything else' do
      let(:attributes) { { immigration_status: 'eu_settled' } }

      field :right_to_work_or_study_details, presence: false
    end

    field :becoming_a_teacher_completed, value: true
    field :contact_details_completed, value: true
    field :course_choices_completed, value: true
    field :degrees_completed, value: true
    field :english_gcse_completed, value: true
    field :interview_preferences_completed, value: true
    field :maths_gcse_completed, value: true
    field :other_qualifications_completed, value: true
    field :personal_details_completed, value: true
    field :references_completed, value: true
    field :safeguarding_issues_completed, value: true
    field :science_gcse_completed, value: true
    field :training_with_a_disability_completed, value: true
    field :volunteering_completed, value: true
    field :work_history_completed, value: true

    context 'application_choices_count option' do
      let(:attributes) { { application_choices_count: 2 } }

      it 'adds the specified number of unsubmitted application choices' do
        expect(record.application_choices.count).to eq(2)
        expect(record.application_choices.map(&:status).uniq).to eq(['unsubmitted'])
      end
    end

    context 'submitted_application_choices_count option' do
      let(:attributes) { { submitted_application_choices_count: 2 } }

      it 'adds the specified number of submitted application choices' do
        expect(record.application_choices.count).to eq(2)
        expect(record.application_choices.map(&:status).uniq).not_to eq(['unsubmitted'])
      end
    end

    context 'with_accepted_offer option' do
      let(:attributes) do
        {
          with_accepted_offer: true,
          submitted_application_choices_count: 1,
        }
      end

      it 'adds the requested number of submitted application choices with an accepted offer' do
        expect(record.application_choices.count).to eq(1)
        expect(record.application_choices.first.status).to eq('pending_conditions')
      end
    end

    context 'with full work history requested' do
      let(:attributes) { { full_work_history: true } }

      it 'adds two jobs' do
        expect(record.application_work_experiences.count).to eq(2)
      end

      it 'adds one work break' do
        expect(record.application_work_history_breaks.count).to eq(1)
      end
    end

    context 'with full work history not requested' do
      let(:attributes) do
        {
          full_work_history: false,
          work_experiences_count: 2,
        }
      end

      it 'adds the requested number of jobs' do
        expect(record.application_work_experiences.count).to eq(2)
      end

      it 'does not add a work break' do
        expect(record.application_work_history_breaks.count).to eq(0)
      end
    end

    context 'references_count option' do
      let(:attributes) { { references_count: 2 } }

      it 'adds the specified number of references' do
        expect(record.application_references.count).to eq(2)
      end
    end

    context 'references_state option' do
      let(:attributes) do
        {
          references_state: :feedback_requested,
          references_count: 1,
        }
      end

      it 'adds the specified number of references in that state' do
        expect(record.application_references.count).to eq(1)
        expect(record.application_references.first.feedback_status).to eq('feedback_requested')
      end
    end
  end

  trait :carry_over do
    it_behaves_like 'trait :completed'

    field :created_at, value: CycleTimetableHelper.mid_cycle
    field :updated_at, value: CycleTimetableHelper.mid_cycle

    it 'associates a previous application form in the previous year' do
      expect(record.previous_application_form).to be_present
      expect(record.previous_application_form.recruitment_cycle_year).to eq(previous_year)
    end
  end

  trait :apply_again do
    it_behaves_like 'trait :completed', phase: 'apply_2'

    field :created_at, value: CycleTimetableHelper.before_apply_deadline
    field :updated_at, value: CycleTimetableHelper.before_apply_deadline

    it 'associates a previous application form in the current year' do
      expect(record.previous_application_form).to be_present
      expect(record.previous_application_form.recruitment_cycle_year).to eq(current_year)
    end
  end

  factory :completed_application_form do
    it_behaves_like 'trait :completed'
  end
end
