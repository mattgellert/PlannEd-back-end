ActiveModelSerializers.config.adapter = :json_api
#tells Rails to serialize our data in the JSON API format

api_mime_types = %W(
  application/vnd.api+json
  text/x-json
  application/json
)
Mime::Type.register 'application/vnd.api+json', :json, api_mime_types
#tells app to accept JSON API mime type when receiving data
