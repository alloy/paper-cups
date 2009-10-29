require 'authentication_needed_san'
ActionController::Base.send(:include, AuthenticationNeededSan)