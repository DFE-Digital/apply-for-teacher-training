require 'rails_helper'

RSpec.describe CandidateInterface::DegreesForm, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:qualification_type) }
    it { is_expected.to validate_presence_of(:subject) }
    it { is_expected.to validate_presence_of(:institution_name) }

    it { is_expected.to validate_length_of(:qualification_type).is_at_most(255) }
    it { is_expected.to validate_length_of(:subject).is_at_most(255) }
    it { is_expected.to validate_length_of(:institution_name).is_at_most(255) }
  end

  describe '#save_base' do
    it 'returns false if not valid' do
      degree = CandidateInterface::DegreesForm.new

      expect(degree.save_base(ApplicationForm.new)).to eq(false)
    end

    it 'updates the provided ApplicationForm if valid' do
      form_data = {
        qualification_type: 'BA',
        subject: 'maths',
        institution_name: 'University of Much Wow',
      }
      application_form = create(:application_form)
      degree = CandidateInterface::DegreesForm.new(form_data)

      expect(degree.save_base(application_form)).to eq(true)
      expect(application_form.application_qualifications.degree.first)
        .to have_attributes(form_data)
    end
  end
end
