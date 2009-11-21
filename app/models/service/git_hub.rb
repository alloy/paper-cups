class Service::GitHub < Service
  def create_message(room, author, params)
    pushed = JSON.parse(params[:payload])
    repo   = pushed['repository']['name']
    branch = pushed['ref'].split('/').last
    
    pushed['commits'].each do |commit|
      committer = commit['author']['name']
      room.messages.create :author => author, :body =>
        "[#{repo} - #{branch}] #{commit['message']} (#{commit['url']}) -- #{committer}"
    end
  end
end