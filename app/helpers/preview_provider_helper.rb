module PreviewProviderHelper
  def unique_provider_code
    begin
      length = rand(3..4)
      random_code = SecureRandom.alphanumeric(length)
    end while Provider.exists?(code: random_code)
    random_code
  end
end
