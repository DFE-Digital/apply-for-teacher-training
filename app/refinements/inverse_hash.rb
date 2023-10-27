module InverseHash
  refine Hash do
    def inverse
      each_with_object({}) do |(key, value), object|
        value.each do |val|
          object[val] ||= []
          object[val] << key unless object[val].include?(key)
          object[val].sort!
        end
      end
    end
  end
end
