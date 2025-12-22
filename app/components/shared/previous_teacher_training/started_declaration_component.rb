class PreviousTeacherTraining::StartedDeclarationComponent < ViewComponent::Base
  include ViewHelper

  attr_reader :application_form, :actions

  def initialize(application_form:, actions: false)
    @application_form = application_form
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
        href: edit_candidate_interface_previous_teacher_trainings_path(
          published_previous_teacher_training,
          return_to: 'review',
        ),
        classes: 'govuk-link--no-visited-state',
        visually_hidden_text: I18n.t('previous_teacher_training.started_declaration_component.change_started_teacher_training'),
      }],
    }
  end

  def started?
    previous_teacher_trainings.any?
  end

  def previous_teacher_trainings
    @previous_teacher_training ||= @application_form.previous_teacher_trainings.published.started_yes
  end

  def published_previous_teacher_training
    @published_previous_teacher_training ||= @application_form.published_previous_teacher_training
  end
end
