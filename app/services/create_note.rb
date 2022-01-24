class CreateNote
  include ActiveModel::Model
  attr_accessor :application_choice, :message, :referer, :user
  attr_reader :note

  delegate :errors, :save!, :valid?, to: :note

  def initialize(attrs = {})
    super(attrs)

    @note = Note.new(
      application_choice: application_choice,
      user: user,
      message: message,
    )
  end
end
