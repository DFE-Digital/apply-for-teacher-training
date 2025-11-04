# NOTE: This component is used by both provider and support UIs
class QualificationsTableComponent < ViewComponent::Base
  attr_reader :qualifications, :header, :subheader, :editable, :header_tag

  def initialize(qualifications:, header:, subheader:, editable: false, header_tag: 'h4')
    @qualifications = qualifications
    @header = header
    @subheader = subheader
    @editable = editable
    @header_tag = header_tag
  end

  def add_other_qualifications_q_a
    [{ key: 'Do you want to add A levels and other qualifications?',
       value: 'No' }]
  end
end
