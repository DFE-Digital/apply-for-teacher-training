require 'rails_helper'

RSpec.describe CandidateInterface::DegreeWizard do
  subject(:wizard) { described_class.new(store, degree_params) }

  let(:degree_params) { {} }

  let(:store) { instance_double(WizardStateStores::RedisStore) }

  before { allow(store).to receive(:read) }

  describe '#next_step' do
    context 'country step' do
      context 'when country is uk' do
        let(:degree_params) { { uk_or_non_uk: 'uk', current_step: :country } }

        it 'redirects to degree type step' do
          expect(wizard.next_step).to be(:level)
        end
      end

      context 'when country is not the uk and country is present' do
        let(:degree_params) { { uk_or_non_uk: 'non_uk', country: 'France', current_step: :country } }

        it 'redirects to the subject step' do
          expect(wizard.next_step).to be(:subject)
        end
      end

      context 'when country is not the uk and country is nil' do
        let(:degree_params) { { uk_or_non_uk: 'non_uk', current_step: :country } }

        it 'raises an InvalidStepError' do
          expect { wizard.next_step }.to raise_error(CandidateInterface::DegreeWizard::InvalidStepError)
        end
      end
    end

    context 'level step' do
      let(:degree_params) { { current_step: :level } }

      it 'redirects to the subject page' do
        expect(wizard.next_step).to be(:subject)
      end
    end

    describe 'subject step' do
      context 'when uk degree and level 6 diploma' do
        let(:degree_params) { { current_step: :subject, uk_or_non_uk: 'uk', level: 'Level 6 Diploma' } }

        it 'redirects to the university page' do
          expect(wizard.next_step).to be(:university)
        end
      end

      context 'when uk degree and another qualification selected' do
        let(:degree_params) { { current_step: :subject, uk_or_non_uk: 'uk', level: 'Another qualification equivalent to a degree' } }

        it 'redirects to the university page' do
          expect(wizard.next_step).to be(:university)
        end
      end

      context 'when either uk or non_uk degree and any other degree level' do
        let(:degree_params) { { current_step: :subject, uk_or_non_uk: %w[uk non_uk].sample } }

        it 'redirects to the type page' do
          expect(wizard.next_step).to be(:type)
        end
      end
    end

    context 'type step' do
      let(:degree_params) { { current_step: :type } }

      it 'redirects to university page' do
        expect(wizard.next_step).to be(:university)
      end
    end

    context 'university step' do
      let(:degree_params) { { current_step: :university } }

      it 'redirects to completed page' do
        expect(wizard.next_step).to be(:completed)
      end
    end

    context 'completed step' do
      let(:degree_params) { { current_step: :completed } }

      it 'redirects to the grades page' do
        expect(wizard.next_step).to be(:grade)
      end
    end

    context 'grade step' do
      let(:degree_params) { { current_step: :grade } }

      it 'redirects to the start years page' do
        expect(wizard.next_step).to be(:start_year)
      end
    end

    context 'start year step' do
      let(:degree_params) { { current_step: :start_year } }

      it 'redirects to the graduation years page' do
        expect(wizard.next_step).to be(:award_year)
      end
    end

    describe 'graduation year step' do
      context 'uk degree' do
        let(:degree_params) { { uk_or_non_uk: 'uk', current_step: :award_year } }

        it 'redirects to the graduation years page' do
          expect(wizard.next_step).to be(:review)
        end
      end

      context 'non_uk degree' do
        let(:degree_params) { { uk_or_non_uk: 'non_uk', current_step: :award_year } }

        it 'redirects to the enic page' do
          expect(wizard.next_step).to be(:enic)
        end
      end
    end

    context 'enic step' do
      let(:degree_params) { { uk_or_non_uk: 'non_uk', current_step: :enic } }

      it 'redirects to the review page' do
        expect(wizard.next_step).to be(:review)
      end
    end
  end

  context 'validations' do
    it { is_expected.to validate_presence_of(:uk_or_non_uk).on(:country) }
    it { is_expected.to validate_presence_of(:subject).on(:subject) }
    it { is_expected.to validate_length_of(:subject).is_at_most(255).on(:subject) }
    it { is_expected.to validate_presence_of(:university).on(:university) }
    it { is_expected.to validate_presence_of(:completed).on(:completed) }
    it { is_expected.to validate_presence_of(:start_year).on(:start_year) }
    it { is_expected.to validate_presence_of(:award_year).on(:award_year) }

    context 'Non-UK validations' do
      let(:degree_params) { { uk_or_non_uk: 'non_uk', have_grade: 'Yes', have_enic_reference: 'yes' } }

      it { is_expected.to validate_presence_of(:country).on(:country) }
      it { is_expected.to validate_presence_of(:international_type).on(:type) }
      it { is_expected.to validate_presence_of(:have_grade).on(:grade) }
      it { is_expected.to validate_presence_of(:other_grade).on(:grade) }
      it { is_expected.to validate_length_of(:other_grade).is_at_most(255).on(:grade) }
      it { is_expected.to validate_presence_of(:have_enic_reference).on(:enic) }
      it { is_expected.to validate_presence_of(:enic_reference).on(:enic) }
      it { is_expected.to validate_presence_of(:comparable_uk_degree).on(:enic) }
    end

    context 'UK validations' do
      let(:degree_params) { { uk_or_non_uk: 'uk', level: 'Another qualification equivalent to a degree', grade: 'Other' } }

      it { is_expected.to validate_presence_of(:level).on(:level) }
      it { is_expected.to validate_presence_of(:equivalent_level).on(:level) }
      it { is_expected.to validate_presence_of(:grade).on(:grade) }
      it { is_expected.to validate_presence_of(:other_grade).on(:grade) }
      it { is_expected.to validate_length_of(:other_grade).is_at_most(255).on(:grade) }
      it { is_expected.to validate_presence_of(:type).on(:type) }
    end

    context 'other type' do
      let(:degree_params) { { uk_or_non_uk: 'uk', level: 'Bachelor degree', type: 'Another bachelor degree type' } }

      it { is_expected.to validate_presence_of(:other_type).on(:type) }
      it { is_expected.to validate_length_of(:other_type).is_at_most(255).on(:type) }
    end
  end

  describe 'attributes for persistence' do
    context 'uk' do
      let(:wizard_attrs) do
        {
          uk_or_non_uk: 'uk',
          subject: 'History',
          level: 'Bachelor degree',
          type: 'Bachelor of Arts (BA)',
          university: 'The University of Cambridge',
          have_grade: 'Yes',
          grade: 'First-class honours',
          completed: 'Yes',
          start_year: '2000',
          award_year: '2004',
        }
      end

      let(:wizard) { described_class.new(store, wizard_attrs) }

      it 'persists the correct attributes' do
        expect(wizard.attributes_for_persistence).to eq(
          {
            international: false,
            qualification_type: 'Bachelor of Arts (BA)',
            qualification_type_hesa_code: nil,
            institution_name: 'The University of Cambridge',
            institution_hesa_code: '114',
            subject: 'History',
            subject_hesa_code: '100302',
            grade: 'First-class honours',
            grade_hesa_code: nil,
            predicted_grade: false,
            start_year: '2000',
            award_year: '2004',
          },
        )
      end
    end

    context 'international' do
      let(:wizard_attrs) do
        {
          uk_or_non_uk: 'non_uk',
          subject: 'History',
          international_type: 'Diplôme',
          university: 'Aix-Marseille University',
          country: 'France',
          other_grade: '94%',
          completed: 'No',
          start_year: '2000',
          award_year: '2004',
          enic_reference: '4000228364',
          comparable_uk_degree: 'Bachelor (Honours) degree',
        }
      end

      let(:wizard) { described_class.new(store, wizard_attrs) }

      it 'persists the correct attributes' do
        expect(wizard.attributes_for_persistence).to eq(
          {
            international: true,
            qualification_type: 'Diplôme',
            institution_name: 'Aix-Marseille University',
            institution_country: 'France',
            subject: 'History',
            predicted_grade: true,
            grade: '94%',
            start_year: '2000',
            award_year: '2004',
            enic_reference: '4000228364',
            comparable_uk_degree: 'Bachelor (Honours) degree',
          },
        )
      end
    end

    context 'further uk attributes' do
      let(:wizard_attrs) do
        {
          uk_or_non_uk: 'uk',
          equivalent_level: 'Equivalent Degree',
          other_grade: 'Distinction',
        }
      end

      let(:wizard) { described_class.new(store, wizard_attrs) }

      it 'persists value to correct database field' do
        expect(wizard.attributes_for_persistence).to include(
          {
            qualification_type: 'Equivalent Degree',
            qualification_type_hesa_code: nil,
            grade: 'Distinction',
            grade_hesa_code: '12',
          },
        )
      end
    end
  end

  describe '#sanitize_attrs' do
    let(:stored_data) { { uk_or_non_uk: 'uk', completed: 'Yes', grade: 'First-class honours' }.to_json }
    let(:attrs) { { uk_or_non_uk: 'non_uk', current_step: :country } }

    before do
      allow(store).to receive(:read).and_return(stored_data)
    end

    context 'on the country_step' do
      it 'clears the specified attributes' do
        instance = described_class.new(store, attrs)
        expect(instance.completed).to be_nil
        expect(instance.grade).to be_nil
      end
    end

    context 'on the grade step' do
      let(:attrs) { { uk_or_non_uk: 'non_uk', current_step: :grade } }

      it 'does not clear the specified attributes' do
        instance = described_class.new(store, attrs)
        expect(instance.completed).to eq 'Yes'
        expect(instance.grade).to eq 'First-class honours'
      end
    end
  end
end
