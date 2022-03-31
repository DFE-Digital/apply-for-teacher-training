class RejectionReasons::RejectionReasonsComponent < RejectionReasons::StructuredRejectionReasonsComponent
  def render_link_to_find?(reason)
    reason.id == 'qualifications' && @render_link_to_find_when_rejected_on_qualifications
  end
end
