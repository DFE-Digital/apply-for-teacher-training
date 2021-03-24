class DataSetDocumentation
  def self.for(klass)
    name = klass.name.demodulize.underscore

    begin
      spec = YAML.load_file(Rails.root.join("app/exports/#{name}.yml"))
    rescue Errno::ENOENT
      return false
    end

    common_columns = Dir[Rails.root.join('app/exports/common_columns/*')]
                         .map { |file| YAML.load_file(file) }
                         .reduce({}, :merge)

    used_common_columns = common_columns.slice(*spec['common_columns'])
    used_common_columns.merge(spec['custom_columns'] || {})
  end

  def self.shadowed_common_columns(klass)
    name = klass.name.demodulize.underscore

    begin
      spec = YAML.load_file(Rails.root.join("app/exports/#{name}.yml"))
    rescue Errno::ENOENT
      return false
    end

    common_columns = Dir[Rails.root.join('app/exports/common_columns/*')]
                         .map { |file| YAML.load_file(file) }
                         .reduce({}, :merge).keys.map(&:to_sym)

    custom_columns = spec['custom_columns'].keys.map(&:to_sym)

    custom_columns & common_columns
  end
end
