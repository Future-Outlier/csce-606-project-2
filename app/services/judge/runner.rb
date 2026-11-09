module Judge
  class Runner
    class << self
      def build
        return RemoteRunner.new if Rails.env.production? || ENV["JUDGE_URL"].present?

        DockerRunner.new
      end
    end
  end
end
