RSpec.shared_examples 'a mail with subject and content' do |email_subject, content|
  it "sends an email with the correct subject and #{content.keys.to_sentence} in the body" do
    expect(email.subject).to include(email_subject)

    content.each do |_, expectation|
      if expectation.is_a?(Regexp)
        expect(email.body).to match(expectation)
      else
        expectation = expectation.call if expectation.respond_to?(:call)
        expect(email.body).to include(expectation)
      end
    end
  end
end
