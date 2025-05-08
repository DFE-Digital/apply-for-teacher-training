require 'rails_helper'

RSpec.describe CandidateInterface::DegreeWizard do
  subject(:wizard) { described_class.new(store, degree_params) }

  let(:degree_params) { {} }

  let(:store) { instance_double(WizardStateStores::RedisStore) }
  let(:application_form) { create(:application_form) }

  before do
    allow(store).to receive(:read)
    allow(Sentry).to receive(:capture_exception)
  end

  describe '#subject' do
    let(:degree_params) do
      {
        subject: 'Chemistry',
        subject_raw:,
      }
    end

    context 'when subject raw is present' do
      let(:subject_raw) { 'Math' }

      it 'returns raw value' do
        expect(wizard.subject).to eq(subject_raw)
      end
    end

    context 'when subject raw is empty' do
      let(:subject_raw) { '' }

      it 'returns raw value' do
        expect(wizard.subject).to eq(subject_raw)
      end
    end

    context 'when subject raw is nil' do
      let(:subject_raw) { nil }

      it 'returns original value' do
        expect(wizard.subject).to eq('Chemistry')
      end
    end
  end

  describe '#other_type' do
    let(:degree_params) do
      {
        other_type: 'Bachelor of Games',
        other_type_raw:,
      }
    end

    context 'when other type raw is present' do
      let(:other_type_raw) { 'Bachelor' }

      it 'returns raw value' do
        expect(wizard.other_type).to eq(other_type_raw)
      end
    end

    context 'when other type raw is empty' do
      let(:other_type_raw) { '' }

      it 'returns raw value' do
        expect(wizard.other_type).to eq(other_type_raw)
      end
    end

    context 'when other type raw is nil' do
      let(:other_type_raw) { nil }

      it 'returns original value' do
        expect(wizard.other_type).to eq('Bachelor of Games')
      end
    end
  end

  describe '#university' do
    let(:degree_params) do
      {
        university: 'Oxford',
        university_raw:,
      }
    end

    context 'when university raw is present' do
      let(:university_raw) { 'Oxford' }

      it 'returns raw value' do
        expect(wizard.university).to eq(university_raw)
      end
    end

    context 'when university raw is empty' do
      let(:university_raw) { '' }

      it 'returns raw value' do
        expect(wizard.university).to eq(university_raw)
      end
    end

    context 'when university raw is nil' do
      let(:university_raw) { nil }

      it 'returns original value' do
        expect(wizard.university).to eq('Oxford')
      end
    end
  end

  describe '#other_grade' do
    let(:degree_params) do
      {
        other_grade: 'Aegrotat',
        other_grade_raw:,
      }
    end

    context 'when other grade raw is present' do
      let(:other_grade_raw) { 'Something' }

      it 'returns raw value' do
        expect(wizard.other_grade).to eq(other_grade_raw)
      end
    end

    context 'when other grade raw is empty' do
      let(:other_grade_raw) { '' }

      it 'returns raw value' do
        expect(wizard.other_grade).to eq(other_grade_raw)
      end
    end

    context 'when other grade raw is nil' do
      let(:other_grade_raw) { nil }

      it 'returns original value' do
        expect(wizard.other_grade).to eq('Aegrotat')
      end
    end
  end

  describe '#next_step' do
    context 'country step' do
      context 'when country is uk' do
        let(:degree_params) { { uk_or_non_uk: 'uk', current_step: :country } }

        it 'redirects to degree type step' do
          expect(wizard.next_step).to be(:degree_level)
        end
      end

      context 'when country is not the uk and country is present' do
        let(:degree_params) { { uk_or_non_uk: 'non_uk', country: 'FR', current_step: :country } }

        it 'redirects to the subject step' do
          expect(wizard.next_step).to be(:type)
        end
      end

      context 'when country is not the uk and country is nil no degree' do
        let(:degree_params) do
          {
            uk_or_non_uk: 'non_uk',
            current_step: :country,
            application_form_id: application_form.id,
          }
        end

        it 'redirects to university_degree and raises Sentry error' do
          expect(wizard.next_step).to be(:university_degree)

          expect(Sentry).to have_received(:capture_exception).with(
            described_class::InvalidStepError.new(
              "Invalid Step for application_form: #{application_form.id}, previous_step: referer",
            ),
          )
        end
      end

      context 'when country is not the uk and country is nil with degree' do
        let(:application_form) { create(:application_form, :with_degree_and_gcses) }
        let(:degree_params) do
          {
            uk_or_non_uk: 'non_uk',
            current_step: :country,
            application_form_id: application_form.id,
          }
        end

        it 'redirects to review and raises Sentry error' do
          expect(wizard.next_step).to be(:review)

          expect(Sentry).to have_received(:capture_exception).with(
            described_class::InvalidStepError.new(
              "Invalid Step for application_form: #{application_form.id}, previous_step: referer",
            ),
          )
        end
      end
    end

    context 'level step' do
      let(:degree_params) { { current_step: :degree_level } }

      it 'redirects to the subject page' do
        expect(wizard.next_step).to be(:subject)
      end
    end

    describe 'subject step' do
      context 'when uk degree and level 6 diploma' do
        let(:degree_params) { { current_step: :subject, uk_or_non_uk: 'uk', degree_level: 'Level 6 Diploma' } }

        it 'redirects to the university page' do
          expect(wizard.next_step).to be(:university)
        end
      end

      context 'when uk degree and another qualification selected' do
        let(:degree_params) { { current_step: :subject, uk_or_non_uk: 'uk', degree_level: 'Another qualification equivalent to a degree' } }

        it 'redirects to the university page' do
          expect(wizard.next_step).to be(:university)
        end
      end

      context 'when uk degree and any other degree_level' do
        let(:degree_params) { { current_step: :subject, uk_or_non_uk: 'uk' } }

        it 'redirects to the type page' do
          expect(wizard.next_step).to be(:type)
        end
      end
    end

    context 'type step' do
      let(:degree_params) { { current_step: :type, uk_or_non_uk: 'uk' } }

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
      let(:degree_params) { { current_step: :completed, degree_level: degree_level } }

      context 'when degree type is not a doctorate' do
        let(:degree_level) { CandidateInterface::DegreeWizard::QUALIFICATION_LEVEL['bachelor'] }

        it 'redirects to the grades page' do
          expect(wizard.next_step).to be(:grade)
        end
      end

      context 'when degree type is doctorate' do
        let(:degree_level) { CandidateInterface::DegreeWizard::QUALIFICATION_LEVEL['doctor'] }

        it 'redirects to the start_year page' do
          expect(wizard.next_step).to be(:start_year)
        end
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

      it 'redirects to the award year page' do
        expect(wizard.next_step).to be(:award_year)
      end
    end

    describe 'award year step' do
      context 'uk degree' do
        let(:degree_params) { { uk_or_non_uk: 'uk', current_step: :award_year } }

        it 'redirects to the review page' do
          expect(wizard.next_step).to be(:review)
        end
      end

      context 'non_uk degree and completed' do
        let(:degree_params) { { uk_or_non_uk: 'non_uk', current_step: :award_year, completed: 'Yes' } }

        it 'redirects to the enic page' do
          expect(wizard.next_step).to be(:enic)
        end
      end

      context 'non_uk degree and not completed' do
        let(:degree_params) { { uk_or_non_uk: 'non_uk', current_step: :award_year, completed: 'No' } }

        it 'redirects to the review page' do
          expect(wizard.next_step).to be(:review)
        end
      end
    end

    context 'enic step' do
      let(:degree_params) { { current_step: :enic } }

      it 'redirects to the review page' do
        expect(wizard.next_step).to be(:review)
      end
    end

    context 'degree is persisted' do
      before do
        create(:degree_qualification, institution_country: nil)
      end

      let(:wizard) { described_class.from_application_qualification(store, ApplicationQualification.first) }

      context 'when degree level is changed' do
        it 'for a degree with types it asks users to select type and redirects to review' do
          wizard.current_step = :degree_level
          wizard.degree_level = 'Foundation degree'

          expect(wizard.next_step).to eq(:type)

          wizard.current_step = :type

          expect(wizard.next_step).to eq(:review)
        end

        it 'for a degree without types it redirects to review' do
          wizard.current_step = :degree_level
          wizard.degree_level = 'Level 6 Diploma'

          expect(wizard.next_step).to eq(:review)
        end
      end

      context 'when completed is changed' do
        it 'for a completed uk degree it asks user change award year and redirects to review' do
          wizard.current_step = :completed
          wizard.completed = 'Yes'

          expect(wizard.next_step).to eq(:award_year)

          wizard.current_step = :award_year

          expect(wizard.next_step).to eq(:review)
        end

        it 'for a completed international degree it asks user to change award year and fill in enic and redirects to review' do
          wizard.current_step = :completed
          wizard.completed = 'Yes'
          wizard.uk_or_non_uk = 'non_uk'

          expect(wizard.next_step).to eq(:award_year)

          wizard.current_step = :award_year

          expect(wizard.next_step).to eq(:enic)

          wizard.current_step = :enic

          expect(wizard.next_step).to eq(:review)
        end

        it 'for an incomplete degree it asks user to change award year and then redirects to review' do
          wizard.current_step = :completed
          wizard.completed = 'No'

          expect(wizard.next_step).to eq(:award_year)

          wizard.current_step = :award_year

          expect(wizard.next_step).to eq(:review)
        end
      end

      context 'when grade is changed' do
        it 'redirects to review' do
          wizard.current_step = :grade

          expect(wizard.next_step).to eq(:review)
        end
      end

      context 'when university is changed' do
        it 'redirects to review' do
          wizard.current_step = :university

          expect(wizard.next_step).to eq(:review)
        end
      end

      context 'when a uk degree is changed to international' do
        it 'redirects to type step' do
          wizard.current_step = :country
          wizard.uk_or_non_uk = 'non_uk'
          wizard.country = 'France'

          expect(wizard.next_step).to eq(:type)
        end
      end

      context 'when an international degree is changed to uk' do
        before do
          ApplicationQualification.delete_all
          create(:non_uk_degree_qualification)
        end

        it 'redirects to degree level step' do
          wizard.current_step = :country
          wizard.uk_or_non_uk = 'uk'

          # We need to manually delete this attribute as if the user has sent a blank form field
          # The wizard has already been constructed in the test so country field is not sanitised
          wizard.country = nil

          expect(wizard.next_step).to eq(:degree_level)
        end
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
      let(:degree_params) { { uk_or_non_uk: 'non_uk', grade: 'Yes', enic_reason: 'obtained' } }

      it { is_expected.to validate_presence_of(:country).on(:country) }
      it { is_expected.to validate_presence_of(:international_type).on(:type) }
      it { is_expected.to validate_presence_of(:other_grade).on(:grade) }
      it { is_expected.to validate_length_of(:other_grade).is_at_most(255).on(:grade) }
      it { is_expected.to validate_presence_of(:enic_reason).on(:enic) }
      it { is_expected.to validate_presence_of(:enic_reference).on(:enic_reference) }
      it { is_expected.to validate_presence_of(:comparable_uk_degree).on(:enic_reference) }
    end

    context 'UK validations' do
      let(:degree_params) { { uk_or_non_uk: 'uk', degree_level: 'Another qualification equivalent to a degree', grade: 'Other' } }

      it { is_expected.to validate_presence_of(:degree_level).on(:degree_level) }
      it { is_expected.to validate_presence_of(:equivalent_level).on(:degree_level) }
      it { is_expected.to validate_presence_of(:other_grade).on(:grade) }
      it { is_expected.to validate_length_of(:other_grade).is_at_most(255).on(:grade) }
      it { is_expected.to validate_presence_of(:type).on(:type) }
    end

    context 'grade is missing for UK degree with specified grade options' do
      let(:degree_params) { { uk_or_non_uk: 'uk', grade: nil, degree_level: 'Bachelor degree', type: 'Bachelor of Arts' } }

      it 'is invalid' do
        wizard.valid?(:grade)
        expect(wizard.errors.full_messages).to eq(['Grade Select your degree grade'])
      end
    end

    context 'other type' do
      let(:degree_params) { { uk_or_non_uk: 'uk', degree_level: 'Bachelor degree', type: 'Another bachelor degree type' } }

      it { is_expected.to validate_presence_of(:other_type).on(:type) }
      it { is_expected.to validate_length_of(:other_type).is_at_most(255).on(:type) }
    end

    context 'award year is before start year' do
      let(:degree_params) { { uk_or_non_uk: 'uk', start_year: current_year, award_year: previous_year } }

      it 'is invalid' do
        wizard.valid?(:award_year)
        expect(wizard.errors.full_messages).to eq(['Award year Enter a graduation year after your start year'])
      end
    end

    context 'start year is after graduation year' do
      let(:degree_params) { { uk_or_non_uk: 'uk', start_year: current_year, award_year: previous_year } }

      it 'is invalid' do
        wizard.valid?(:start_year)
        expect(wizard.errors.full_messages).to eq(['Start year Enter a start year before your graduation year'])
      end
    end

    context 'start year cannot be in future when degree completed' do
      let(:degree_params) { { uk_or_non_uk: 'uk', completed: 'Yes', start_year: next_year } }

      it 'is invalid' do
        wizard.valid?(:start_year)

        expect(wizard.errors.full_messages).to eq(['Start year Enter a start year in the past'])
      end
    end

    context 'award year cannot be in future when degree completed' do
      let(:degree_params) { { uk_or_non_uk: 'uk', completed: 'Yes', award_year: next_year } }

      it 'is invalid' do
        wizard.valid?(:award_year)

        expect(wizard.errors.full_messages).to eq(['Award year Enter an award year in the past'])
      end
    end

    context 'award year cannot be in the past when degree is incomplete' do
      let(:degree_params) { { uk_or_non_uk: 'uk', completed: 'No', start_year: previous_year - 1, award_year: previous_year, recruitment_cycle_year: current_year } }

      it 'is invalid' do
        wizard.valid?(:award_year)

        expect(wizard.errors.full_messages).to eq(['Award year Enter a year that is the current year or a year in the future'])
      end
    end

    context 'award year cannot be after end of current cycle if degree incomplete' do
      let(:degree_params) { { uk_or_non_uk: 'uk', completed: 'No', start_year: previous_year, award_year: next_year, recruitment_cycle_year: current_year } }

      it 'is invalid' do
        wizard.valid?(:award_year)

        expect(wizard.errors.full_messages).to eq(['Award year The date you graduate must be before the start of your teacher training'])
      end
    end
  end

  describe 'attributes for persistence' do
    context 'uk' do
      let(:wizard_attrs) do
        {
          application_form_id: 2,
          uk_or_non_uk: 'uk',
          subject: 'History',
          degree_level: 'Bachelor degree',
          type: 'Bachelor of Arts',
          university: 'The University of Cambridge',
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
            application_form_id: 2,
            level: 'degree',
            international: false,
            institution_country: nil,
            qualification_type: 'Bachelor of Arts',
            qualification_type_hesa_code: '051',
            qualification_level: 'bachelor',
            qualification_level_uuid: DfE::ReferenceData::Qualifications::QUALIFICATIONS.some(name: 'bachelors degree').first.id,
            degree_type_uuid: Hesa::DegreeType.find_by_hesa_code('051').id,
            institution_name: 'The University of Cambridge',
            institution_hesa_code: '0114',
            degree_institution_uuid: Hesa::Institution.find_by_name('The University of Cambridge').id,
            subject: 'History',
            subject_hesa_code: '100302',
            degree_subject_uuid: Hesa::Subject.find_by_name('History').id,
            grade: 'First-class honours',
            grade_hesa_code: '01',
            degree_grade_uuid: Hesa::Grade.find_by_description('First-class honours').id,
            predicted_grade: false,
            start_year: '2000',
            award_year: '2004',
            enic_reason: nil,
            enic_reference: nil,
            comparable_uk_degree: nil,
          },
        )
      end
    end

    context 'international with where no grade is awarded' do
      let(:wizard_attrs) do
        {
          application_form_id: 1,
          uk_or_non_uk: 'non_uk',
          subject: 'History',
          international_type: 'Doctor of Philosophy',
          university: 'Purdue University',
          country: 'USA',
          grade: 'No',
          completed: 'Yes',
          start_year: '2000',
          award_year: '2004',
        }
      end

      let(:wizard) { described_class.new(store, wizard_attrs) }

      it 'persists the correct attributes' do
        expect(wizard.attributes_for_persistence).to eq(
          {
            application_form_id: 1,
            international: true,
            level: 'degree',
            qualification_type: 'Doctor of Philosophy',
            institution_name: 'Purdue University',
            institution_country: 'USA',
            subject: 'History',
            degree_subject_uuid: Hesa::Subject.find_by_name('History').id,
            predicted_grade: false,
            grade: 'N/A',
            start_year: '2000',
            award_year: '2004',
            enic_reason: nil,
            enic_reference: nil,
            comparable_uk_degree: nil,
          },
        )
      end
    end

    context 'international' do
      let(:wizard_attrs) do
        {
          application_form_id: 1,
          uk_or_non_uk: 'non_uk',
          subject: 'History',
          international_type: 'Diplôme',
          university: 'Aix-Marseille University',
          country: 'FR',
          other_grade: '94%',
          completed: 'Yes',
          start_year: '2000',
          award_year: '2004',
          enic_reference: '4000228364',
          enic_reason: 'obtained',
          comparable_uk_degree: 'Bachelor (Honours) degree',
        }
      end

      let(:wizard) { described_class.new(store, wizard_attrs) }

      it 'persists the correct attributes' do
        expect(wizard.attributes_for_persistence).to eq(
          {
            application_form_id: 1,
            international: true,
            level: 'degree',
            qualification_type: 'Diplôme',
            institution_name: 'Aix-Marseille University',
            institution_country: 'FR',
            subject: 'History',
            degree_subject_uuid: Hesa::Subject.find_by_name('History').id,
            predicted_grade: false,
            grade: '94%',
            start_year: '2000',
            award_year: '2004',
            enic_reference: '4000228364',
            enic_reason: 'obtained',
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

    context 'other type and equivalent level are present' do
      let(:wizard_attrs) do
        {
          uk_or_non_uk: 'uk',
          equivalent_level: 'Equivalent Degree',
          other_type: 'Doctor of Science (DSc)',
        }
      end

      let(:wizard) { described_class.new(store, wizard_attrs) }

      it 'persists equivalent level to qualification type field' do
        expect(wizard.attributes_for_persistence).to include(
          {
            qualification_type: 'Equivalent Degree',
          },
        )
      end
    end

    context 'when masters degree is chosen' do
      let(:wizard_attrs) do
        {
          uk_or_non_uk: 'uk',
          degree_level: 'Master’s degree',
          type: 'Master of Science',
        }
      end

      let(:wizard) { described_class.new(store, wizard_attrs) }

      it 'persists type to qualification type field' do
        expect(wizard.attributes_for_persistence).to include(
          {
            qualification_type: 'Master of Science',
            qualification_level: 'master',
            qualification_level_uuid: DfE::ReferenceData::Qualifications::QUALIFICATIONS.some(degree: :master).first.id,
          },
        )
      end
    end

    context 'when unknown degree level is chosen' do
      let(:wizard_attrs) do
        {
          uk_or_non_uk: 'uk',
          degree_level: 'Jedi Knight',
          type: 'Jedi lightsaber fight',
        }
      end

      let(:wizard) { described_class.new(store, wizard_attrs) }

      it 'persists type to qualification type field' do
        expect(wizard.attributes_for_persistence).to include(
          {
            qualification_type: 'Jedi lightsaber fight',
            qualification_level: nil,
            qualification_level_uuid: nil,
          },
        )
      end
    end

    context 'when unknown degree type is chosen' do
      let(:wizard_attrs) do
        {
          uk_or_non_uk: 'uk',
          degree_level: 'Bachelor degree',
          type: 'Jedi lightsaber fight',
        }
      end

      let(:wizard) { described_class.new(store, wizard_attrs) }

      it 'persists type to qualification type field' do
        expect(wizard.attributes_for_persistence).to include(
          {
            qualification_type: 'Jedi lightsaber fight',
            qualification_level: 'bachelor',
            qualification_level_uuid: DfE::ReferenceData::Qualifications::QUALIFICATIONS.some(degree: :bachelor).first.id,
          },
        )
      end
    end

    context 'international degree has no grade' do
      let(:wizard_attrs) do
        {
          uk_or_non_uk: 'non_uk',
          grade: 'No',
        }
      end
      let(:wizard) { described_class.new(store, wizard_attrs) }

      it 'persists value to correct database field' do
        expect(wizard.attributes_for_persistence).to include(
          {
            grade: 'N/A',
          },
        )
      end
    end

    context 'international degree is not completed' do
      let(:wizard_attrs) do
        {
          uk_or_non_uk: 'non_uk',
          completed: 'No',
          comparable_uk_degree: 'Bachelor (Ordinary) degree',
          enic_reference: '400001234805',
        }
      end
      let(:wizard) { described_class.new(store, wizard_attrs) }

      it 'persists nil value for comparable uk degree and enic reference' do
        expect(wizard.attributes_for_persistence).to include(
          {
            predicted_grade: true,
            comparable_uk_degree: nil,
            enic_reference: nil,
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

    describe '#sanitize_uk_or_non_uk' do
      it 'clears the specified attributes' do
        wizard = described_class.new(store, attrs)
        expect(wizard.completed).to be_nil
        expect(wizard.grade).to be_nil
      end
    end

    context 'sanitize_grade' do
      let(:stored_data) { {}.to_json }
      let(:attrs) { { grade: 'First-class honours', other_grade: '94%', current_step: :grade } }

      it 'clears other grade' do
        wizard = described_class.new(store, attrs)
        expect(wizard.grade).to eq 'First-class honours'
        expect(wizard.other_grade).to be_nil
      end

      it 'does not clear other grade if other selected' do
        new_attrs = attrs.merge(grade: 'Other')
        wizard = described_class.new(store, new_attrs)
        expect(wizard.grade).to eq 'Other'
        expect(wizard.other_grade).to eq('94%')
      end
    end

    context 'sanitize_type' do
      context 'bachelor degree' do
        let(:stored_data) { { degree_level: 'Bachelor degree' }.to_json }
        let(:attrs) { { type: 'Bachelor of Arts', other_type: 'Bachelor of Technology', current_step: :type } }

        it 'clears other type' do
          wizard = described_class.new(store, attrs)
          expect(wizard.type).to eq 'Bachelor of Arts'
          expect(wizard.other_type).to be_nil
          expect(wizard.other_type_raw).to be_nil
        end

        it 'does not clear other type if another type selected' do
          new_attrs = attrs.merge(type: 'Another bachelor degree type')
          wizard = described_class.new(store, new_attrs)
          expect(wizard.type).to eq 'Another bachelor degree type'
          expect(wizard.other_type).to eq('Bachelor of Technology')
        end
      end

      context 'masters degree' do
        let(:stored_data) { { degree_level: 'Master’s degree' }.to_json }
        let(:attrs) { { type: 'Master of Science', other_type: 'Master of Technology', current_step: :type } }

        it 'clears other type' do
          wizard = described_class.new(store, attrs)
          expect(wizard.type).to eq 'Master of Science'
          expect(wizard.other_type).to be_nil
          expect(wizard.other_type_raw).to be_nil
        end

        it 'does not clear other type if another type selected' do
          new_attrs = attrs.merge(type: 'Another master’s degree type')
          wizard = described_class.new(store, new_attrs)
          expect(wizard.type).to eq 'Another master’s degree type'
          expect(wizard.other_type).to eq('Master of Technology')
        end
      end
    end

    context 'sanitize_degree_level' do
      let(:stored_data) { {}.to_json }
      let(:attrs) { { degree_level: 'Bachelor', equivalent_level: 'Diploma', current_step: :degree_level } }

      it 'clears the equivalent level' do
        wizard = described_class.new(store, attrs)
        expect(wizard.degree_level).to eq 'Bachelor'
        expect(wizard.equivalent_level).to be_nil
      end

      it 'does not clear equivalent level if another qualification selected' do
        new_attrs = attrs.merge(degree_level: 'Another qualification equivalent to a degree')
        wizard = described_class.new(store, new_attrs)
        expect(wizard.degree_level).to eq 'Another qualification equivalent to a degree'
        expect(wizard.equivalent_level).to eq 'Diploma'
      end
    end

    context 'sanitize_enic' do
      let(:stored_data) { {}.to_json }
      let(:no_attrs) { { enic_reason: 'not_needed', comparable_uk_degree: 'Bachelor (Ordinary) degree', current_step: :enic } }
      let(:yes_attrs) { { enic_reason: 'obtained', enic_reference: '40008234', comparable_uk_degree: 'Bachelor (Ordinary) degree', current_step: :enic } }

      it 'clears the enic number and comparable uk degree if enic_reason is NOT obtained' do
        wizard = described_class.new(store, no_attrs)
        expect(wizard.enic_reference).to be_nil
        expect(wizard.comparable_uk_degree).to be_nil
      end

      it 'does not clear the enic number and comparable uk degree if enic_reason is obtained' do
        wizard = described_class.new(store, yes_attrs)
        expect(wizard.enic_reference).to eq('40008234')
        expect(wizard.comparable_uk_degree).to eq('Bachelor (Ordinary) degree')
      end
    end
  end

  describe '.from_application_qualification' do
    let(:wizard) do
      described_class.from_application_qualification(store, application_qualification)
    end

    describe 'uk degree' do
      let(:application_qualification) do
        create(:degree_qualification, id: 1, qualification_type: 'Bachelor of Arts', grade: 'First-class honours')
      end

      context 'standard uk degree' do
        it 'rehydrates the degree wizard' do
          stores = {
            id: 1,
            uk_or_non_uk: 'uk',
            application_form_id: application_qualification.application_form.id,
            degree_level: 'Bachelor degree',
            equivalent_level: nil,
            type: application_qualification.qualification_type,
            international_type: nil,
            other_type: nil,
            grade: application_qualification.grade,
            other_grade: nil,
            completed: 'No',
            subject: application_qualification.subject,
            university: application_qualification.institution_name,
            start_year: application_qualification.start_year,
            award_year: application_qualification.award_year,
            enic_reason: nil,
            enic_reference: nil,
            comparable_uk_degree: nil,
          }

          expect(wizard.as_json).to include(stores.stringify_keys)
        end
      end

      context 'uk degree with bachelor other type' do
        before do
          application_qualification.qualification_type = 'Bachelor of Technology'
        end

        it 'rehydrates the correct attributes' do
          expect(wizard.degree_level).to eq('Bachelor degree')
          expect(wizard.equivalent_level).to be_nil
          expect(wizard.type).to eq('Another bachelor degree type')
          expect(wizard.international_type).to be_nil
          expect(wizard.other_type).to eq('Bachelor of Technology')
        end
      end

      context 'uk degree with master other type' do
        before do
          application_qualification.qualification_type = 'Master of Business Administration'
        end

        it 'rehydrates the correct attributes' do
          expect(wizard.degree_level).to eq('Master’s degree')
          expect(wizard.equivalent_level).to be_nil
          expect(wizard.type).to eq('Another master’s degree type')
          expect(wizard.international_type).to be_nil
          expect(wizard.other_type).to eq('Master of Business Administration')
        end
      end

      context 'uk degree with free text type' do
        before do
          application_qualification.qualification_level = 'master'
          application_qualification.qualification_type = 'Master of Jedi'
        end

        it 'rehydrates the correct attributes' do
          expect(wizard.degree_level).to eq('Master’s degree')
          expect(wizard.equivalent_level).to be_nil
          expect(wizard.type).to eq('Another master’s degree type')
          expect(wizard.international_type).to be_nil
          expect(wizard.other_type).to eq('Master of Jedi')
        end
      end

      context 'uk degree with equivalent level' do
        before do
          application_qualification.qualification_type = 'A different degree'
        end

        it 'rehydrates the degree wizard' do
          expect(wizard.degree_level).to eq('Another qualification equivalent to a degree')
          expect(wizard.equivalent_level).to eq('A different degree')
          expect(wizard.type).to be_nil
          expect(wizard.international_type).to be_nil
          expect(wizard.other_type).to be_nil
        end
      end

      context 'uk degree level with free text' do
        before do
          application_qualification.qualification_type = 'Diploma of life'
        end

        it 'rehydrates the degree wizard' do
          expect(wizard.degree_level).to eq('Another qualification equivalent to a degree')
          expect(wizard.equivalent_level).to eq('Diploma of life')
          expect(wizard.international_type).to be_nil
          expect(wizard.other_type).to be_nil
        end
      end

      context 'uk degree with free text as level 6 diploma' do
        before do
          application_qualification.qualification_level = 'bachelor'
          application_qualification.qualification_type = 'Level 6 diploma'
        end

        it 'rehydrates the degree wizard' do
          expect(wizard.degree_level).to eq('Bachelor degree')
          expect(wizard.equivalent_level).to be_nil
          expect(wizard.international_type).to be_nil
          expect(wizard.other_type).to eq('Level 6 diploma')
        end
      end
    end

    describe 'non-uk degree' do
      let(:application_qualification) do
        create(:non_uk_degree_qualification, id: 1, enic_reason: nil)
      end

      context 'standard non uk degree' do
        it 'rehydrates the degree wizard' do
          stores = {
            id: 1,
            uk_or_non_uk: 'non_uk',
            country: application_qualification.institution_country,
            application_form_id: application_qualification.application_form.id,
            degree_level: nil,
            equivalent_level: nil,
            type: nil,
            international_type: application_qualification.qualification_type,
            other_type: nil,
            grade: 'Yes',
            other_grade: application_qualification.grade,
            completed: 'Yes',
            subject: application_qualification.subject,
            university: application_qualification.institution_name,
            start_year: application_qualification.start_year,
            award_year: application_qualification.award_year,
            enic_reason: nil,
            enic_reference: application_qualification.enic_reference,
            comparable_uk_degree: application_qualification.comparable_uk_degree,
          }

          expect(wizard.as_json).to include(stores.stringify_keys)
        end
      end

      context 'non-uk degree without enic reference or comparable uk degree' do
        before do
          application_qualification.enic_reference = nil
          application_qualification.comparable_uk_degree = nil
        end

        it 'rehydrates the correct attributes' do
          expect(wizard.enic_reason).to be_nil
          expect(wizard.enic_reference).to be_nil
          expect(wizard.comparable_uk_degree).to be_nil
        end
      end
    end
  end

  describe '#persist' do
    let!(:application_qualification) { create(:degree_qualification, award_year: '2014') }
    let(:degree_params) do
      {
        id: application_qualification.id,
        application_form_id: application_form.id,
        uk_or_non_uk: 'uk',
        subject: 'History',
        start_year: '2007',
        award_year: '2011',
        type: 'Bachelor of Arts',
        university: 'Manchester',
        grade: 'Pass',
      }
    end

    before do
      allow(store).to receive(:delete)
    end

    context 'updates degree if it exists and all necessary fields are present' do
      it 'attribute is changed' do
        expect { wizard.persist! }.not_to(change { ApplicationQualification.count })
        application_qualification.reload
        expect(application_qualification.award_year).to eq('2011')
      end
    end

    context 'creates new international degree only if most fields are not blank' do
      let(:degree_params) {
        { id: nil, uk_or_non_uk: 'non_uk', subject: 'History', start_year: '2007', award_year: '2011', international_type: 'Bachelor of Arts',
          university: 'University of Paris', other_grade: '94%', application_form_id: application_form.id }
      }

      it 'creates new degree entry' do
        expect { wizard.persist! }.to change { ApplicationQualification.count }.from(1).to(2)
      end
    end

    context 'does not create new international degree if specific fields are blank' do
      let(:degree_params) { { id: nil, enic_reason: 'waiting', application_form_id: application_form.id } }

      it 'does not create new degree entry' do
        expect { wizard.persist! }.not_to(change { ApplicationQualification.count })
      end
    end

    context 'creates new uk degree only if most fields are not blank' do
      let(:degree_params) {
        { id: nil, uk_or_non_uk: 'uk', subject: 'Geography', start_year: '2007', award_year: '2011', degree_level: 'Bachelor', type: 'Master of Arts',
          university: 'University of Warwick', grade: 'First-class honours', application_form_id: application_form.id }
      }

      it 'creates new degree entry' do
        expect { wizard.persist! }.to change { ApplicationQualification.count }.from(1).to(2)
      end
    end

    context 'does not create new uk degree if specific fields are blank' do
      let(:degree_params) { { id: nil, award_year: '2011', application_form_id: application_form.id } }

      it 'does not create new degree entry' do
        expect { wizard.persist! }.not_to(change { ApplicationQualification.count })
      end
    end
  end
end
