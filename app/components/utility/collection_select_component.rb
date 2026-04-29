class CollectionSelectComponent < ApplicationComponent
  include ViewHelper

  attr_reader :attribute, :collection, :bold_labels,
              :value_method, :text_method, :hint_method, :hint,
              :form_object, :form_path, :form_method,
              :page_title, :caption

  def initialize(attribute:, collection:, value_method:, text_method:, hint_method:, form_object:, form_path:, page_title:, caption:, form_method: :post, bold_labels: nil, hint: {})
    @attribute = attribute
    @collection = collection
    @value_method = value_method
    @text_method = text_method
    @hint_method = hint_method
    @hint = hint
    @bold_labels = bold_labels
    @form_object = form_object
    @form_path = form_path
    @form_method = form_method
    @page_title = page_title
    @caption = caption
  end

  def collection_options_for_select
    collection.map do |option|
      [
        (hint_method.present? ? "#{option.try(text_method)} - #{option.try(hint_method)}" : option.try(text_method)),
        option.try(value_method),
      ]
    end.unshift([nil, nil])
  end

  def collection_count
    count_of_items = collection.count
    count_of_items.is_a?(Hash) ? count_of_items.keys.count : count_of_items
  end
end
