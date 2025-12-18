require 'rails_helper'

RSpec.describe ProviderInterface::PreviousTeacherTrainingComponent do
  let(:application_form) { create(:application_form) }

  subject(:component) { render_inline(described_class.new(application_form:)) }


end
