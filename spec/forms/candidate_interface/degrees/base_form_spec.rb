require 'rails_helper'

RSpec.describe CandidateInterface::Degrees::BaseForm do
  subject(:base_form) { described_class.new(store, degree_params) }

  let(:store) { instance_double(WizardStateStores::RedisStore) }
  let(:application_form) { create(:application_form) }

  before { allow(store).to receive(:read) }

  describe 'attributes for persistence' do
    context 'uk' do
      let(:degree_params) do
        {
          application_form_id: 2,
          country: 'GB',
          uk_or_non_uk: 'uk',
          subject: 'History',
          degree_level: 'bachelor',
          type: 'Bachelor of Arts',
          university: 'The University of Cambridge',
          grade: 'First-class honours',
          completed: 'Yes',
          start_year: '2000',
          award_year: '2004',
        }
      end

      it 'persists the correct attributes' do
        expect(base_form.attributes_for_persistence).to eq(
          {
            application_form_id: 2,
            level: 'degree',
            international: false,
            institution_country: 'GB',
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
      let(:degree_params) do
        {
          application_form_id: 1,
          uk_or_non_uk: 'non_uk',
          subject: 'History',
          type: 'Doctor of Philosophy',
          university: 'Purdue University',
          country: 'USA',
          grade: 'No',
          completed: 'Yes',
          start_year: '2000',
          award_year: '2004',
        }
      end

      it 'persists the correct attributes' do
        attributes_for_persistence = base_form.attributes_for_persistence
        expect(attributes_for_persistence.compact).to eq(
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
          },
        )

        expect(attributes_for_persistence).to include({ enic_reason: nil, enic_reference: nil, comparable_uk_degree: nil })
      end
    end

    context 'international, from a country without compatible UK degrees' do
      let(:degree_params) do
        {
          application_form_id: 1,
          uk_or_non_uk: 'non_uk',
          subject: 'History',
          type: 'Diplôme',
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

      it 'persists the correct attributes' do
        attributes_for_persistence = base_form.attributes_for_persistence
        expect(attributes_for_persistence.compact).to eq(
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

    context 'international with a country and degree compatible with UK' do
      let(:degree_params) do
        {
          application_form_id: 2,
          uk_or_non_uk: 'non_uk',
          country: 'NG',
          subject: 'History',
          degree_level: 'bachelor',
          type: 'Bachelor of Arts',
          university: 'Nigerian University',
          grade: 'First-class honours',
          completed: 'Yes',
          start_year: '2000',
          award_year: '2004',
          enic_reference: '4000228364',
          enic_reason: 'maybe',
          comparable_uk_degree: 'Bachelor (Honours) degree',
        }
      end

      it 'captures the correct attributes for persistence' do
        attributes_for_persistence = base_form.attributes_for_persistence
        expect(attributes_for_persistence.compact).to eq(
          {
            application_form_id: 2,
            level: 'degree',
            international: true,
            institution_country: 'NG',
            qualification_type: 'Bachelor of Arts',
            qualification_type_hesa_code: '051',
            qualification_level: 'bachelor',
            qualification_level_uuid: DfE::ReferenceData::Qualifications::QUALIFICATIONS.some(name: 'bachelors degree').first.id,
            degree_type_uuid: Hesa::DegreeType.find_by_hesa_code('051').id,
            institution_name: 'Nigerian University',
            subject: 'History',
            subject_hesa_code: '100302',
            degree_subject_uuid: Hesa::Subject.find_by_name('History').id,
            predicted_grade: false,
            grade: 'First-class honours',
            grade_hesa_code: '01',
            degree_grade_uuid: '8741765a-13d8-4550-a413-c5a860a59d25',
            start_year: '2000',
            award_year: '2004',
            enic_reason: 'maybe',
          },
        )
      end
    end

    context 'further uk attributes' do
      let(:degree_params) do
        {
          uk_or_non_uk: 'uk',
          equivalent_level: 'Equivalent Degree',
          other_grade: 'Distinction',
        }
      end

      it 'persists value to correct database field' do
        expect(base_form.attributes_for_persistence).to include(
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
      let(:degree_params) do
        {
          uk_or_non_uk: 'uk',
          equivalent_level: 'Equivalent Degree',
          other_type: 'Doctor of Science (DSc)',
        }
      end

      it 'persists equivalent level to qualification type field' do
        expect(base_form.attributes_for_persistence).to include(
          {
            qualification_type: 'Equivalent Degree',
          },
        )
      end
    end

    context 'when masters degree is chosen' do
      let(:degree_params) do
        {
          uk_or_non_uk: 'uk',
          degree_level: 'master',
          type: 'Master of Science',
        }
      end

      it 'persists type to qualification type field' do
        expect(base_form.attributes_for_persistence).to include(
          {
            qualification_type: 'Master of Science',
            qualification_level: 'master',
            qualification_level_uuid: DfE::ReferenceData::Qualifications::QUALIFICATIONS.some(degree: :master).first.id,
          },
        )
      end
    end

    context 'when unknown degree level is chosen' do
      let(:degree_params) do
        {
          uk_or_non_uk: 'uk',
          degree_level: 'other',
          equivalent_level: 'Jedi lightsaber fight',
        }
      end

      it 'persists type to qualification type field' do
        expect(base_form.attributes_for_persistence).to include(
          {
            qualification_type: 'Jedi lightsaber fight',
            qualification_level: nil,
            qualification_level_uuid: nil,
          },
        )
      end
    end

    context 'when unknown degree type is chosen' do
      let(:degree_params) do
        {
          uk_or_non_uk: 'uk',
          degree_level: 'bachelor',
          type: 'Jedi lightsaber fight',
        }
      end

      it 'persists type to qualification type field' do
        expect(base_form.attributes_for_persistence).to include(
          {
            qualification_type: 'Jedi lightsaber fight',
            qualification_level: 'bachelor',
            qualification_level_uuid: DfE::ReferenceData::Qualifications::QUALIFICATIONS.some(degree: :bachelor).first.id,
          },
        )
      end
    end

    context 'international degree has no grade' do
      let(:degree_params) do
        {
          uk_or_non_uk: 'non_uk',
          grade: 'No',
        }
      end

      it 'persists value to correct database field' do
        expect(base_form.attributes_for_persistence).to include(
          {
            grade: 'N/A',
          },
        )
      end
    end

    context 'international degree is not completed' do
      let(:degree_params) do
        {
          uk_or_non_uk: 'non_uk',
          completed: 'No',
          comparable_uk_degree: 'Bachelor (Ordinary) degree',
          enic_reference: '400001234805',
        }
      end
      let(:base_form) { described_class.new(store, degree_params) }

      it 'persists nil value for comparable uk degree and enic reference' do
        expect(base_form.attributes_for_persistence).to include(
          {
            predicted_grade: true,
            comparable_uk_degree: nil,
            enic_reference: nil,
          },
        )
      end
    end
  end

  describe '.from_application_qualification' do
    let(:base_form) do
      described_class.from_application_qualification(store, application_qualification)
    end

    describe 'uk degree' do
      let(:application_qualification) do
        create(:degree_qualification, :bachelor, id: 1, grade: 'First-class honours')
      end

      context 'standard uk degree' do
        it 'rehydrates the degree base_form' do
          stores = {
            id: 1,
            uk_or_non_uk: 'uk',
            country: 'GB',
            application_form_id: application_qualification.application_form.id,
            degree_level: 'bachelor',
            equivalent_level: nil,
            type: application_qualification.qualification_type,
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

          expect(base_form.as_json).to include(stores.stringify_keys)
        end
      end

      context 'uk degree with bachelor other type' do
        before do
          application_qualification.qualification_type = 'Bachelor of Technology'
        end

        it 'rehydrates the correct attributes' do
          expect(base_form.degree_level).to eq('bachelor')
          expect(base_form.equivalent_level).to be_nil
          expect(base_form.type).to eq('other')
          expect(base_form.other_type).to eq('Bachelor of Technology')
        end
      end

      context 'uk degree with master other type' do
        before do
          application_qualification.qualification_level = 'master'
          application_qualification.qualification_type = 'Master of Business Administration'
        end

        it 'rehydrates the correct attributes' do
          expect(base_form.degree_level).to eq('master')
          expect(base_form.equivalent_level).to be_nil
          expect(base_form.type).to eq('other')
          expect(base_form.other_type).to eq('Master of Business Administration')
        end
      end

      context 'uk degree with free text type' do
        before do
          application_qualification.qualification_level = 'master'
          application_qualification.qualification_type = 'Master of Jedi'
        end

        it 'rehydrates the correct attributes' do
          expect(base_form.degree_level).to eq('master')
          expect(base_form.equivalent_level).to be_nil
          expect(base_form.type).to eq('other')
          expect(base_form.other_type).to eq('Master of Jedi')
        end
      end

      context 'uk degree with equivalent level' do
        before do
          application_qualification.qualification_level = 'other'
          application_qualification.qualification_type = 'A different degree'
        end

        it 'rehydrates the degree base_form' do
          expect(base_form.degree_level).to eq('other')
          expect(base_form.equivalent_level).to eq('A different degree')
          expect(base_form.type).to be_nil
          expect(base_form.other_type).to be_nil
        end
      end

      context 'uk degree level with free text' do
        before do
          application_qualification.qualification_type = 'Diploma of life'
          application_qualification.qualification_level = 'other'
        end

        it 'rehydrates the degree base_form' do
          expect(base_form.degree_level).to eq('other')
          expect(base_form.equivalent_level).to eq('Diploma of life')
          expect(base_form.type).to be_nil
          expect(base_form.other_type).to be_nil
        end
      end

      context 'uk degree with free text as level 6 diploma' do
        before do
          application_qualification.qualification_level = 'bachelor'
          application_qualification.qualification_type = 'Level 6 diploma'
        end

        it 'rehydrates the degree base_form' do
          expect(base_form.degree_level).to eq('bachelor')
          expect(base_form.equivalent_level).to be_nil
          expect(base_form.type).to eq('other')
          expect(base_form.other_type).to eq('Level 6 diploma')
        end
      end
    end

    describe 'non-uk degree' do
      let(:application_qualification) do
        create(:non_uk_degree_qualification, id: 1, enic_reason: nil)
      end

      context 'standard non uk degree' do
        it 'rehydrates the degree base_form' do
          stores = {
            id: 1,
            uk_or_non_uk: 'non_uk',
            country: application_qualification.institution_country,
            application_form_id: application_qualification.application_form.id,
            degree_level: nil,
            equivalent_level: nil,
            type: application_qualification.qualification_type,
            other_type: nil,
            grade: 'Other',
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

          expect(base_form.as_json).to include(stores.stringify_keys)
        end
      end

      context 'non-uk degree without enic reference or comparable uk degree' do
        before do
          application_qualification.enic_reference = nil
          application_qualification.comparable_uk_degree = nil
        end

        it 'rehydrates the correct attributes' do
          expect(base_form.enic_reason).to be_nil
          expect(base_form.enic_reference).to be_nil
          expect(base_form.comparable_uk_degree).to be_nil
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
        expect { base_form.persist! }.not_to(change { ApplicationQualification.count })
        application_qualification.reload
        expect(application_qualification.award_year).to eq('2011')
      end
    end

    context 'creates new international degree only if most fields are not blank' do
      let(:degree_params) {
        { id: nil, uk_or_non_uk: 'non_uk', subject: 'History', start_year: '2007', award_year: '2011', type: 'Bachelor of Arts',
          university: 'University of Paris', other_grade: '94%', application_form_id: application_form.id }
      }

      it 'creates new degree entry' do
        expect { base_form.persist! }.to change { ApplicationQualification.count }.from(1).to(2)
      end
    end

    context 'does not create new international degree if specific fields are blank' do
      let(:degree_params) { { id: nil, enic_reason: 'waiting', application_form_id: application_form.id } }

      it 'does not create new degree entry' do
        expect { base_form.persist! }.not_to(change { ApplicationQualification.count })
      end
    end

    context 'creates new uk degree only if most fields are not blank' do
      let(:degree_params) {
        { id: nil, uk_or_non_uk: 'uk', subject: 'Geography', start_year: '2007', award_year: '2011', degree_level: 'Bachelor', type: 'Master of Arts',
          university: 'University of Warwick', grade: 'First-class honours', application_form_id: application_form.id }
      }

      it 'creates new degree entry' do
        expect { base_form.persist! }.to change { ApplicationQualification.count }.from(1).to(2)
      end
    end

    context 'does not create new uk degree if specific fields are blank' do
      let(:degree_params) { { id: nil, award_year: '2011', application_form_id: application_form.id } }

      it 'does not create new degree entry' do
        expect { base_form.persist! }.not_to(change { ApplicationQualification.count })
      end
    end
  end
end
