require 'rails_helper'

RSpec.describe Candidate, type: :model do
  subject { FactoryBot.create(:candidate) }

  it { is_expected.to validate_presence_of :email_address }
  it { is_expected.to validate_length_of(:email_address).is_at_most(250) }
  it { is_expected.to validate_uniqueness_of :email_address }

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
end
