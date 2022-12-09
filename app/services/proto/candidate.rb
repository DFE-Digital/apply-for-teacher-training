class Proto::Candidate < Proto::Record
  def initialize(...)
    super
    @application_forms = Proto::Collection.new(upstream: self)
  end

  attr_reader :application_forms

  def submitted_application(new_record: false)
    application_form(new_record:).submitted.modify do |form|
      form.with.application_choice
    end
  end

  def rejected_application(new_record: false)
    application_form(new_record:).modify do |form|
      form.with.application_choice.rejected
    end
  end

  def application_form(new_record: false)
    if new_record || application_forms.empty?
      application_forms.add(Proto::ApplicationForm.new, singular: true)
    else
      application_forms.last
    end
  end

  def create_self
    FactoryBot.create(:candidate, *traits,
                      application_forms: application_forms.build)
  end

private

  def associations_plan
    {
      application_forms: application_forms.build_plan,
    }
  end
end
