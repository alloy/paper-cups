module RisosuSan
  def self.included(klass) #:nodoc:
    klass.extend ClassMethods
  end
  
  module ClassMethods
    # Adds a before filter which will take care of finding the parent resource.
    #
    #   class PasswordsController < ActionController::Base
    #     find_parent_resource :only => :new
    #   end
    def find_parent_resource(options = {})
      before_filter :find_parent_resource, options
    end
  end
  
  protected
  
  # Returns whether or not the request for the current resource is nested under
  # a parent resource, by reflecting on the params.
  #
  #   params # => { :id => 42 }
  #   nested? # => false
  #
  #   params # => { :member_id => 24, :id => 42 }
  #   nested? # => true
  def nested?
    !parent_resource_params.empty?
  end
  
  # Returns a hash of params for the parent resource, if available.
  #
  #   params # => { :member_id => 24, :id => 42 }
  #   parent_resource_params # => { :param => :member_id, :id => 24, :name => 'member', :class_name => 'Member', :class => Member }
  def parent_resource_params
    @parent_resource_params ||=
      if key = params.keys.find { |k| k =~ /^(\w+)_id$/ }
        { :param => key, :id => params[key], :name => $1, :class_name => $1.classify, :class => $1.classify.constantize }
      else
        {}
      end
  end
  
  # Finds the parent resource, if available, and assigns it to
  # <tt>@parent_resource</tt> and an instance variable with the name of the
  # resource.
  #
  #   params # => { :member_id => 24, :id => 42 }
  #   find_parent_resource
  #   @parent_resource # => #<Member id: 24>
  #   @member # => #<Member id: 24>
  def find_parent_resource
    if @parent_resource.nil? && nested? && @parent_resource = parent_resource_params[:class].find(parent_resource_params[:id])
      instance_variable_set("@#{parent_resource_params[:name]}", @parent_resource)
    end
    @parent_resource
  end
end