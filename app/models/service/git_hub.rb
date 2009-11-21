class Service::GitHub < Service
  def create_message(room, author, params)
    @pushed = JSON.parse(params[:payload])
    @pushed['commits'].each do |commit|
      room.messages.create :author => author, :body => message(commit)
    end
  end
  
  private
  
  def message(commit)
    @repo   ||= @pushed['repository']['name']
    @branch ||= @pushed['ref'].split('/').last
    
    commit_message = commit['message'].split("\n").first.strip
    "[#{@repo}/#{@branch}] #{commit_message} (#{commit['url']}) -- #{commit['author']['name']}"
  end
end