require 'rails_helper'

RSpec.describe TTApplicationMailer, type: :mailer do
  subject(:mailer) { described_class }

  describe 'send_application' do
    it 'can send an email that contains the candidate email' do
      candidate_email = 'candidate@teaching.com'
      mail = mailer.send_application(to: 'test@example.com', candidate_email: candidate_email).deliver!
      expect(mail.body.encoded).to include(candidate_email)
    end
  end
end
