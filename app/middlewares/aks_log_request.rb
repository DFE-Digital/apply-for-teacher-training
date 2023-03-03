class AksLogRequest
  def initialize(app)
    @app = app
  end

  def call(env)
    Rails.logger.info('*' * 80)
    Rails.logger.info('AKS info')
    env.keys.sort.each do |key|
      Rails.logger.info("#{key} = #{env[key]}")
    end
    Rails.logger.info('*' * 80)
    @app.call(env)
  end
end
