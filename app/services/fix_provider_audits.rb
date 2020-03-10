class FixProviderAudits
  def initialize
    @provider_users = {}
  end

  def call
    Audited::Audit.where("username like '%(Provider)'").find_each do |audit|
      email_address = email_address_from(audit)
      provider_user = find_provider_user_by(email_address)
      audit.update(user: provider_user) if provider_user
    end
  end

private

  def find_provider_user_by(email_address)
    @provider_users[email_address] ||= ProviderUser.find_by(email_address: email_address)
    @provider_users[email_address]
  end

  def email_address_from(audit)
    match = audit.username.match(/(^.*) \(Provider\)/)
    match[1] if match
  end
end
