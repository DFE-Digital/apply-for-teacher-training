class Encryptor
  ENCRYPTOR = ActiveSupport::MessageEncryptor.new(Rails.application.secret_key_base[0..31])

  def self.encrypt(text)
    ENCRYPTOR.encrypt_and_sign(text)
  end

  def self.decrypt(text)
    ENCRYPTOR.decrypt_and_verify(text)
  end
end
