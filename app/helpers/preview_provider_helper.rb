module PreviewProviderHelper
  def unique_provider_code
    loop do
      length = rand(3..4)
      random_code = SecureRandom.alphanumeric(length)
      break unless Provider.exists?(code: random_code)
    end
    random_code
  end
end
