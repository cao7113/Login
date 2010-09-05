# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_Login_session',
  :secret      => 'cb307b94c4c6a21d265d262ce697d09d0932d3f0053a93e5bce4c31557f9881d4a528b0be9a7b736f90fc58066665e566a62f45428e4a1ffb424bf22d40e8e64'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
