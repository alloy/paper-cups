# == AuthenticationNeededSan
#
# AuthenticationNeededSan is a module which assists your controllers in dealing
# with cases where authentication is needed, but you’d like to redirect the
# user ‘back’ to the page she originally requested once the authentication flow
# has been finished.
# 
# Since it uses the +flash+ internally, the data _won't_ be around after
# the user makes another request. This is becasue you do not want the user
# to be redirected ‘back’ to a page ‘out of the blue’. Which is what would
# happen if we’d use the +session+.
#
# However, sometimes you might want to keep the data around for another
# request. Use still_authentication_needed! in this case.
module AuthenticationNeededSan
  class ProtocolNotImplementedError < StandardError; end
  
  # Returns a hash of options that need to be kept around until
  # finish_authentication_needed! is called.
  def after_authentication
    flash[:after_authentication] ||= {}
  end
  
  # Call this method when authentication is needed and you want the user to
  # be redirected back to the URL she requested.
  #
  # Any extra +options+ given will be available as well, through the
  # after_authentication accessor.
  #
  # Your class should implement the +when_authentication_needed+ instance
  # method, which you use to define what should happen when
  # authentication_needed! is called. Normally you’d probably redirect the
  # user to a ‘login’ page.
  def authentication_needed!(options = {})
    after_authentication.merge! options
    after_authentication[:redirect_to] ||= request.url
    
    if respond_to?(:when_authentication_needed, true)
      when_authentication_needed
    else
      raise ProtocolNotImplementedError,
        "[!] The class `#{self.class.name}' should implement #when_authentication_needed to define what should be done after #authentication_needed! is called."
    end
  end
  
  # Returns whether or not there currently is any after_authentication data.
  def authentication_needed?
    !after_authentication.blank?
  end
  
  # Force the after_authentication to be available after the next request.
  #
  # You’d use this if, for instance, authentication failed and the user needs
  # to try it again.
  def still_authentication_needed!
    flash.keep :after_authentication
  end
  
  # Finish the after_authentication flow, which means the user will be
  # redirected ‘back’ to the page she originally requested _before_
  # authentication_needed! was called.
  #
  # This method returns +false+ if no authentication was needed, this way you
  # can easily specify a default redirection:
  #
  #   class SessionsController < ApplicationController
  #     def create
  #       # login code...
  #       finish_authentication_needed! or redirect_to(root_url)
  #     end
  #   end
  def finish_authentication_needed!
    if authentication_needed?
      flash.discard :after_authentication
      redirect_to after_authentication[:redirect_to]
    else
      false
    end
  end
end