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
    spec['custom_columns'].merge(used_common_columns)
  end
end
