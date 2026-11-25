class PreviousTeacherTraining::ListComponent < ApplicationComponent
  include ViewHelper

  with_collection_parameter :previous_teacher_training

  attr_reader :card, :actions, :heading_level, :current_user

  def initialize(previous_teacher_training:, current_user:, card: true, actions: false, heading_level: 2)
    @previous_teacher_training = previous_teacher_training
    @current_user = current_user
    @card = card
    @actions = actions
    @heading_level = heading_level
  end

  def render?
    @previous_teacher_training.started == 'yes'
  end

  def card_details
    { rows: }.merge(card_row)
  end

private

  def rows
    [provider_name_row, training_dates_row, details_row]
  end

  def card_row
    return {} unless card

    {
      card: {
        title: @previous_teacher_training.provider_name,
        heading_level:,
        actions: if actions
                   [
                     govuk_link_to(
                       t('previous_teacher_training.list_component.delete'),
                       remove_link,
                       no_visited_state: true,
                       class: 'govuk-link--no-visited-state',
                       visually_hidden_text: I18n.t('previous_teacher_training.list_component.change_provider_name'),
                     ),
                   ]
                 else
                   []
                 end,
      },
    }
  end

  def remove_link
    if current_user.is_a?(SupportUser)
      support_interface_application_form_remove_teacher_training_previous_teacher_trainings_path(
        @previous_teacher_training.application_form,
        @previous_teacher_training,
      )
    else
      remove_candidate_interface_previous_teacher_training_path(@previous_teacher_training)
    end
  end

  def provider_name_row
    {
      key: { text: I18n.t('previous_teacher_training.list_component.provider_name') },
      value: { text: @previous_teacher_training.provider_name },
    }.merge(provider_name_action)
  end

  def provider_name_action
    return {} unless actions

    {
      actions: [{
        href: change_link,
        text: I18n.t('previous_teacher_training.list_component.change'),
        classes: 'govuk-link--no-visited-state',
        visually_hidden_text: I18n.t('previous_teacher_training.list_component.change_provider_name'),
      }],
    }
  end

  def change_link
    if current_user.is_a?(SupportUser)
      support_interface_application_form_edit_teacher_training_previous_teacher_trainings_path(
        @previous_teacher_training.application_form,
        @previous_teacher_training,
      )
    else
      new_candidate_interface_previous_teacher_training_name_path(
        @previous_teacher_training,
        return_to: 'review',
      )
    end
  end

  def training_dates_row
    {
      key: { text: I18n.t('previous_teacher_training.list_component.training_dates') },
      value: { text: @previous_teacher_training.formatted_dates },
    }.merge(training_date_action)
  end

  def training_date_action
    return {} unless actions

    {
      actions: [{
        text: I18n.t('previous_teacher_training.list_component.change'),
        href: change_link,
        classes: 'govuk-link--no-visited-state',
        visually_hidden_text: I18n.t('previous_teacher_training.list_component.change_training_dates'),
      }],
    }
  end

  def details_row
    {
      key: { text: I18n.t('previous_teacher_training.list_component.details') },
      value: { text: simple_format(@previous_teacher_training.details) },
    }.merge(details_action)
  end

  def details_action
    return {} unless actions

    {
      actions: [{
        text: I18n.t('previous_teacher_training.list_component.change'),
        href: change_link,
        classes: 'govuk-link--no-visited-state',
        visually_hidden_text: I18n.t('previous_teacher_training.list_component.change_details'),
      }],
    }
  end
end
