class CollectionSelectComponent < ViewComponent::Base
  include ViewHelper

  attr_reader :attribute, :collection,
              :value_method, :text_method, :hint_method,
              :form_object, :form_path, :page_title

  def initialize(attribute:, collection:, value_method:, text_method:, hint_method:, form_object:, form_path:, page_title:)
    @attribute = attribute
    @collection = collection
    @value_method = value_method
    @text_method = text_method
    @hint_method = hint_method
    @form_object = form_object
    @form_path = form_path
    @page_title = page_title
  end
end
