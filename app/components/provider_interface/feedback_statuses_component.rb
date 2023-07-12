class ProviderInterface::FeedbackStatusesComponent < ViewComponent::Base
  include ViewHelper

  attr_reader :feedback_status

  def initialize(feedback_status:)
    @feedback_status = feedback_status
  end

  def feedback_status_label
    translated_feedback_status = mapped_feedback_status_label[feedback_status.downcase]
    I18n.t("provider_interface.reference_status_report.feedback_status_labels.#{translated_feedback_status}", default: 'other')
  end

  def feedback_status_colour
    I18n.t("provider_interface.reference_status_report.feedback_status_labels_colours.#{feedback_status.downcase}", default: 'grey')
  end

  def mapped_feedback_status_label
    {
      'received' => 'feedback_provided',
      'not received' => 'feedback_requested',
      'other' => 'other',
    }
  end
end
