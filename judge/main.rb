require "json"
require_relative "runner"

submission_pid = Process.fork do
  result_output = STDOUT.dup
  STDOUT.reopen(File::NULL, "w")
  result = RubySubmission.new.call(JSON.parse(STDIN.read))
  result["coverage"] = Coverage.result if Coverage.running?
  result_output.puts(JSON.generate(result))
end
_, status = Process.wait2(submission_pid)
abort unless status.success?
