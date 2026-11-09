require "rails_helper"

RSpec.describe Judge::HerokuDynoRunner do
  before { seed_judge }

  let(:problem) { Problem.find_by!(slug: "contains-duplicate") }
  let(:inputs) { problem.test_cases.order(:position).map(&:input) }
  let(:api) { instance_double(Judge::HerokuDynoRunner::Api) }
  let(:rendezvous) { instance_double(Judge::HerokuDynoRunner::Rendezvous) }

  it "creates an attached worker dyno and sends source only over stdin" do
    expect(api).to receive(:create_dyno).with(app: "codecoach-judge", token: "platform-secret")
      .and_return("rendezvous://rendezvous.runtime.heroku.com:5000/attach-secret")
    expect(rendezvous).to receive(:call) do |url:, input:, timeout:|
      payload = JSON.parse(input)
      expect(url).to eq("rendezvous://rendezvous.runtime.heroku.com:5000/attach-secret")
      expect(input).not_to include("platform-secret")
      expect(payload).to include("language" => "go", "runtime" => "Go 1.27.3", "inputs" => inputs)
      expect(payload).not_to have_key("expected_output")
      expect(timeout).to be > 15
      JSON.generate(status: "ok", outputs: problem.test_cases.order(:position).map(&:expected_output),
        runtime: "Go 1.27.3")
    end

    result = described_class.new(
      app: "codecoach-judge", token: "platform-secret", api: api, rendezvous: rendezvous
    ).call(code: LanguageSolutions::CORRECT.fetch("go").fetch(problem.slug), language: "go",
      problem: problem, inputs: inputs)

    expect(result).to include("status" => "ok", "runtime" => "Go 1.27.3")
    expect(result.fetch("outputs")).to eq(problem.test_cases.order(:position).map(&:expected_output))
  end

  it "fails closed when configuration is missing or malformed" do
    expect(api).not_to receive(:create_dyno)
    expect(rendezvous).not_to receive(:call)

    [
      [ nil, "secret" ],
      [ "INVALID_APP", "secret" ],
      [ "codecoach-judge", nil ],
      [ "codecoach-judge", "secret\nheader" ]
    ].each do |app, token|
      result = described_class.new(app: app, token: token, api: api, rendezvous: rendezvous).call(
        code: "solution", language: "go", problem: problem, inputs: inputs)
      expect(result).to eq("status" => "Judge Unavailable", "outputs" => [])
    end
  end

  it "fails closed on Platform API, rendezvous, and result failures" do
    runner = described_class.new(
      app: "codecoach-judge", token: "platform-secret", api: api, rendezvous: rendezvous
    )

    allow(api).to receive(:create_dyno).and_return("rendezvous://rendezvous.runtime.heroku.com:5000/secret")
    [
      "not json",
      JSON.generate(status: "ok", outputs: [], runtime: "Go 1.26"),
      JSON.generate(status: "invented", outputs: [], runtime: "Go 1.27.3")
    ].each do |response|
      allow(rendezvous).to receive(:call).and_return(response)
      expect(runner.call(code: "solution", language: "go", problem: problem, inputs: inputs))
        .to eq("status" => "Judge Unavailable", "outputs" => [])
    end

    allow(api).to receive(:create_dyno).and_raise(Net::ReadTimeout)
    expect(runner.call(code: "solution", language: "go", problem: problem, inputs: inputs))
      .to eq("status" => "Judge Unavailable", "outputs" => [])
  end
end
