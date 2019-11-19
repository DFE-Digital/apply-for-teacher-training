class TaskListItemComponent < ActionView::Component::Base
  include ViewHelper

  validates :path, presence: true

  def initialize(completed:, path:, text:)
    @completed = completed
    @path = path
    @text = text
  end

  def tag_id
    "#{@text.parameterize}-badge-id"
  end

private

  attr_reader :completed, :path, :text
end
