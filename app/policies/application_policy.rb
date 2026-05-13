class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    false
  end

  def show?
    false
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

private

  def current_application
    if user_is_a_candidate?
      @current_application ||= user.current_application
    end
  end

  def active_previous_application
    if user_is_a_candidate?
      @active_previous_application ||= user.active_previous_application
    end
  end

  def active_application_choices
    if user_is_a_candidate?
      @active_application_choices ||= user.active_application_choices
    end
  end

  def user_is_a_candidate?
    @user_is_a_candidate ||= user.is_a?(Candidate)
  end

  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def current_application
      if user.is_a?(Candidate)
        @current_application ||= user.current_application
      end
    end

    def resolve
      raise NoMethodError, "You must define #resolve in #{self.class}"
    end

  private

    attr_reader :user, :scope
  end
end
