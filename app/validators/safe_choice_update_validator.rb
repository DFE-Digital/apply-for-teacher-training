class SafeChoiceUpdateValidator < ActiveModel::Validator
  def validate(record)
    if record.application_form.cannot_touch_choices?
      record.errors.add(
        :base,
        I18n.t('.validators.safe_choice_update_validator.error_message', current_cycle: RecruitmentCycle.current_year),
      )
    end
  end
end
