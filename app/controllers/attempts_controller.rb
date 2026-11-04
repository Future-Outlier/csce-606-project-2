class AttemptsController < ApplicationController
  include RoadmapAccess

  HISTORY_LIMIT = 100
  COACHING_LOCKED_MESSAGE = "Explain your approach to the coach before submitting code.".freeze

  def index
    @attempts = current_user.attempts.includes(practice_session: :problem).order(created_at: :desc).limit(HISTORY_LIMIT)
  end

  def show
    @attempt = current_user.attempts.includes(practice_session: :problem).find(params[:id])
  end

  def create
    @problem = Problem.includes(:test_cases).find_by!(slug: params[:problem_id])
    return unless require_unlocked_topic(@problem.topic)
    return redirect_to(problem_path(@problem), alert: COACHING_LOCKED_MESSAGE) if coaching_locked?

    @attempt = Attempt.new(params.require(:attempt).permit(:code, :language))

    unless @problem.ready_for_judging?
      @attempt.errors.add(:base, "This problem is not ready for judging: at least five cases are required.")
      return render "problems/show", status: :unprocessable_content
    end

    @attempt.practice_session = current_user.practice_sessions.for_today(@problem)
    @attempt.total_cases = @problem.test_cases.size
    Attempt.transaction do
      if @attempt.save
        enqueue_judging
        redirect_to attempt_path(@attempt)
      else
        render "problems/show", status: :unprocessable_content
      end
    end
  end

  private

  def enqueue_judging
    begin
      enqueued = JudgeSubmissionJob.perform_later(@attempt)
    rescue ActiveRecord::ActiveRecordError => error
      Rails.error.report(error)
    end
    unless enqueued
      @attempt.update!(judge_result: Attempt::JUDGE_UNAVAILABLE, error_message: Judge::DockerRunner::UNAVAILABLE_MESSAGE)
    end
  end

  private

  # Checked on the server so a hidden editor can't be bypassed with a direct POST.
  def coaching_locked?
    current_user.premium? && current_user.practice_sessions.for_today(@problem).coaching_locked?
  end
end
