class WorkHistoryAndUnpaidExperienceComponent < WorkHistoryComponent
  def history
    @history ||= WorkHistoryWithBreaks.new(application_form, include_unpaid_experience: true).timeline
  end
end
