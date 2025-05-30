module CandidateInterface
  class CarriedOverContentComponentPreview < ViewComponent::Preview
    def after_find_opens
      application_form = FactoryBot.create(:application_form)
      render AfterFindOpensComponent.new(application_form:)
    end

    def before_find_opens
      application_form = FactoryBot.create(:application_form)
      render BeforeFindOpensComponent.new(application_form:)
    end
  end

  class AfterFindOpensComponent < CandidateInterface::CarriedOverContentComponent
    def after_find_opens?
      true
    end
  end

  class BeforeFindOpensComponent < CandidateInterface::CarriedOverContentComponent
    def after_find_opens?
      false
    end
  end
end
