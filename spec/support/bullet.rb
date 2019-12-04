RSpec.configure do |config|
  if Bullet.enable?
    config.before do
      Bullet.start_request
    end

    config.after do
      Bullet.end_request
    end
  end
end
