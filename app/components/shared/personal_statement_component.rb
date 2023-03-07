# NOTE: This component is used by both provider and support UIs
class PersonalStatementComponent < ViewComponent::Base
  include ViewHelper

  delegate :becoming_a_teacher,
           :subject_knowledge,
           :further_information,
           to: :application_form

  def initialize(application_form:, editable: false)
    @application_form = application_form
    @editable = editable
  end

private

  def header
    FeatureFlag.active?(:one_personal_statement) && application_form.single_personal_statement? ? I18n.t('page_titles.personal_statement') : I18n.t('personal_statement.vocation')
  end

  attr_reader :application_form
end
