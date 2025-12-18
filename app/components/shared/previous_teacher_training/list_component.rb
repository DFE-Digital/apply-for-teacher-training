class PreviousTeacherTraining::ListComponent < ViewComponent::Base
  include ViewHelper

  with_collection_parameter :previous_teacher_training

  attr_reader :header, :border, :actions

  def initialize(previous_teacher_training:, header: true, border: true, actions: false)
    @previous_teacher_training = previous_teacher_training
    @header = header
    @border = border
    @actions = actions
  end

  def provider_name
    @provider_name ||= @previous_teacher_training.provider_name
  end

  def rows
    [provider_name_row, training_dates_row, details_row]
  end

private

  def provider_name_row
    {
      key: I18n.t('previous_teacher_training.list_component.provider_name'),
      value: @previous_teacher_training.provider_name,
    }.merge(provider_name_action)
  end

  def provider_name_action
    return {} unless actions

    {
      action: {
        href: new_candidate_interface_previous_teacher_training_name_path(
          @previous_teacher_training,
          return_to: 'review',
        ),
        text: I18n.t('previous_teacher_training.list_component.change'),
        classes: 'govuk-link--no-visited-state',
        visually_hidden_text: I18n.t('previous_teacher_training.list_component.change_provider_name'),
      },
    }
  end

  def training_dates_row
    {
      key: I18n.t('previous_teacher_training.list_component.training_dates'),
      value: @previous_teacher_training.formatted_dates,
    }.merge(training_date_action)
  end

  def training_date_action
    return {} unless actions

    {
      action: {
        text: I18n.t('previous_teacher_training.list_component.change'),
        href: new_candidate_interface_previous_teacher_training_date_path(
          @previous_teacher_training,
          return_to: 'review',
        ),
        classes: 'govuk-link--no-visited-state',
        visually_hidden_text: I18n.t('previous_teacher_training.list_component.change_training_dates'),
      },
    }
  end

  def details_row
    {
      key: I18n.t('previous_teacher_training.list_component.details'),
      value: simple_format(@previous_teacher_training.details),
    }.merge(details_action)
  end

  def details_action
    return {} unless actions

    {
      action: {
        text: I18n.t('previous_teacher_training.list_component.change'),
        href: new_candidate_interface_previous_teacher_training_detail_path(
          @previous_teacher_training,
          return_to: 'review',
        ),
        classes: 'govuk-link--no-visited-state',
        visually_hidden_text: I18n.t('previous_teacher_training.list_component.change_details'),
      },
    }
  end
end
