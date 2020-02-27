class PaginatorComponent < ActionView::Component::Base
  attr_reader :scope

  def initialize(scope:)
    @scope = scope
  end

  def render?
    FeatureFlag.active?('provider_interface_pagination') && @scope.total_pages > 1
  end

  def page_start
    ((@scope.current_page - 1) * @scope.limit_value) + 1
  end

  def page_end
    [
      @scope.current_page * @scope.limit_value,
      total,
    ].min
  end

  def total
    @scope.total_count
  end
end
