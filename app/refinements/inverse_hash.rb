module InverseHash
  refine Hash do
    Hash::UninversableHashError = Class.new(StandardError)

    def inverse
      each_with_object({}) do |(key, value), object|
        if value.is_a?(Array)
          value.each do |val|
            if object[val].is_a?(Array)
              object[val] << key
            elsif object[val].nil?
              object[val] = [key]
            else
              mid = object[val]
              object[val] = []
              object[val] << mid << key
            end
            object[val].sort!
          end
        elsif value.is_a?(Hash)
          raise Hash::UninversableHashError, 'Cannot inverse a nested hash'
        else
          object[value] = key
        end
      end
    end
  end
end
