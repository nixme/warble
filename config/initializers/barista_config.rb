Barista.configure do |c|
  # read from app/scripts and output to public/javascripts
  c.root        = Rails.root.join('app', 'scripts')
  c.output_root = Rails.root.join('public', 'javascripts')

  c.bare!   # don't wrap files in closures
end
