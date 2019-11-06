require 'rails_helper'

RSpec.describe CandidateInterface::DegreesForm, type: :model do
  let(:form_data) do
    {
      qualification_type: 'BA',
      subject: 'Doge',
      institution_name: 'University of Much Wow',
      grade: 'first',
      award_year: '2008',
    }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:qualification_type) }
    it { is_expected.to validate_presence_of(:subject) }
    it { is_expected.to validate_presence_of(:institution_name) }
    it { is_expected.to validate_presence_of(:grade) }
    it { is_expected.to validate_presence_of(:award_year) }

    it "validates presence of `other_grade` if chosen grade is 'other'" do
      degrees_form = CandidateInterface::DegreesForm.new(grade: 'other')
      error_message = t('activemodel.errors.models.candidate_interface/degrees_form.attributes.other_grade.blank')

      degrees_form.validate

      expect(degrees_form.errors.full_messages_for(:other_grade)).to eq(
        ["Other grade #{error_message}"],
      )
    end

    it "validates presence of `predicted_grade` if chosen grade is 'predicted'" do
      degrees_form = CandidateInterface::DegreesForm.new(grade: 'predicted')
      error_message = t('activemodel.errors.models.candidate_interface/degrees_form.attributes.predicted_grade.blank')

      degrees_form.validate

      expect(degrees_form.errors.full_messages_for(:predicted_grade)).to eq(
        ["Predicted grade #{error_message}"],
      )
    end

    it { is_expected.to validate_length_of(:qualification_type).is_at_most(255) }
    it { is_expected.to validate_length_of(:subject).is_at_most(255) }
    it { is_expected.to validate_length_of(:institution_name).is_at_most(255) }
    it { is_expected.to validate_length_of(:grade).is_at_most(255) }
    it { is_expected.to validate_length_of(:other_grade).is_at_most(255) }
    it { is_expected.to validate_length_of(:predicted_grade).is_at_most(255) }

    describe 'award year' do
      ['a year', '200'].each do |invalid_date|
        it "is invalid if the award year is '#{invalid_date}'" do
          degrees_form = CandidateInterface::DegreesForm.new(award_year: invalid_date)
          error_message = t('activemodel.errors.models.candidate_interface/degrees_form.attributes.award_year.invalid')

          degrees_form.validate

          expect(degrees_form.errors.full_messages_for(:award_year)).to eq(
            ["Award year #{error_message}"],
          )
        end
      end

      it 'is valid if the award year is 4 digits' do
        degrees_form = CandidateInterface::DegreesForm.new(award_year: '2009')
        error_message = t('activemodel.errors.models.candidate_interface/degrees_form.attributes.award_year.invalid')

        degrees_form.validate

        expect(degrees_form.errors.full_messages_for(:award_year)).not_to eq(
          ["Award year #{error_message}"],
        )
      end
    end
  end

  describe '.build_all_from_application' do
    it 'creates an array of objects based on the provided ApplicationForm' do
      application_form = create(:application_form) do |form|
        form.application_qualifications.create(
          id: 1,
          level: 'degree',
          qualification_type: 'BA',
          subject: 'Woof',
          institution_name: 'University of Doge',
          grade: 'first',
          predicted_grade: false,
          award_year: '2008',
        )
        form.application_qualifications.create(
          id: 2,
          level: 'degree',
          qualification_type: 'BA',
          subject: 'Meow',
          institution_name: 'University of Cate',
          grade: 'upper_second',
          predicted_grade: true,
          award_year: '2010',
        )
      end

      degrees = CandidateInterface::DegreesForm.build_all_from_application(application_form)

      expect(degrees).to match_array([
        have_attributes(
          id: 1,
          qualification_type: 'BA',
          subject: 'Woof',
          institution_name: 'University of Doge',
          grade: 'first',
          award_year: '2008',
        ),
        have_attributes(
          id: 2,
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

      degrees = CandidateInterface::DegreesForm.build_all_from_application(application_form)

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
          id: 1,
          level: 'degree',
          grade: 'Distinction',
        )
      end

      degree = CandidateInterface::DegreesForm.build_all_from_application(application_form)

      expect(degree.first).to have_attributes(grade: 'other', other_grade: 'Distinction')
    end

    it 'returns grade and predicted if predicted grade is true' do
      application_form = create(:application_form) do |form|
        form.application_qualifications.create(
          id: 1,
          level: 'degree',
          grade: 'First',
          predicted_grade: true,
        )
      end

      degree = CandidateInterface::DegreesForm.build_all_from_application(application_form)

      expect(degree.first).to have_attributes(grade: 'predicted', predicted_grade: 'First')
    end
  end

  describe '.build_from_application' do
    it 'returns a new DegreesForm object using the id' do
      application_form = create(:application_form) do |form|
        form.application_qualifications.create(
          id: 1,
          level: 'degree',
          qualification_type: 'BA',
          subject: 'Woof',
        )
        form.application_qualifications.create(
          id: 2,
          level: 'degree',
          qualification_type: 'BA',
          subject: 'Meow',
        )
      end

      degree = CandidateInterface::DegreesForm.build_from_application(application_form, 2)

      expect(degree).to have_attributes(qualification_type: 'BA', subject: 'Meow')
    end

    it 'returns grade and other grade if grade is not known' do
      application_form = create(:application_form) do |form|
        form.application_qualifications.create(
          id: 1,
          level: 'degree',
          grade: 'Distinction',
        )
      end

      degree = CandidateInterface::DegreesForm.build_from_application(application_form, 1)

      expect(degree).to have_attributes(grade: 'other', other_grade: 'Distinction')
    end

    it 'returns grade and predicted if predicted grade is true' do
      application_form = create(:application_form) do |form|
        form.application_qualifications.create(
          id: 1,
          level: 'degree',
          grade: 'First',
          predicted_grade: true,
        )
      end

      degree = CandidateInterface::DegreesForm.build_from_application(application_form, 1)

      expect(degree).to have_attributes(grade: 'predicted', predicted_grade: 'First')
    end
  end

  describe '#save' do
    it 'returns false if not valid' do
      degree = CandidateInterface::DegreesForm.new

      expect(degree.save(ApplicationForm.new)).to eq(false)
    end

    it 'saves the provided ApplicationForm if valid' do
      application_form = create(:application_form)
      degree = CandidateInterface::DegreesForm.new(form_data)

      expect(degree.save(application_form)).to eq(true)
      expect(application_form.application_qualifications.degree.first)
        .to have_attributes(form_data)
    end

    it 'saves grade for the provided ApplicationForm if other grade is given' do
      form_data[:grade] = 'other'
      form_data[:other_grade] = 'Distinction'
      application_form = create(:application_form)
      degree = CandidateInterface::DegreesForm.new(form_data)

      expect(degree.save(application_form)).to eq(true)
      expect(application_form.application_qualifications.degree.first)
        .to have_attributes(grade: 'Distinction')
    end

    it 'saves grade and predicted grade for the provided ApplicationForm if predicted grade is given' do
      form_data[:grade] = 'predicted'
      form_data[:predicted_grade] = 'First'
      application_form = create(:application_form)
      degree = CandidateInterface::DegreesForm.new(form_data)

      expect(degree.save(application_form)).to eq(true)
      expect(application_form.application_qualifications.degree.first)
        .to have_attributes(grade: 'First', predicted_grade: true)
    end
  end

  describe '#update' do
    let(:application_form) do
      create(:application_form) do |form|
        form.application_qualifications.create(
          id: 1,
          level: 'degree',
          qualification_type: form_data[:qualification_type],
          subject: form_data[:subject],
          institution_name: form_data[:institution_name],
          grade: form_data[:grade],
          predicted_grade: false,
          award_year: form_data[:award_year],
        )
      end
    end

    it 'returns false if not valid' do
      degree = CandidateInterface::DegreesForm.new

      expect(degree.update(ApplicationForm.new, 1)).to eq(false)
    end

    it 'updates the provided ApplicationForm if valid' do
      form_data[:qualification_type] = 'Masters'
      form_data[:subject] = 'Awoo'
      degree = CandidateInterface::DegreesForm.new(form_data)

      expect(degree.update(application_form, 1)).to eq(true)
      expect(application_form.application_qualifications.degree.first)
        .to have_attributes(form_data)
    end

    it 'updates grade for the provided ApplicationForm if other grade is given' do
      form_data[:grade] = 'other'
      form_data[:other_grade] = 'Distinction'
      degree = CandidateInterface::DegreesForm.new(form_data)

      expect(degree.update(application_form, 1)).to eq(true)
      expect(application_form.application_qualifications.degree.first)
        .to have_attributes(grade: 'Distinction')
    end

    it 'updates grade and predicted grade for the provided ApplicationForm if predicted grade is given' do
      form_data[:grade] = 'predicted'
      form_data[:predicted_grade] = 'First'
      degree = CandidateInterface::DegreesForm.new(form_data)

      expect(degree.update(application_form, 1)).to eq(true)
      expect(application_form.application_qualifications.degree.first)
        .to have_attributes(grade: 'First', predicted_grade: true)
    end
  end

  describe '#title' do
    it 'concatenates the qualification type and subject' do
      degree = CandidateInterface::DegreesForm.new(qualification_type: 'BA', subject: 'Doge')

      expect(degree.title).to eq('BA Doge')
    end
  end
end
