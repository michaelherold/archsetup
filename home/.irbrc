begin
  # Use Pry everywhere
  require 'pry'
rescue LoadError
end

if defined? Pry
  Pry.start
  exit
else

end
