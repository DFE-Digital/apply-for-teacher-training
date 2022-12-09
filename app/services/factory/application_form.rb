class Factory::ApplicationForm < Satisfactory::Record
  PERMITTED_WITH_COUNT = %i[application_choices].freeze
  PERMITTED_WITHOUT_COUNT = %i[submitted application_choice].freeze

  def initialize(...)
    super
    @choices = Satisfactory::Collection.new(upstream: self)
  end

  attr_accessor :choices

  def submitted
    tap do |form|
      form.traits << :submitted
    end
  end

  def application_choice(new_record: false)
    if new_record || choices.empty?
      choices.add(Factory::ApplicationChoice.new, singular: true)
    else
      choices.last
    end
  end

  def application_choices(count: 3, new_record: false)
    Satisfactory::Collection.new(upstream: self).tap do |new_choices|
      count.times do
        new_choices.add(Factory::ApplicationChoice.new)
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

  def permitted_with_count
    PERMITTED_WITH_COUNT
  end

  def permitted_without_count
    PERMITTED_WITHOUT_COUNT
  end
end
