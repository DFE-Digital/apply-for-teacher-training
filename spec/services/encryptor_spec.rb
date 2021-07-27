require 'rails_helper'

RSpec.describe Encryptor do
  it 'returns the original string when decrypting an encrypted string' do
    encrypted_data = described_class.encrypt('example')

    expect(described_class.decrypt(encrypted_data)).to eq('example')
  end

  it 'returns false given an invalid encrypted string' do
    expect(described_class.decrypt('invalid-input')).to be false
  end

  it 'returns false when the encrypted string fails verification' do
    encryptor_that_cannot_verify_the_message = double
    allow(encryptor_that_cannot_verify_the_message).to receive(:decrypt_and_verify)
      .and_raise(ActiveSupport::MessageVerifier::InvalidSignature.new)

    stub_const('Encryptor::ENCRYPTOR', encryptor_that_cannot_verify_the_message)

    expect(described_class.decrypt('any-old-thing')).to be false
  end
end
