class TaskListItemComponent < ViewComponent::Base
  include ViewHelper

  def initialize(
    completed:,
    text:, path: nil,
    show_incomplete: true,
    custom_status: nil,
    custom_color: nil
  )
    @completed = completed
    @path = path
    @text = text
    @show_incomplete = show_incomplete
    @custom_status = custom_status
    @custom_color = custom_color
  end

  def tag_id
    "#{@text.parameterize}-badge-id"
  end

private

  attr_reader :completed, :path, :text, :show_incomplete, :custom_status, :custom_color
end
