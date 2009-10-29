module ActiveRecord
  module Validations #:nodoc:
    module ClassMethods
      local_part_illegal_chars = '[^@<>\(\)\[\]:;\\\\\s\.]'
      EMAIL_REGEXP = /^[^\.](#{local_part_illegal_chars}|\.#{local_part_illegal_chars})+@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
      
      # Takes a list of attributes that should be validated to be valid
      # formatted email addresses. Takes all other options that
      # validates_format_of does.
      #
      #   class Member < ActiveRecord::Base
      #     validates_email :email, :message => "is not a valid email address"
      #   end
      #
      # Note that the example message is the default.
      def validates_email(*attr_names)
        options = { :with => EMAIL_REGEXP, :message => "is not a valid email address" }
        options.merge!(attr_names.extract_options!)
        validates_format_of attr_names, options
      end
    end
  end
end