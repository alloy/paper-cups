# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_camping-gas_session',
  :secret      => 'fb974c6134ec0b528bc5ed09c6866033b5b8318fae6f738c6af91708de13a3a65139a480638a03e3c3c469709f3ac2916c260906a0025fa239bca3b96b10d7d5'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
