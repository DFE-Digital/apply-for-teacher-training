require 'rails_helper'

RSpec.describe CandidateInterface::SignUpForm, type: :model do
  let(:new_email) { Faker::Internet.email }
  let(:existing_candidate) { create(:candidate) }
  let(:existing_email) { existing_candidate.email_address }

  def new_form(email:, accept_ts_and_cs:, course_id: nil)
    described_class.new(email_address: email, accept_ts_and_cs: accept_ts_and_cs, course_from_find_id: course_id)
  end

  describe '#save' do
    it 'returns true if it creates a new candidate' do
      form = new_form(email: new_email, accept_ts_and_cs: true)
      expect(form.existing_candidate?).to eq(false)
      expect(form.save).to eq(true)
      expect(form.existing_candidate?).to eq(true)
    end

    it 'returns false if :accept_ts_and_cs is not true' do
      form = new_form(email: new_email, accept_ts_and_cs: false)
      expect(form.existing_candidate?).to eq(false)
      expect(form.save).to eq(false)
      expect(form.existing_candidate?).to eq(false)
    end

    it 'returns false if candidate email_address validations fail' do
      form = new_form(email: 'foo', accept_ts_and_cs: true)
      expect(form.existing_candidate?).to eq(false)
      expect(form.save).to eq(false)
      expect(form.errors[:email_address]).not_to be_empty
    end

    it 'returns false if candidate attempts to use a non-DfE email address on a test environment' do
      ClimateControl.modify HOSTING_ENVIRONMENT_NAME: 'qa' do
        form = new_form(email: 'alice@example.com', accept_ts_and_cs: true)
        expect(form.existing_candidate?).to eq(false)
        expect(form.save).to eq(false)
        expect(form.errors[:email_address]).not_to be_empty
      end
    end

    it 'returns false if email_address belongs to existing candidate' do
      form = new_form(email: existing_email, accept_ts_and_cs: true)
      expect(form.existing_candidate?).to eq(true)
      expect(form.save).to eq(false)
    end

    it 'returns false if email_address is upcased version of one that exists' do
      form = new_form(email: existing_email.upcase, accept_ts_and_cs: true)
      expect(form.existing_candidate?).to eq(true)
      expect(form.save).to eq(false)
    end

    it 'returns true if course_from_find_id if a value is given for course_from_find_id' do
      form = new_form(email: new_email, accept_ts_and_cs: true, course_id: 12)
      expect(form.save).to eq(true)
      expect(form.course_from_find_id).to eq(12)
    end

    it 'includes an event tag for BigQuery' do
      form = new_form(email: new_email, accept_ts_and_cs: true)

      form.save

      expect(SendEventsToBigquery).to have_received(:perform_async)
        .with(a_hash_including({ 'event_tags' => ['candidate_sign_up'] }))
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:accept_ts_and_cs) }
    it { is_expected.to validate_presence_of(:email_address) }
    it { is_expected.to validate_length_of(:email_address).is_at_most(100) }
  end
end
