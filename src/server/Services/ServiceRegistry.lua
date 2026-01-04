local ServiceRegistry = {}

function ServiceRegistry.register(name, service)
	ServiceRegistry[name] = service
end

function ServiceRegistry.get(name)
	return ServiceRegistry[name]
end

return ServiceRegistry