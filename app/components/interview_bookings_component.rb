# frozen_string_literal: true

class InterviewBookingsComponent < ViewComponent::Base
  attr_accessor :interview

  def initialize(application_choice)
    @application_choice = application_choice
  end

  def interviews
    @application_choice.interviews.includes(:provider).order(date_and_time: :asc)
  end
end
