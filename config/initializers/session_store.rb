# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_ankoder_worker_session',
  :secret      => '403f65933876d2ddd7679537d66b1d0037cfe0dd3a2b6ded6e810b2e0c02e283c9f5ef2e62ad40e2bff2bb3c137fec39771f905257ecf01be6a2e57327dc49de'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
