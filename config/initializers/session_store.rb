# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_paper_cups_session',
  :secret      => '4010273d7797f0cfb1c468dbc9cd8100d478a2b89dc28bd8408d26224c9e1680221f8dfff87fd6d055d57e85591928b7a69dd67ed3e97b69199ede5d8ee22deb'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
