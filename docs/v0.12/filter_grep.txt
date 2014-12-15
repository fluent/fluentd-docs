# grep Filter Plugin

The `filter_grep` filter plugin "greps" events by the values of specified fields.

## Example Configurations

`filter_grep` is included in Fluentd's core. No installation required.

    :::text
    <filter foo.bar>
      type grep
      regexp1 message cool
      regexp2 hostname ^web\d+\.example\.com$
      exclude1 message uncool
    </filter>

The above example matches any event that satisfies the following conditions:

1. The value of the "message" field contains "cool"
2. The value of the "hostname" field matches `web<INTEGER>.example.com`.
3. The value of the "message" field does NOT contain "uncool".

Hence, the following events are kept:

    :::text
    {"message":"It's cool outside today", "hostname":"web001.example.com"}
    {"message":"That's not cool", "hostname":"web1337.example.com"}

whereas the following examples are filtered out:

    :::text
    {"message":"I am cool but you are uncool", "hostname":"db001.example.com"}
    {"hostname":"web001.example.com"}
    {"message":"It's cool outside today"}

## Parameters

### regexpN (optional)

The "N" at the end should be replaced with an integer between 1 and 20 (ex: "regexp1"). regexpN takes two whitespace-delimited arguments.

- The first argument is the field name to which the regular expression is applied.
- The second argument is the regular expression.

For example, the following filters out events unless the field "price" is a positive integer.

    :::text
    regexp1  [1-9]\d*

The grep filter filters out UNLESS all regexpN's are matched. Hence, if you have

    :::text
    regexp1 price     [1-9]\d*
    regexp2 item_name ^book_

unless the event's "item_name" field starts with "book_" and the "price" field is an integer, it is filtered out.

### excludeN (optional)

The "N" at the end should be replaced with an integer between 1 and 20 (ex: "exclude1"). excludeN takes two whitespace-delimited arguments.

- The first argument is the field name to which the regular expression is applied.
- The second argument is the regular expression.

For example, the following filters out events whose "status_code" field is 5xx.

    :::text
    exclude1 status_code ^5\d\d$

The grep filter filters out if any excludeN is matched. Hence, if you have

    :::text
    exclude1 status_code ^5\d\d$
    exclude2 url \.css$

Then, any event whose "status_code" is 5xx OR "url" ends with ".css" is filtered out.

NOTE: If <code>regexpN</code> and <code>excludeN</code> are used together, both are applied.


## Learn More

- [Filter Plugin Overview](filter-plugin-overview)
- [record_transformer Filter Plugin](filter_record_transformer)