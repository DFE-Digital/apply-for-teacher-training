require 'rails_helper'

RSpec.describe DataMigrations::DestroyOrphanedSites do
  context 'when the site has a course option' do
    it 'is not destroyed' do
      provider = create(:provider)
      create(:course_option, site: create(:site, provider: provider), course: create(:course, provider: provider))

      expect { described_class.new.change }.not_to(change { Site.count })
    end
  end

  context 'when the site does not have a course option' do
    it 'is destroyed' do
      create(:site)

      expect { described_class.new.change }.to change { Site.count }.by(-1)
    end
  end
end
