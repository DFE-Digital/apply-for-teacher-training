class QualificationTitleComponent < ActionView::Component::Base
  def initialize(qualification:)
    @qualification = qualification
  end

  def qualification_type
    if @qualification.level == 'gcse' && @qualification.missing_qualification?
      I18n.t('application_form.gcse.qualification_types_abbreviated.gcse')
    elsif @qualification.level == 'gcse'
      I18n.t(
        "application_form.gcse.qualification_types_abbreviated.#{@qualification.qualification_type}",
        default: @qualification.qualification_type,
      )
    else
      @qualification.qualification_type
    end
  end
end
