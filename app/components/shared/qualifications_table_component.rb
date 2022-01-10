# NOTE: This component is used by both provider and support UIs
class QualificationsTableComponent < ViewComponent::Base
  attr_reader :qualifications, :header, :subheader

  def initialize(qualifications:, header:, subheader:)
    @qualifications = qualifications
    @header = header
    @subheader = subheader
  end

  def add_other_qualifications_q_a
    {
      rows: [{ key: 'Do you want to add A levels and other qualifications?',
               value: 'No' }],
    }
  end
end
