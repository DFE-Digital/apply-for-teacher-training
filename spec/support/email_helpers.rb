module EmailHelpers
  def last_email
    expect(ActionMailer::Base.deliveries).not_to be_empty
    ActionMailer::Base.deliveries.last
  end

  def email_with_subject(subject, recipient: nil)
    expect(ActionMailer::Base.deliveries).not_to be_empty
    ActionMailer::Base.deliveries.find do |email|
      next if recipient && email.to.exclude?(recipient)

      email.subject == subject
    end
  end

  def extract_links_from_email(email)
    if html_email?(email)
      html_part(email).to_s.scan(/href="(.*?)"/).flatten
    else
      email.body.to_s.scan(/(https?:\/\/[^\s]+)/).flatten
    end
  end

  def html_email?(email)
    email.multipart? || email.mime_type == 'text/html'
  end

  def html_part(email)
    if email.multipart?
      email.html_part
    elsif email.mime_type == 'text/html'
      email.body
    else
      raise 'Email is not multipart and has no HTML part'
    end
  end

  def find_link(email, regex)
    extract_links_from_email(email).find do |link|
      link.match(regex)
    end
  end

  def find_email_with_link(regex)
    ActionMailer::Base.deliveries.find do |email|
      find_link(email, regex)
    end
  end
end

RSpec.configure do |config|
  config.include EmailHelpers
end
