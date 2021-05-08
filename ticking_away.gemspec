lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift lib unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |s|
  s.name        = 'ticking_away'
  s.version     = '0.0.1'
  s.summary     = "IRC Chat Bot for time shenanigans"
  s.authors     = ["Jeff Wood"]
  s.email       = 'woodjeffrey2@gmail.com'
  s.files       = Dir['lib/**/*']
  s.homepage    =
    'https://github.com/woodjeffrey2/ticking_away'
  s.license       = 'MIT'
  s.add_runtime_dependency 'cinch', '2.3.4' 
end