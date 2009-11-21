class Service
  def self.inherited(klass)
    services[klass.name.demodulize.underscore] = klass
  end
  
  def self.services
    @services ||= {}
  end
  
  def self.find(name)
    services[name]
  end
  
  def create_message(room, author, params)
    raise "`#{self.class.name}' does not implement #create_message."
  end
  
  class GitHub < Service
    MESSAGE = '[%s - %s] %s (%s) -- %s'
    
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
end