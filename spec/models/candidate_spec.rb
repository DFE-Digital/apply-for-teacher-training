require 'rails_helper'

RSpec.describe Candidate, type: :model do
  subject { FactoryBot.create(:candidate) }

  describe 'a valid candidate' do
    it { is_expected.to validate_presence_of :email_address }
    it { is_expected.to validate_length_of(:email_address).is_at_most(250) }
    it { is_expected.to validate_uniqueness_of :email_address }

    it { is_expected.to allow_value('candidate@example.com').for(:email_address) }
    it { is_expected.not_to allow_value('candidate.com').for(:email_address) }
  end

  describe '#delete' do
    it 'deletes all dependent records through cascading deletes in the database' do
      candidate = FactoryBot.create(:candidate)
      application_form = FactoryBot.create(:application_form, candidate: candidate)
      application_choice = FactoryBot.create(:application_choice, application_form: application_form)

      candidate.delete

      expect { candidate.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect { application_form.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect { application_choice.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe '#current_application' do
    it 'returns an existing application' do
      candidate = FactoryBot.create(:candidate)
      application_form = FactoryBot.create(:application_form, candidate: candidate)

      expect(candidate.current_application).to eq(application_form)
    end

    it 'creates an application if there are none' do
      candidate = FactoryBot.create(:candidate)

      expect { candidate.current_application }.to change { candidate.application_forms.count }.from(0).to(1)
    end
  end
end
