class SubmitApplication
  attr_reader :application_choices

  def initialize(application_choices)
    @application_choices = application_choices
  end

  def call
    ActiveRecord::Base.transaction do
      application_choices.each do |application_choice|
        ApplicationStateChange.new(application_choice).submit!
      end
    end

    # TODO: send the email "Thank you for completing your teacher training application"
  end
end
