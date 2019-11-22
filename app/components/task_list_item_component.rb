class TaskListItemComponent < ActionView::Component::Base
  include ViewHelper

  validates :path, presence: true

  def initialize(completed:, path:, text:, show_incomplete: true)
    @completed = completed
    @path = path
    @text = text
    @show_incomplete = show_incomplete
  end

  def tag_id
    "#{@text.parameterize}-badge-id"
  end

private

  attr_reader :completed, :path, :text, :show_incomplete
end
