Barista.configure do |c|
  # read coffeescripts from app/scripts
  c.root = Rails.root.join('app', 'scripts')

  # output javascript to public/javascripts
  c.output_root = Rails.root.join('public', 'javascripts')

  # don't wrap files in closures
  c.no_wrap!
end
