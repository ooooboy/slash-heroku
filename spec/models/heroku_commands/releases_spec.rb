require "rails_helper"

RSpec.describe HerokuCommands::Releases, type: :model do
  include SlashHeroku::Support::Helpers::Api

  def heroku_handler_for(text)
    command = command_for(text)
    command.handler
  end

  it "has a releases -a command" do
    command = heroku_handler_for("releases -a atmos-dot-org")

    response_info = fixture_data("releases/atmos-dot-org/list")
    stub_request(:get, "https://api.heroku.com/apps/atmos-dot-org/releases")
      .with(headers: default_headers(command.user.heroku_token))
      .to_return(status: 200, body: response_info, headers: {})

    expect(command.task).to eql("releases")
    expect(command.subtask).to eql("default")
    expect(command.application).to eql("atmos-dot-org")
    expect { command.run }.to_not raise_error
    expect(command.response[:attachments].size).to eql(9)
  end

  it "has a release:info -a command" do
    command = heroku_handler_for("releases:info 9 -a atmos-dot-org")

    response_info = fixture_data("releases/atmos-dot-org/info")
    stub_request(:get, "https://api.heroku.com/apps/atmos-dot-org/releases/9")
      .with(headers: default_headers(command.user.heroku_token))
      .to_return(status: 200, body: response_info, headers: {})

    expect(command.task).to eql("releases")
    expect(command.subtask).to eql("info")
    expect(command.application).to eql("atmos-dot-org")
    expect { command.run }.to_not raise_error
    expect(command.response[:attachments].size).to eql(1)

    attachment = command.response[:attachments].first
    expect(attachment[:fallback])
      .to eql("Heroku release for atmos-dot-org - v9")
    expect(attachment[:text])
      .to eql("Release v9 of atmos-dot-org")
    expect(attachment[:title])
      .to eql("https://atmos-dot-org.herokuapp.com")
    expect(attachment[:title_link])
      .to eql("https://atmos-dot-org.herokuapp.com")
    expect(attachment[:fields].size).to eql(2)

    fields = attachment[:fields]
    expect(fields.first[:title]).to eql("By")
    expect(fields.first[:value]).to eql("atmos@atmos.org")
    expect(fields.last[:title]).to eql("When")
    expect(fields.last[:value]).to eql("2015-12-07T00:42:33Z")
  end

  it "has a release:rollback -a command" do
    id = "49d3122d-f273-4e34-afec-337a8b107e48"
    heroku_handler_for("releases:rollback #{id} -a atmos-dot-org")

    pending "releases:rollback is unimplemented"

    raise ArgumentError, "releases:rollback is unimplemented"
  end
end