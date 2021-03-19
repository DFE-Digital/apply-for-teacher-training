class DataSetDocumentation
  def self.for(klass)
    name = klass.name.demodulize.underscore

    begin
      spec = YAML.load_file(Rails.root.join("app/exports/#{name}.yml"))
    rescue Errno::ENOENT
      return false
    end

    common_columns = YAML.load_file(Rails.root.join('app/exports/_common_columns.yml'))
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

    common_columns = YAML.load_file(Rails.root.join('app/exports/_common_columns.yml')).keys.map(&:to_sym)
    custom_columns = spec['custom_columns'].keys.map(&:to_sym)

    custom_columns & common_columns
  end
end
