class CreateNote
  attr_accessor :application_choice, :message, :user
  delegate :errors, :valid?, to: :note

  def initialize(user:, application_choice:, message:)
    @application_choice = application_choice
    @message = message
    @user = user
  end

  def save!
    if note.valid?
      note.save
    else
      raise ValidationException, note.errors.map(&:message)
    end
  end

private

  def note
    @note ||= Note.new(application_choice:, user:, message:)
  end
end
