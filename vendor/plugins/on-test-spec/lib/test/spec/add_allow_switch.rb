require 'active_support'

class Class
  def add_allow_switch(method, options={})
    default = options[:default] || false
    
    class_eval do
      cattr_accessor "allow_#{method}"
      self.send("allow_#{method}=", default)
      
      alias_method "original_#{method}", method
      
      eval %{
        def #{method}(*args)
          if allow_#{method}
            original_#{method}(*args)
          else
            raise RuntimeError, "You're trying to call `#{method}' on `#{self}', which you probably don't want in a test."
          end
        end
      }, binding, __FILE__, __LINE__
    end
  end
end

class Module
  def add_allow_switch(method, options={})
    default = options[:default] || false
    
    mattr_accessor "allow_#{method}"
    send("allow_#{method}=", default)
    
    unless respond_to?(:__metaclass___)
      def __metaclass__
        class << self; self; end
      end
    end
    
    __metaclass__.class_eval do
      alias_method "original_#{method}", method
      
      eval %{
        def #{method}(*args)
          if allow_#{method}
            original_#{method}(*args)
          else
            raise RuntimeError, "You're trying to call `#{method}' on `#{self}', which you probably don't want in a test."
          end
        end
      }, binding, __FILE__, __LINE__
    end
  end  
end