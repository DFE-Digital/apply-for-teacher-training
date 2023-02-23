module GetIntoTeachingAPIHelper
  class LookupItemOption
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :name
  end

  def lookup_item_options(lookup_items)
    lookup_items.map do |item|
      LookupItemOption.new(name: item.value)
    end
  end
end
