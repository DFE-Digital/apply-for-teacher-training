module AddAnotherButtonHelper
  def add_another_button(form)
    dummy_model = OpenStruct.new(id: 0)
    field = form.fields_for 'further_conditions[]', dummy_model do |fc|
      render 'provider_interface/offer/conditions/further_condition', condition_id: dummy_model.id, label_text: '{label_text}', form: form, condition_field: fc
    end
    form.button(
      name: 'commit',
      value: 'add_another_condition',
      class: 'govuk-button govuk-button--secondary app-add-another__add-button govuk-!-margin-bottom-4',
      data: { field: field.gsub('0', '{condition_id}') },
    ) do
      t('.add_another')
    end
  end
end
