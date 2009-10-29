require 'active_record_ext'

ActiveRecord::Base.send(:extend, ActiveRecord::Ext)
ActiveRecord::Base.send(:include, ActiveRecord::BasicScopes)