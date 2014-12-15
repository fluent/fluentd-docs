# record_transformer Filter Plugin

The `filter_record_transformer` filter plugin mutates/transforms incoming event streams in a versatile manner. If there is a need to add/delete/modify events, this plugin is the first filter to try.

## Example Configurations

`filter_record_modifier` is included in Fluentd's core. No installation required.

    :::text
    <filter foo.bar>
      type record_transformer
      <record>
        hostname "#{Socket.gethostname}"
      </record>
    </filter>

The above filter adds the new field "hostname" with the server's hostname as its value (It is taking advantage of Ruby's string interpolation). So, an input like

    :::text
    {"message":"hello world!"}

is transformed into

    :::text
    {"message":"hello world!", "hostname":"db001.internal.example.com"}

Here is another example where the field "total" is divided by the field "count" to create a new field "avg":

    :::text
    <filter foo.bar>
      type record_transformer
      enable_ruby
      <record>
        avg ${total/count}
      </record>
    </filter>        

It transforms an event like

    :::text
    {"total":100, "count":10}

into

    :::text
    {"total":100, "count":10, "avg":"10"}

With the `enable_ruby` option, an arbitrary Ruby expression can be used inside `${...}`. Note that the "avg" field is typed as string. Currently, `${...}` always returns strings.

Finally, this configuration embeds the value of the second part of the tag in the field "service_name". It might come in handy when aggregating data across many services.

    :::text
    <filter web.*>
      type record_transformer
      <record>
        service_name ${tag_parts[1]}
      </record>
    </filter>

So, if an event with the tag "web.auth" and record `{"user_id":1, "status":"ok"}` comes in, it transforms it into `{"user_id":1, "status":"ok", "service_name":"auth"}`.

## Parameters

### <record> directive

Parameters inside `<record>` directives are considered to be new key-value pairs:

    :::text
    <record>
      NEW_FIELD NEW_VALUE
    </record>

For NEW_VALUE, a special syntax `${}` allows the user to generate a new field dynamically. Inside the curly braces, the following variables are available:

- The incoming event's existing values can be referred by their field names. So, if the record is `{"total":100, "count":10}`, then `total=10` and `count=10`.
- `tag_parts[N]` refers to the Nth part of the tag. It works like the usual zero-based array accessor.
- `tag_prefix[N]` refers to the first N parts of the tag. It works like the usual zero-based array accessor.
- `tag_suffix[N]` refers to the last N parts of the tag. It works like the usual zero-based array accessor.
- `tag` refers to the whole tag.

### enable_ruby (optional)

When set to true, the full Ruby syntax is enabled in the `${...}` expression. The default value is false.

### renew_record (optional)

By default, the record transformer filter mutates the incoming data. However, if this parameter is set to true, it modifies a new empty hash instead.

### keep_keys (optional, string type)

A comma-delimited list of keys to keep. Only relevant if `renew_record` is set to true.

### remove_keys (optional, string type)

A comma-delimited list of keys to delete.

## Learn More

- [Filter Plugin Overview](filter-plugin-overview)
- [grep Filter Plugin](filter_grep)