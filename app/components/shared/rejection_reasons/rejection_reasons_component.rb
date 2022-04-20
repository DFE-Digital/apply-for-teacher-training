##
# This component class supports the rendering of rejection reasons from the current iteration of structured rejection reasons.
# See https://github.com/DFE-Digital/apply-for-teacher-training/blob/main/docs/reasons-for-rejection.md
#
class RejectionReasons::RejectionReasonsComponent < RejectionReasons::StructuredRejectionReasonsComponent
  def render_link_to_find?(reason)
    reason.id == 'qualifications' && @render_link_to_find_when_rejected_on_qualifications
  end
end
