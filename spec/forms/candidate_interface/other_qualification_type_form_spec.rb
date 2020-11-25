require 'rails_helper'

RSpec.describe CandidateInterface::OtherQualificationTypeForm do
  let(:error_message_scope) do
    'activemodel.errors.models.candidate_interface/other_qualification_type_form.attributes.'
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:qualification_type) }
  end
end
