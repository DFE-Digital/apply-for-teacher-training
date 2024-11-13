RSpec.shared_examples 'a mail with subject and content' do |email_subject, content|
  it "sends an email with the correct subject and #{content.keys.to_sentence} in the body" do
    expect(email.subject).to eq(email_subject)

    content.each_value do |expectation|
      if expectation.is_a?(Regexp)
        expect(email.body).to match(expectation)
      else
        expectation = expectation.call if expectation.respond_to?(:call)
        expect(email.body).to include(expectation)
      end
    end
  end
end

RSpec.shared_examples 'an email with unsubscribe option' do
  it 'has the unsubscribe link' do
    expect(email.body).to have_content 'You will still receive essential updates about your application. You cannot undo this.'
    expect(email.body).to have_content 'Unsubscribe from reminder emails like this'
    expect(email.body).to have_content 'http://localhost:3000/candidate/unsubscribe-from-emails/'
  end
end
