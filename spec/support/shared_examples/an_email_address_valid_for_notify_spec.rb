RSpec.shared_examples 'an email address valid for notify' do |field_name = :email_address|
  [
    # Standard email addresses
    'user@example.com',                              # Standard format
    'user123@example.com',                           # With numbers in local part
    'user.name@example.com',                         # With period in local part
    'user_name@example.com',                         # With underscore in local part
    'user+tag@example.com',                          # With plus symbol in local part
    'user-tag@example.com',                          # With hyphen in local part
    'user@hotmail.co.uk',
    'user@yahoo.co.uk',
    'user@myportabledomain.ab.uk',

    # Email addresses with subdomains
    'user123@subdomain.example.com',                 # With subdomain and numbers in local part
    'user.name@sub-domain.example.com',              # With subdomain and period in local part
    'user+tag@subdomain.example.com',                # With subdomain and plus symbol in local part
    'user-tag@subdomain.example.com',                # With subdomain and hyphen in local part
    'john_doe@sales.example.com',                    # With nested subdomains

    # International local part
    '阿里巴巴@example.com', # Chinese
    'サンプル@example.com', # Japanese

    # Email addresses with Internationalized Domain Names (IDNs)
    'user@xn--bcher-kva.example.com',               # With IDN (contains special characters)
    'user@xn--5hx875a.example.com',                 # With IDN (contains Chinese characters)
    'user@sub.xn--bcher-kva.example.com',           # With subdomain and IDN
    'user@sub.xn--5hx875a.example.com',             # With subdomain and IDN

    # Email address with different TLD
    'user@example.co.uk', # With UK TLD

    'user.name+tag!@domain.com',        # Special characters in the local part
    'user@sub.domain.co.uk',            # Multiple subdomains
    'user@example.com',                 # Email address with a single subdomain
    'user.name123@example.com',         # Alphanumeric characters and periods in the local part
    'user@domain.co.uk',                # Email address with a standard TLD
  ].each do |valid_email_address|
    it "validate valid email address like '#{valid_email_address}'" do
      expect(subject).to allow_value(valid_email_address).for(field_name)
    end
  end

  [
    'user@example.com1111111',      # Invalid
    'user@-example.com',            # Hyphen at the beginning of the domain
    'user@example-.com',            # Hyphen at the end of the domain
    'user@[192.168.1.1]',           # IP address in square brackets
    'user@[IPv6:2001:db8::1]',      # IPv6 address in square brackets
    'user@example..com',            # Double dots in the domain part
    'user@example.c',               # TLD shorter than 2 characters
    'user@sub_domain-.example.com', # Hyphen at the end of the subdomain
    'user@sub_domain.-example.com', # Dot at the end of the subdomain
    'user.@example.com',            # Dot at the end of the local part
    'user..name@example.com',       # Consecutive dots in the local part
    'user@-example.com',            # Hyphen at the beginning of the domain
    'user@example-.com',            # Hyphen at the end of the domain
    'user@[192.168.1.1]',           # IP address in square brackets
    'user@[IPv6:2001:db8::1]', # IPv6 address in square brackets
    'user@example..com', # Double dots in the domain part
    'user@example.c', # TLD shorter than 2 characters
    'user@sub_domain-.example.com', # Hyphen at the end of the subdomain
    'user@sub_domain.-example.com', # Dot at the end of the subdomain
    'user@sub_domain-.example.com', # Hyphen at the end of the subdomain
    'user@sub_domain.-example.com', # Dot at the end of the subdomain
  ].each do |invalid_email_address|
    it "validate invalid email address like '#{invalid_email_address}'" do
      expect(subject).not_to allow_value(invalid_email_address).for(field_name)
    end
  end
end
