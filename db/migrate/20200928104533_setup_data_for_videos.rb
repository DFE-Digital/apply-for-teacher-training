class SetupDataForVideos < ActiveRecord::Migration[6.0]
  def up
    provider = Provider.find_by(code: 'B72')
    provider.update(name: 'University of West Devonshire')

    provider.provider_users.first.update(
      dfe_sign_in_uid: 'michelle',
      email_address: 'michelle.walker@uowd.ac.uk',
      first_name: 'Michelle',
      last_name: 'Walker',
    )
    provider.provider_permissions.first.update(
      manage_users: true,
      manage_organisations: false,
      make_decisions: true,
      view_safeguarding_information: true,
      view_diversity_information: true,
    )

    provider = Provider.find_by(code: 'C58')
    provider.update(name: 'University of Dulwich')

    provider = Provider.find_by(code: '2LR')
    provider.update(name: 'Mullerstad TSA')

    provider.provider_users.first.update(
      dfe_sign_in_uid: 'paul',
      email_address: 'paul.lamb@mullerstad.ac.uk',
      first_name: 'Paul',
      last_name: 'Lamb',
    )
    provider.provider_permissions.first.update(
      manage_users: true,
      manage_organisations: true,
      make_decisions: true,
      view_safeguarding_information: true,
      view_diversity_information: true,
    )

    provider = Provider.find_by(code: '1N1')
    provider.update(name: 'Springbank SCITT')

    provider.provider_users.first.update(
      dfe_sign_in_uid: 'maria',
      email_address: 'maria.spicer@springbankscitt.ac.uk',
      first_name: 'Maria',
      last_name: 'Spicer',
    )
    provider.provider_permissions.first.update(
      manage_users: true,
      manage_organisations: false,
      make_decisions: true,
      view_safeguarding_information: true,
      view_diversity_information: true,
    )
  end

  def down
    provider = Provider.find_by(code: 'B72')
    provider.update(name: 'University of Brighton')

    provider = Provider.find_by(code: 'C58')
    provider.update(name: 'University of Chichester')

    provider = Provider.find_by(code: '2LR')
    provider.update(name: 'Oriel ITT Partnership')

    provider = Provider.find_by(code: '1N1')
    provider.update(name: 'Gorse SCITT')
  end
end
