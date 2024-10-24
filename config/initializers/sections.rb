Rails.application.configure do
  config.x.sections.editable = %i[
    personal_details
    contact_details
    training_with_a_disability
    interview_preferences
    equality_and_diversity
    becoming_a_teacher
    science_gcse
    efl
    work_history
    volunteering
  ]
  config.x.sections.editable_window_days = 5
end
