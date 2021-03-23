class CollectionSelectComponent < ViewComponent::Base
  include ViewHelper

  attr_reader :attribute, :collection,
              :value_method, :text_method, :hint_method,
              :form_object, :form_path, :form_method,
              :page_title, :caption

  def initialize(attribute:, collection:, value_method:, text_method:, hint_method:, form_object:, form_path:, form_method: :post, page_title:, caption:)
    @attribute = attribute
    @collection = collection
    @value_method = value_method
    @text_method = text_method
    @hint_method = hint_method
    @form_object = form_object
    @form_path = form_path
    @form_method = form_method
    @page_title = page_title
    @caption = caption
  end
end
