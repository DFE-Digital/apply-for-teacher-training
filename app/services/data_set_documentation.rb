class DataSetDocumentation
  def self.for(klass)
    name = with_name_handling(klass.name.demodulize.underscore)

    spec = YAML.load_file(Rails.root.join("app/exports/#{name}.yml"), permitted_classes: [Time, Date])
    common_columns = load_common_columns
    custom_columns = spec['custom_columns']

    check_for_shadowed_columns(common_columns, custom_columns)

    used_common_columns = common_columns.slice(*spec['common_columns'])
    used_common_columns.merge(custom_columns || {})
  end

  def self.check_for_shadowed_columns(common_columns, custom_columns)
    if custom_columns.present? && custom_columns.keys.map(&:to_sym).intersect?(common_columns.keys.map(&:to_sym))
      raise 'There are columns in the export documentation that shadow the shared common columns'
    end
  end

  def self.load_common_columns
    Rails.root.glob('app/exports/common_columns/*')
        .map { |file| YAML.load_file(file, permitted_classes: [Time, Date]) }
        .reduce({}, :merge)
  end

  def self.with_name_handling(spec_name)
    case spec_name
    when 'qualifications_export'
      'expanded_qualifications_export'
    else
      spec_name
    end
  end

  private_class_method :load_common_columns, :check_for_shadowed_columns
end
