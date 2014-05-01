# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard :rspec do

  # # watch /lib/ files
  # watch(%r{^lib/(.+).rb$}) do |m|
  #   "spec/#{m[1]}_spec.rb"
  # end
 
  # # watch /spec/ files
  # watch(%r{^spec/(.+).rb$}) do |m|
  #   "spec/#{m[1]}.rb"
  # end

  watch(%r{^spec/.+_spec\.rb$})
  # watch(%r{^lib/(.+)\.rb$})     { |m| "spec/#{m[1]}_spec.rb" }
  watch(%r{^(hanoi)\.rb$})     { |m| "spec/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')  { "spec" }

end

