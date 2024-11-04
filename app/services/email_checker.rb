class EmailChecker
  def initialize(email_address)
    @email_address = email_address
  end

  def personal?
    domain_name.in? ::PERSONAL_EMAIL_ADDRESS_DOMAINS
  end

private

  def domain_name
    @email_address.split('@').last
  end
end
