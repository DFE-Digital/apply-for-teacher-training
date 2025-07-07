RSpec.configure do |config|
  config.before(type: :system) do
    uri = URI.join(I18n.t('find_teacher_training.production_url'), 'results')
    stub_request(:get, uri)
      .with(query: hash_including({}))
      .to_return(body: nil)
  end
end
