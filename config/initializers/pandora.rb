# Create a shared Pandora partner client if keys are available.

if ENV['PANDORA_USERNAME'].present?
  $pandora_partner = Pandora::Partner.new(
    ENV['PANDORA_USERNAME'],
    ENV['PANDORA_PASSWORD'],
    ENV['PANDORA_DEVICE_ID'],
    ENV['PANDORA_ENCRYPTION_KEY'],
    ENV['PANDORA_DECRYPTION_KEY']
  )
end
