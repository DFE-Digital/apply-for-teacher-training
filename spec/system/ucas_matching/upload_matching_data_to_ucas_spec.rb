require 'rails_helper'

RSpec.feature 'Uploading of matching data to UCAS', sidekiq: true do
  scenario 'An eventually succesful upload to UCAS' do
    given_there_is_an_application_in_the_system

    given_the_access_token_can_not_be_acquired
    when_the_daily_upload_runs
    then_an_token_error_is_raised_so_sidekiq_tries_again

    given_the_file_can_not_be_uploaded
    when_the_daily_upload_runs
    then_a_server_error_is_raised_so_sidekiq_tries_again

    given_all_is_good_with_the_upload_system
    when_the_daily_upload_runs
    then_the_file_has_been_uploaded
  end

  def given_there_is_an_application_in_the_system
    @application_choice = create(:submitted_application_choice, :with_completed_application_form)
  end

  def given_the_access_token_can_not_be_acquired
    stub_request(:post, 'https://transfer.ucasenvironments.com/api/v1/token')
      .to_return(
        status: 401,
        body: 'Something is wrong here!',
      )
  end

  def when_the_daily_upload_runs
    @latest_exception = nil
    UCASMatching::UploadMatchingData.new.perform
  rescue UCASMatching::APIError => e
    @latest_exception = e
  end

  def then_an_token_error_is_raised_so_sidekiq_tries_again
    expect(@latest_exception.message).to eql("HTTP 401 Unauthorized when fetching access token: 'Something is wrong here!'")
  end

  def given_the_file_can_not_be_uploaded
    stub_request(:post, 'https://transfer.ucasenvironments.com/api/v1/token')
      .to_return(
        body: { access_token: '123456789' }.to_json,
      )

    @upload_request = stub_request(
      :post,
      'https://transfer.ucasenvironments.com/api/v1/folders/685520099/files',
    ).with(headers: {
      'Authorization' => 'Bearer 123456789',
    }).to_return(
      status: 500,
      body: 'Brrr something has gone wrong',
    )
  end

  def then_a_server_error_is_raised_so_sidekiq_tries_again
    expect(@latest_exception.message).to eql("HTTP 500 Internal Server Error when uploading to Movit: 'Brrr something has gone wrong'")
  end

  def given_all_is_good_with_the_upload_system
    stub_request(:post, 'https://transfer.ucasenvironments.com/api/v1/token')
      .to_return(
        body: { access_token: '123456789' }.to_json,
      )

    stub_request(
      :post,
      'https://transfer.ucasenvironments.com/api/v1/folders/685520099/files',
    ).with(headers: {
      'Authorization' => 'Bearer 123456789',
    }).to_return(status: 200)
  end

  def then_the_file_has_been_uploaded
    expect(@latest_exception).to be_nil

    expect(WebMock).to have_requested(:post, 'https://transfer.ucasenvironments.com/api/v1/folders/685520099/files')
      .with { |req|
        tempfile = Rails.root.join('tmp', "#{SecureRandom.hex}.zip")

        File.open(tempfile, 'wb') do |f|
          # The `req.body` is a HTTP response that looks like this:
          #
          #   -----------------------d04a9b3742f0b3809dc6a392e2a91c02d22d1adf6a
          #   Content-Disposition: form-data; name="file"; filename="dfe_apply_itt_applications_20200720_111327_0100-1acf8a7f568ad745f4d8d7dc08d0425c.zip"
          #   Content-Type: application/octet-stream
          #
          #   P?Y?P??ȇkTdfe_apply_itt_applications_20200720_111327_0100-1acf8a7f568ad745f4d8d7dc08d0425c.csv]?[o?0
          #
          #   -----------------------d04a9b3742f0b3809dc6a392e2a91c02d22d1adf6a--
          #
          # Remove the first 4 and last 2 lines to get the actual zipfile.
          f.write(req.body.lines[4..-2].join.chomp)
        end

        directory_to_extract_to = Rails.root.join('tmp', SecureRandom.hex)
        Dir.mkdir(directory_to_extract_to)

        Archive::Zip.extract(
          tempfile.to_s,
          directory_to_extract_to.to_s,
          password: ENV.fetch('UCAS_ZIP_PASSWORD'),
        )

        csv = File.read(Dir.glob("#{directory_to_extract_to}/*.csv").first)
        csv.match?(@application_choice.application_form.first_name)
      }
      .at_least_once
  end
end
