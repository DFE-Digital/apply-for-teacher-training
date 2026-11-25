class PreviousTeacherTraining::StartedDeclarationComponent < ApplicationComponent
  include ViewHelper

  attr_reader :application_form, :actions, :current_user

  def initialize(application_form:, current_user:, actions: false)
    @application_form = application_form
    @current_user = current_user
    @actions = actions
  end

  def rows
    [
      {
        key: { text: I18n.t('previous_teacher_training.started_declaration_component.started_teacher_training') },
        value: { text: published_previous_teacher_training.started.capitalize },
      }.merge(change_action),
    ]
  end

  def render?
    published_previous_teacher_training.present?
  end

private

  def change_action
    return {} unless actions

    {
      actions: [{
        text: I18n.t('previous_teacher_training.started_declaration_component.change'),
        href: change_link,
        classes: 'govuk-link--no-visited-state',
        visually_hidden_text: I18n.t('previous_teacher_training.started_declaration_component.change_started_teacher_training'),
      }],
    }
  end

  def change_link
    if current_user.is_a?(SupportUser)
      support_interface_application_form_edit_declaration_previous_teacher_trainings_path(
        application_form,
        published_previous_teacher_training,
      )
    else
      edit_candidate_interface_previous_teacher_trainings_path(
        published_previous_teacher_training,
        return_to: 'review',
      )
    end
  end

  def started?
    previous_teacher_trainings.any?
  end

  def previous_teacher_trainings
    @previous_teacher_training ||= @application_form.previous_teacher_trainings.published.started_yes
  end

  def published_previous_teacher_training
    @published_previous_teacher_training ||= @application_form.published_previous_teacher_trainings.sample
  end
end
