module PreviewProviderHelper
  def unique_provider_code
    loop do
      length = rand(3..4)
      random_code = SecureRandom.alphanumeric(length)
      break random_code unless Provider.exists?(code: random_code)
    end
  end
end
