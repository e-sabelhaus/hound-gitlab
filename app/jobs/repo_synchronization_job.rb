class RepoSynchronizationJob
  extend Retryable

  @queue = :high

  def self.before_enqueue(user_id, gitlab_token)
    user = User.find(user_id)
    user.update_attribute(:refreshing_repos, true)
  end

  def self.perform(user_id, gitlab_token)
    user = User.find(user_id)
    synchronization = RepoSynchronization.new(user, gitlab_token)
    synchronization.start
    user.update_attribute(:refreshing_repos, false)
  rescue Resque::TermException
    Resque.enqueue(self, user_id, gitlab_token)
  end
end
