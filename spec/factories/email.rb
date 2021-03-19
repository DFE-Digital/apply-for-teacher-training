FactoryBot.define do
  factory :email do
    application_form

    to { 'me@example.com' }
    subject { 'Test email' }
    mailer { 'ActionMailer' }
    mail_template { 'some_mail_template' }
    body { 'Hi' }
  end
end
