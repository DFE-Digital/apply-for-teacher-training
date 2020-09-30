module CandidateInterface
  class DecoupledRefereesController < CandidateInterfaceController
    def start; end

    def type
      @reference_type_form = Reference::RefereeTypeForm.new
    end

    def update_type; end
  end
end
