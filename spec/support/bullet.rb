module SetupBullet
  def self.call
    require 'bullet'
    return if Bullet.enable?

    Bullet.enable = true
    Bullet.unused_eager_loading_enable = false
    Bullet.counter_cache_enable = false
    Bullet.add_safelist type: :n_plus_one_query, class_name: 'Audited::Audit', association: :user
    Bullet.raise = true # raise an error if n+1 query occurs

    RSpec.configure do |config|
      config.before do
        Bullet.start_request
      end

      config.after do
        Bullet.end_request
      end
    end
  end
end

if ENV.fetch('BULLET', 'true') == 'true'
  SetupBullet.call
end
