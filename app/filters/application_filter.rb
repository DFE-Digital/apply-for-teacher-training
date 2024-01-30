class ApplicationFilter
  attr_reader :controller

  def self.before(controller)
    new(controller).call
  end

  delegate :current_application,
           :redirect_to,
           to: :controller

  def initialize(controller)
    @controller = controller
  end
end
