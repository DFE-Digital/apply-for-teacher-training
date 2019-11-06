require 'rails_helper'

RSpec.describe CandidateInterface::OtherQualificationForm, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:qualification_type) }
    it { is_expected.to validate_presence_of(:subject) }
    it { is_expected.to validate_presence_of(:institution_name) }
    it { is_expected.to validate_presence_of(:grade) }
    it { is_expected.to validate_presence_of(:award_year) }

    it { is_expected.to validate_length_of(:qualification_type).is_at_most(255) }
    it { is_expected.to validate_length_of(:subject).is_at_most(255) }
    it { is_expected.to validate_length_of(:institution_name).is_at_most(255) }
    it { is_expected.to validate_length_of(:grade).is_at_most(255) }

    describe 'award year' do
      ['a year', '200'].each do |invalid_date|
        it "is invalid if the award year is '#{invalid_date}'" do
          qualification = CandidateInterface::OtherQualificationForm.new(award_year: invalid_date)
          error_message = t('activemodel.errors.models.candidate_interface/other_qualification_form.attributes.award_year.invalid')

          qualification.validate

          expect(qualification.errors.full_messages_for(:award_year)).to eq(
            ["Award year #{error_message}"],
          )
        end
      end

      it 'is valid if the award year is 4 digits' do
        qualification = CandidateInterface::OtherQualificationForm.new(award_year: '2009')

        qualification.validate

        expect(qualification.errors.full_messages_for(:award_year)).to be_empty
      end

      it 'is invalid if the award year is before the current year' do
        Timecop.freeze(Time.zone.local(2019, 10, 1, 12, 0, 0)) do
          qualification = CandidateInterface::OtherQualificationForm.new(award_year: '2029')
          error_message = t('activemodel.errors.models.candidate_interface/other_qualification_form.attributes.award_year.in_the_future')

          qualification.validate

          expect(qualification.errors.full_messages_for(:award_year)).to eq(
            ["Award year #{error_message}"],
          )
        end
      end
    end
  end

  describe '#save' do
    it 'returns false if not valid' do
      qualification = CandidateInterface::OtherQualificationForm.new

      expect(qualification.save(ApplicationForm.new)).to eq(false)
    end

    it 'saves the provided ApplicationForm if valid' do
      form_data = {
        qualification_type: 'BTEC',
        subject: 'Being a Superhero',
        institution_name: 'School of Heroes',
        grade: 'Distinction',
        award_year: '2012',
      }
      application_form = create(:application_form)
      qualification = CandidateInterface::OtherQualificationForm.new(form_data)

      expect(qualification.save(application_form)).to eq(true)
      expect(application_form.application_qualifications.other.first)
        .to have_attributes(form_data)
    end
  end
end
