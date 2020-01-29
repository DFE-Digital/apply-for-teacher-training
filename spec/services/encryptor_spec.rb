require 'rails_helper'

RSpec.describe Encryptor do
  it 'returns the original string when decrypting an encrypted string' do
    encrypted_data = Encryptor.encrypt('example')

    expect(Encryptor.decrypt(encrypted_data)).to eq('example')
  end
end
