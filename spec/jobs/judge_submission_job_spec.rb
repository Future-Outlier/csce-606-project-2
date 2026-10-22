require "rails_helper"

RSpec.describe JudgeSubmissionJob do
  before { seed_judge }

  it "preserves the code and records an unexpected job failure" do
    attempt = create_user.practice_sessions.for_today(Problem.first).attempts.create!(
      code: "saved source", language: "ruby", total_cases: 6)
    submission = instance_double(Judge::Submission)
    error = RuntimeError.new("unexpected judge failure")
    allow(Judge::Submission).to receive(:new).and_return(submission)
    allow(submission).to receive(:call).and_raise(error)
    expect(Rails.error).to receive(:report).with(error)

    described_class.perform_now(attempt)

    expect(attempt.reload).to have_attributes(
      code: "saved source", judge_result: "Judge Unavailable", passed_cases: 0, total_cases: 6,
      error_message: "The Ruby judge is unavailable. Your code was saved; please try again later.")
  end
end
