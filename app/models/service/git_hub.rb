class Service::GitHub < Service
  def create_message(room, author, params)
    @pushed = JSON.parse(params[:payload])
    @repo   = @pushed['repository']['name']
    @branch = @pushed['ref'].split('/').last
    
    commits = @commits = @pushed['commits']
    
    if commits.length > 3
      coalesce = true
      commits = commits.first(2)
    end
    
    messages = commits.map { |commit| message(commit) }
    messages << coalesced_message if coalesce
    
    messages.each do |message|
      room.messages.create :author => author, :body => message
    end
  end
  
  private
  
  def message(commit)
    commit_message = commit['message'].split("\n").first.strip
    "[#{@repo}/#{@branch}] #{commit_message} (#{commit['url']}) -- #{commit['author']['name']}"
  end
  
  def coalesced_message
    url = "#{@pushed['repository']['url']}/compare/#{@commits.first['id'][0,7]}...#{@commits.last['id'][0,7]}"
    "[#{@repo}/#{@branch}] Total of #{@commits.size} commits: #{url}"
  end
end