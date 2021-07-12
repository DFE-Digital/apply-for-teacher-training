require './config/environment'

filename = ARGV[0]

if filename
  model_names = File.read(filename).split(/\n/).map do |line|
    next unless line =~ /^<enum> /
    line.split('<enum> ')[1].split('.')[0]
  end
  model_names.compact.uniq.map(&:constantize) rescue nil
else
  diff_tree_output = `git diff-tree -r --name-only --no-commit-id --no-renames --diff-filter=d origin/main HEAD app/models`
  diff_tree_output.split(/\n/).map do |model_path|
    require "./#{model_path}"
  end
end

# Only includes classes already loaded via constantize or require above
ApplicationRecord.descendants.each do |model|
  enums = model.attribute_types.select { |k, v| v.is_a? ActiveRecord::Enum::EnumType }
  enums.each do |k, v|
    puts "<enum> #{model}.#{k}: #{v.send(:mapping).values}"
  end
end
