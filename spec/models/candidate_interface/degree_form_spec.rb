require 'rails_helper'

RSpec.describe CandidateInterface::DegreeForm, type: :model do
  let(:form_data) do
    {
      qualification_type: 'BA',
      subject: 'Doge',
      institution_name: 'University of Much Wow',
    }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:qualification_type).on(:base) }
    it { is_expected.to validate_presence_of(:subject).on(:base) }
    it { is_expected.to validate_presence_of(:institution_name).on(:base) }
    it { is_expected.to validate_presence_of(:grade).on(:grade) }
    it { is_expected.to validate_presence_of(:award_year).on(:award_year) }

    it "validates presence of `other_grade` if chosen grade is 'other'" do
      degree = CandidateInterface::DegreeForm.new(grade: 'other')
      error_message = t('activemodel.errors.models.candidate_interface/degree_form.attributes.other_grade.blank')

      degree.validate(:grade)

      expect(degree.errors.full_messages_for(:other_grade)).to eq(
        ["Other grade #{error_message}"],
      )
    end

    it "validates presence of `predicted_grade` if chosen grade is 'predicted'" do
      degree = CandidateInterface::DegreeForm.new(grade: 'predicted')
      error_message = t('activemodel.errors.models.candidate_interface/degree_form.attributes.predicted_grade.blank')

      degree.validate(:grade)

      expect(degree.errors.full_messages_for(:predicted_grade)).to eq(
        ["Predicted grade #{error_message}"],
      )
    end

    it { is_expected.to validate_length_of(:qualification_type).is_at_most(255).on(:base) }
    it { is_expected.to validate_length_of(:subject).is_at_most(255).on(:base) }
    it { is_expected.to validate_length_of(:institution_name).is_at_most(255).on(:base) }
    it { is_expected.to validate_length_of(:grade).is_at_most(255).on(:grade) }
    it { is_expected.to validate_length_of(:other_grade).is_at_most(255).on(:grade) }
    it { is_expected.to validate_length_of(:predicted_grade).is_at_most(255).on(:grade) }

    describe 'award year' do
      ['a year', '200'].each do |invalid_date|
        it "is invalid if the award year is '#{invalid_date}'" do
          degree = CandidateInterface::DegreeForm.new(award_year: invalid_date)
          error_message = t('activemodel.errors.models.candidate_interface/degree_form.attributes.award_year.invalid')

          degree.validate(:award_year)

          expect(degree.errors.full_messages_for(:award_year)).to eq(
            ["Award year #{error_message}"],
          )
        end
      end

      it 'is valid if the award year is 4 digits' do
        degree = CandidateInterface::DegreeForm.new(award_year: '2009')
        error_message = t('activemodel.errors.models.candidate_interface/degree_form.attributes.award_year.invalid')

        degree.validate

        expect(degree.errors.full_messages_for(:award_year)).not_to eq(
          ["Award year #{error_message}"],
        )
      end
    end
  end

  describe '.build_all_from_application' do
    it 'creates an array of objects based on the provided ApplicationForm' do
      application_form = create(:application_form) do |form|
        form.application_qualifications.create(
          level: 'degree',
          qualification_type: 'BA',
          subject: 'Woof',
          institution_name: 'University of Doge',
          grade: 'first',
          predicted_grade: false,
          award_year: '2008',
        )
        form.application_qualifications.create(
          level: 'degree',
          qualification_type: 'BA',
          subject: 'Meow',
          institution_name: 'University of Cate',
          grade: 'upper_second',
          predicted_grade: true,
          award_year: '2010',
        )
      end

      degrees = CandidateInterface::DegreeForm.build_all_from_application(application_form)

      expect(degrees).to match_array([
        have_attributes(
          qualification_type: 'BA',
          subject: 'Woof',
          institution_name: 'University of Doge',
          grade: 'first',
          award_year: '2008',
        ),
        have_attributes(
          qualification_type: 'BA',
          subject: 'Meow',
          institution_name: 'University of Cate',
          grade: 'upper_second',
          award_year: '2010',
        ),
      ])
    end

    it 'only includes degrees and not other qualifications' do
      application_form = create(:application_form) do |form|
        form.application_qualifications.create(
          level: 'degree',
          qualification_type: 'BA',
          subject: 'Ssss',
          institution_name: 'University of Snek',
          grade: 'third',
          award_year: '2010',
        )
        form.application_qualifications.create(
          level: 'gcse',
          qualification_type: 'GCSE',
          subject: 'Hoot',
          institution_name: 'School of Owls',
          grade: 'A',
          award_year: '2005',
        )
      end

      degrees = CandidateInterface::DegreeForm.build_all_from_application(application_form)

      expect(degrees).to match_array([
        have_attributes(
          qualification_type: 'BA',
          subject: 'Ssss',
          institution_name: 'University of Snek',
          grade: 'third',
          award_year: '2010',
        ),
      ])
    end

    it 'returns grade and other grade if grade is not known' do
      application_form = create(:application_form) do |form|
        form.application_qualifications.create(
          level: 'degree',
          grade: 'Distinction',
        )
      end

      degree = CandidateInterface::DegreeForm.build_all_from_application(application_form)

      expect(degree.first).to have_attributes(grade: 'other', other_grade: 'Distinction')
    end

    it 'returns grade and predicted if predicted grade is true' do
      application_form = create(:application_form) do |form|
        form.application_qualifications.create(
          level: 'degree',
          grade: 'First',
          predicted_grade: true,
        )
      end

      degree = CandidateInterface::DegreeForm.build_all_from_application(application_form)

      expect(degree.first).to have_attributes(grade: 'predicted', predicted_grade: 'First')
    end
  end

  describe '.build_from_application' do
    it 'returns a new DegreeForm object using an application qualification' do
      application_qualification = build_stubbed(
        :application_qualification,
        level: 'degree',
        qualification_type: 'BA',
        subject: 'Meow',
      )

      degree = CandidateInterface::DegreeForm.build_from_qualification(application_qualification)

      expect(degree).to have_attributes(qualification_type: 'BA', subject: 'Meow')
    end

    it 'returns grade and other grade if grade is not known' do
      application_qualification = build_stubbed(
        :application_qualification,
        level: 'degree',
        grade: 'Distinction',
        predicted_grade: false,
      )

      degree = CandidateInterface::DegreeForm.build_from_qualification(application_qualification)

      expect(degree).to have_attributes(grade: 'other', other_grade: 'Distinction')
    end

    it 'returns grade and predicted if predicted grade is true' do
      application_qualification = build_stubbed(
        :application_qualification,
        level: 'degree',
        grade: 'First',
        predicted_grade: true,
      )

      degree = CandidateInterface::DegreeForm.build_from_qualification(application_qualification)

      expect(degree).to have_attributes(grade: 'predicted', predicted_grade: 'First')
    end
  end

  describe '#save_base' do
    it 'returns false if not valid' do
      degree = CandidateInterface::DegreeForm.new

      expect(degree.save_base(ApplicationForm.new)).to eq(false)
    end

    it 'saves a new degree on the provided ApplicationForm if valid' do
      application_form = create(:application_form)
      degree = CandidateInterface::DegreeForm.new(form_data)

      expect(degree.save_base(application_form)).to be_truthy
      expect(application_form.application_qualifications.degree.first)
        .to have_attributes(form_data)
    end
  end

  context 'updating degree form' do
    let(:application_form) { create(:application_form) }
    let(:existing_degree) do
      application_form.application_qualifications.create(
        level: 'degree',
        qualification_type: form_data[:qualification_type],
        subject: form_data[:subject],
        institution_name: form_data[:institution_name],
        grade: form_data[:grade],
        predicted_grade: false,
        award_year: form_data[:award_year],
      )
    end
    let(:degree) { CandidateInterface::DegreeForm.new(id: existing_degree.id) }

    describe '#update_base' do
      it 'returns false if not valid' do
        expect(degree.update_base(ApplicationForm.new)).to eq(false)
      end

      it 'updates the provided ApplicationForm if valid' do
        form_data[:qualification_type] = 'Masters'
        form_data[:subject] = 'Awoo'
        degree.assign_attributes(form_data)

        expect(degree.update_base(application_form)).to eq(true)
        expect(application_form.application_qualifications.degree.first)
          .to have_attributes(form_data)
      end
    end

    describe '#update_grade' do
      it 'updates grade for the provided ApplicationForm if other grade is given' do
        form_data[:grade] = 'other'
        form_data[:other_grade] = 'Distinction'
        degree.assign_attributes(form_data)

        expect(degree.update_grade(application_form)).to eq(true)
        expect(application_form.application_qualifications.degree.first)
          .to have_attributes(grade: 'Distinction')
      end

      it 'updates grade and predicted grade for the provided ApplicationForm if predicted grade is given' do
        form_data[:grade] = 'predicted'
        form_data[:predicted_grade] = 'First'
        degree.assign_attributes(form_data)

        expect(degree.update_grade(application_form)).to eq(true)
        expect(application_form.application_qualifications.degree.first)
          .to have_attributes(grade: 'First', predicted_grade: true)
      end
    end

    describe '#update_year' do
      it 'updates year for the provided ApplicationForm if other year is given' do
        form_data[:award_year] = '2000'
        degree.assign_attributes(form_data)

        expect(degree.update_year(application_form)).to eq(true)
        expect(application_form.application_qualifications.degree.first)
          .to have_attributes(award_year: '2000')
      end
    end
  end

  describe '#title' do
    it 'concatenates the qualification type and subject' do
      degree = CandidateInterface::DegreeForm.new(qualification_type: 'BA', subject: 'Doge')

      expect(degree.title).to eq('BA Doge')
    end
  end
end
