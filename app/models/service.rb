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
end

Dir.glob(File.expand_path('../service/*.rb', __FILE__)).each do |service|
  require_dependency service
end