module GcseQualificationHelper
  def select_gcse_qualification_type_options
    option = Struct.new(:id, :label)

    t('gcse_edit_type.types').map { |id, label| option.new(id, label) }
  end

  def conditional_radios_for_gcse_qualifications
    { other_uk: [other_uk_qualification_type: 'Enter type of qualification'] }
  end
end
