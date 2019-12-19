class TaskListItemComponent < ActionView::Component::Base
  include ViewHelper

  validates :path, presence: true

  def initialize(completed:, path:, text:, show_incomplete: true, submitted: false)
    @completed = completed
    @path = path
    @text = text
    @show_incomplete = show_incomplete
    @submitted = submitted
  end

  def tag_id
    "#{@text.parameterize}-badge-id"
  end

private

  attr_reader :completed, :path, :text, :show_incomplete, :submitted
end
