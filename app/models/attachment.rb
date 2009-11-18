class Attachment < ActiveRecord::Base
  attachment_san :filename_scheme => :token, :public_base_path => '/attachments'
  
  before_create :generate_token
  
  private
  
  def generate_token
    self.token = Token.generate
  end
end
