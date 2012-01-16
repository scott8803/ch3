class User < ActiveRecord::Base

# == Schema Information
#
# Table name: users
#
#  id                 :integer         not null, primary key
#  name               :string(255)
#  email              :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  encrypted_password :string(255)
#  salt               :string(255)
#  admin              :boolean         default(FALSE)
#

	attr_accessor :password
  attr_accessible :name, :email, :password, :password_confirmation
 	
	email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i	

	validates :name, 	:presence => true, 
										:length => {:maximum => 50 }
	validates :email, :presence => true, 
										:format => {:with => email_regex},
										:uniqueness => true
  # Automatically create the virtual attribute 'password_confirmation'.
  validates :password, :presence     => true,
                       :confirmation => true,
                       :length       => { :within => 6..40 },
                       :on => :create

  before_create :encrypt_password

	def has_password?(submitted_password)
		encrypted_password == encrypt(submitted_password)
	end
	
	def self.authenticate(email,submitted_password)
		user = find_by_email(email)
    return nil  if user.nil?
    return user if user.has_password?(submitted_password)
	end

	def self.authenticate_with_salt(id, cookie_salt)
		user = find_by_id(id)
		return nil  if user.nil?
		return user if user.salt == cookie_salt
	end

  private
    def encrypt_password
      self.salt = make_salt unless has_password?(password)
      self.encrypted_password = encrypt(password)
    end
	  #include CryptoLib
    def encrypt(string)
      CryptoLib::secure_hash("#{salt}--#{string}")
    end

    def make_salt
      CryptoLib::secure_hash("#{Time.now.utc}--#{password}")
    end

end



