class CandidateMailerPreview < ActionMailer::Preview
  def submit_application_email
    CandidateMailer.submit_application_email(to: "#{SecureRandom.hex}@example.com", support_reference: 'APPLICATION-REF')
  end
end
