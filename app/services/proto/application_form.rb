class Proto::ApplicationForm < Proto::Record
  def initialize(...)
    super
    @choices = Proto::Collection.new(upstream: self)
  end

  attr_accessor :choices

  def submitted
    tap do |form|
      form.traits << :submitted
    end
  end

  def application_choice(new_record: false)
    if new_record || choices.empty?
      choices.add(Proto::ApplicationChoice.new, singular: true)
    else
      choices.last
    end
  end

  def application_choices(count: 3, new_record: false)
    Proto::Collection.new(upstream: self).tap do |new_choices|
      count.times do
        new_choices.add(Proto::ApplicationChoice.new)
      end

      if new_record
        choices.add(new_choices)
      else
        self.choices = new_choices
      end
    end
  end

  def build
    FactoryBot.build(:application_form, *traits,
                     application_choices: choices.build)
  end

private

  def associations_plan
    {
      application_choices: choices.build_plan,
    }
  end
end
