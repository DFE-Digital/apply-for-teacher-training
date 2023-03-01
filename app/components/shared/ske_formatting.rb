module SkeFormatting
  def ske_condition
    ske_conditions.first
  end

  def presenter(condition = nil)
    @presenter = SkeConditionPresenter.new(condition || ske_condition, interface: :candidate_interface)
  end
end
