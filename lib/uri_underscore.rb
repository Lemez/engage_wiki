# config/initializers/uri_underscore.rb
class URI::Generic
  def initialize_with_registry_check(scheme,
                 userinfo, host, port, registry,
                 path, opaque,
                 query,
                 fragment,
                 parser = DEFAULT_PARSER,
                 arg_check = false)
    if %w(http https).include?(scheme) && host.nil? && registry =~ /_/
      initialize_without_registry_check(scheme, userinfo, registry, port, nil, path, opaque, query, fragment, parser, arg_check)
    else
      initialize_without_registry_check(scheme, userinfo, host, port, registry, path, opaque, query, fragment, parser, arg_check)
    end
  end
  alias_method_chain :initialize, :registry_check
end