##
# This component class supports the rendering of rejection reasons from the current iteration of structured rejection reasons.
# See https://github.com/DFE-Digital/apply-for-teacher-training/blob/main/docs/reasons-for-rejection.md
#
class RejectionReasons::RejectionReasonsComponent < RejectionReasons::StructuredRejectionReasonsComponent
  attr_reader :editable

  def initialize(application_choice:, reasons:, editable: false, render_link_to_find_when_rejected_on_qualifications: false)
    super(
      application_choice: application_choice,
      reasons: reasons,
      render_link_to_find_when_rejected_on_qualifications: render_link_to_find_when_rejected_on_qualifications,
    )

    @editable = editable
  end

  def editable?
    editable
  end

  def render_link_to_find?(reason)
    reason.id == 'qualifications' && @render_link_to_find_when_rejected_on_qualifications
  end
end
