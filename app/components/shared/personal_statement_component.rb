# NOTE: This component is used by both provider and support UIs
class PersonalStatementComponent < ApplicationComponent
  include ViewHelper

  delegate :becoming_a_teacher,
           :further_information,
           to: :application_form

  def initialize(application_form:, editable: false)
    @application_form = application_form
    @editable = editable
  end

private

  attr_reader :application_form
end
