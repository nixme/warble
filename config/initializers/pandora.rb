# Instantiate a global Pandora client for API calls.
# Pandora partner credentials must be provided via environment variables.
$pandora_partner = Pandora::Partner.new(
  ENV['PANDORA_PARTNER_USERNAME'],
  ENV['PANDORA_PARTNER_PASSWORD'],
  ENV['PANDORA_PARTNER_DEVICE_ID'],
  ENV['PANDORA_PARTNER_ENCRYPTION_KEY'],
  ENV['PANDORA_PARTNER_DECRYPTION_KEY']
)
