class TaskListItemComponent < ViewComponent::Base
  include ViewHelper

  def initialize(
    completed:,
    path:,
    text:,
    show_incomplete: true,
    submitted: false,
    custom_status: nil
  )
    @completed = completed
    @path = path
    @text = text
    @show_incomplete = show_incomplete
    @submitted = submitted
    @custom_status = custom_status
  end

  def tag_id
    "#{@text.parameterize}-badge-id"
  end

private

  attr_reader :completed, :path, :text, :show_incomplete, :submitted, :custom_status
end
