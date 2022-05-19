require 'rails_helper'

RSpec.describe CandidateInterface::SignUpForm, type: :model do
  let(:new_email) { Faker::Internet.email }
  let(:existing_candidate) { create(:candidate) }
  let(:existing_email) { existing_candidate.email_address }

  def new_form(email:, course_id: nil)
    described_class.new(email_address: email, course_from_find_id: course_id)
  end

  describe '#save' do
    it 'returns true if it creates a new candidate' do
      form = new_form(email: new_email)
      expect(form.existing_candidate?).to be(false)
      expect(form.save).to be(true)
      expect(form.existing_candidate?).to be(true)
    end

    it 'returns false if candidate email_address validations fail' do
      form = new_form(email: 'foo')
      expect(form.existing_candidate?).to be(false)
      expect(form.save).to be(false)
      expect(form.errors[:email_address]).not_to be_empty
    end

    it 'returns false if candidate attempts to use a non-DfE email address on a test environment' do
      ClimateControl.modify HOSTING_ENVIRONMENT_NAME: 'qa' do
        form = new_form(email: 'alice@example.com')
        expect(form.existing_candidate?).to be(false)
        expect(form.save).to be(false)
        expect(form.errors[:email_address]).not_to be_empty
      end
    end

    it 'returns false if email_address belongs to existing candidate' do
      form = new_form(email: existing_email)
      expect(form.existing_candidate?).to be(true)
      expect(form.save).to be(false)
    end

    it 'returns false if email_address is upcased version of one that exists' do
      form = new_form(email: existing_email.upcase)
      expect(form.existing_candidate?).to be(true)
      expect(form.save).to be(false)
    end

    it 'returns true if course_from_find_id if a value is given for course_from_find_id' do
      form = new_form(email: new_email, course_id: 12)
      expect(form.save).to be(true)
      expect(form.course_from_find_id).to eq(12)
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:email_address) }
    it { is_expected.to validate_length_of(:email_address).is_at_most(100) }
  end
end
