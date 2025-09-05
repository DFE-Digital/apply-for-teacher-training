# NOTE: This component is used by both provider and support UIs
class QualificationsTableComponent < ApplicationComponent
  attr_reader :qualifications, :header, :subheader, :editable

  def initialize(qualifications:, header:, subheader:, editable: false)
    @qualifications = qualifications
    @header = header
    @subheader = subheader
    @editable = editable
  end

  def add_other_qualifications_q_a
    [{ key: 'Do you want to add A levels and other qualifications?',
       value: 'No' }]
  end
end
