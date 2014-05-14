Expressr
=======
Express.js for Ruby

Overview
--------

Expressr brings the architecture of Express.js to Ruby. It's a minimal and flexible web application framework that couples the concepts of Express.js and Node.js with the beauty of Ruby.

Expressr runs on [Noder](https://github.com/tombenner/noder) (Node.js for Ruby), which runs on [EventMachine](https://github.com/eventmachine/eventmachine).

Quick Start
-----------

A web app can be created and started using the following script:

```ruby
require 'expressr'

app = Expressr::App.new

app.get('/hello.txt') do |request, response|
  response.out('Hello World')
end

app.listen(3000)
```

To start the app, put the code into a file named `my_app.rb` and run it:

```bash
$ ruby my_app.rb
Running Noder at 0.0.0.0:3000...
```

Examples
--------

Here are some other examples of common usage:

```ruby
require 'expressr'

app = Expressr::App.new

# Log every request to URLs beginning with /admin/
app.all('/admin/*') do |request, response|
  Noder.logger.info "#{request.locals.user} accessed #{request.url}"
end

# Render JSON
app.get('/some_json') do |request, response|
  response.out({ some: 'json' })
end

# Render a view
app.get('/users/:id') do (request, response)
  Noder.with ->{ User.find(request.params.id) } do |user|
    response.render('users/show', user: user.attributes)
  end
end

# Respond to a POST request by creating a record and then redirecting
app.post('/comment') do |request, response|
  Noder.with ->{ Comment.create(request.params.comment) } do |comment|
    response.redirect("/comment/#{comment.id}")
  endd
end

app.listen(3000)
```

See the API section below for complete documentation.

Please note that the datastore-related lines in the examples above will block the event loop as written. You'll want to use [EM-Synchrony](https://github.com/igrigorik/em-synchrony)'s support for whichever datastore you're using and for other IO operations.

API
---

* [App](#expressrapp)
* [Request](#expressrrequest)
* [Response](#expressrresponse)
* [Router](#expressrrouter)

### Expressr::App

`Expressr::App` lets you create and run web apps.

#### Settings

An app has settings which configure it:

* `'jsonp callback name'` - The param used for determining the JSONP callback's name. The default is `'callback'` (e.g. for `?callback=myFunction`).
* `'locals'` - A hash of name-value pairs that will be passed to views as local variables.
* `'root'` - The root directory of the app. This is set automatically.
* `'view engine'` - The template engine used for views. The default is `'slim'`, and `'haml'` is also supported.
* `'views'` - The path to the views within the app's root directory. The default value is `'views'`.

Settings can be set using `#set` and retrieved using `#get`:

```ruby
app.set('view engine', 'haml')
app.get('view engine') # "haml"
```

A hash of all settings can be accessed by using `app.settings`.

#### .new(server_options={})

Creates the app.

##### server_options

Please see [Noder's docs](https://github.com/tombenner/noder) for the options that can be passed to `Noder::HTTP::Server`. These include options like the server's address, port, whether HTTPS is enabled, etc.

#### #set(name, value)

Sets the value of a setting.

#### #get(name)

Gets the value of a setting.

#### #enable(name)

Sets the value of a setting to `true`.

#### #disable(name)

Sets the value of a setting to `false`.

#### #enabled?(name)

Returns a boolean of whether the setting is enabled or not.

#### #disabled?(name)

Returns a boolean of whether the setting is disabled or not.

#### #engine(value)

Sets the view engine. This is the equivalent of `set('view engine', value)`. Valid values are `'slim'` and `'haml'`.

#### #param(name, &block)

Registers a listener for any request that includes the specified param. For example, in a request is made to `/user/5` (with a `/user/:user_id` route) or `/profile?user_id=5`, the following will the log the `user_id` value:

```ruby
app.param('user_id') do |request, response, continue, user_id|
  user = User.find(user_id)
  if user
    request.locals.user = user
  else
    Noder.logger.info "User not found: #{user_id}"
  end
end
```

#### #VERB(path, &block)

Registers a listener for any request that matches the VERB (e.g. `get`, `post`, `put`, `delete`) and the path.

Respond with `Welcome!` for GET requests to `/welcome`:

```ruby
app.get('/welcome') do |request, response|
  response.out('Welcome!')
end
```

Respond with JSON for POST requests to `/user/5/settings`:

```ruby
app.post('/user/:id/settings') do |request, response|
  response.out({
    user_id: request.params.id,
    params: request.params
  })
end
```

Regular expressions can also be used:

```ruby
app.get(/^\/commits\/(\w+)\.\.(\w+)/) do |request, response|
  response.out({
    from: request.params[0],
    to: request.params[1]
  })
end
```

#### #all(path, &block)

This method functions just like the `#VERB(path, &block)` method, but it matches all HTTP verbs.

It's very useful for creating global logic for all requests or for requests to specific paths:

```ruby
app.all('/admin/*') do |request, response|
  if !is_admin?
    response.status = 403
    response.out('Not authorized.')
  end
end
```

#### #route(path)

Returns an instance of a single route which can then be used to handle HTTP verbs with optional middleware. Using `#route(path)` is a recommended approach to avoiding duplicate route naming and thus typo errors.

```ruby
app.route('/users').
all do |request, response|
  Noder.logger.info "Users request performed"
end.
get do |request, response|
  response.out(User.find(request.params.user_id))
end.
post do |request, response|
  user = User.create(request.params.user)
  response.out(user.attributes)
end
```

#### #locals

Application local variables are provided to all templates rendered within the application. This is useful for providing helper functions to templates, as well as app-level data.

```ruby
app.locals.site_name = 'My Site'
app.locals.contact_email = 'contact@mysite.com'
```

#### #listen(port=nil, address=nil, &block)

Bind and listen for connections on the given host and port. This method is identical to Noder's `Noder::HTTP::Server#listen`.

```ruby
app = Expressr::App.new
app.get('/hello.txt') do |request, response|
  response.out('Hello World')
end
app.listen(3000)
```

A block which will be called for all requests can be passed to it, too:

```ruby
app = Expressr::App.new
app.listen do |request, response|
  response.out('Hello World')
end
```

#### #close

Stops the app. This is the same as Noder's `Noder::HTTP::Server#close` and is called when an `INT` or `TERM` signal is sent to a running server's process (e.g. when `Control-C` is pressed).

#### #settings

A hash of the app's settings:

```ruby
app.set('my setting', 'My value')
value = app.settings['my setting']
```

### Expressr::Request

`Expressr::Request` inherits from (and thus also includes methods from)  `Noder::HTTP::Request`.

#### #params

Similar to Rails' `params`, this includes params from the query string, POST data, and route parameters. Params can be accessed in three ways: `params.user_id`, `params[:user_id]`, or `params['user_id']`.

For example, a request to `/user/3?comment_id=4` will include two params:

```ruby
app.get('/user/:user_id') do |request, response|
  response.out({
    user_id: request.params.user_id,
    comment_id: request.params.comment_id
  })
end
```

If a regex route is used, the matches can be accessed at their integer indexes:

```ruby
app.get(/\/user\/(\d+)\/comment\/(\d+)/) do |request, response|
  response.out({
    user_id: request.params[0],
    comment_id: request.params[1]
  })
end
```

#### #query

Similar to `#params`, but it only includes params from the query string.

For example, a request to `/user/3?comment_id=4` will only include `comment_id`:

```ruby
app.get('/user/:user_id') do |request, response|
  response.out({
    comment_id: request.query.comment_id
  })
end
```

#### #param(name)

Returns the value of param `name` when present. This is the equivalent of `params.name` or `params[name]`, which are the preferred forms.

```ruby
request.param('user_id')
```

#### #get(name)

Returns the value of the `name` header when present.

```ruby
request.get('Content-Type') # "text/plain"
request.get('Something') # nil
```

Aliased as `#header(name)`.

#### #accepts(types)

Check if the given types are acceptable, returning the best match when true, otherwise `nil`.

```ruby
# Accept: text/*, application/json
request.accepts('text/html') # "text/html"
request.accepts('image/png') # nil
```

#### #is?(type)

Check if the given types are acceptable, returning the best match when true, otherwise `nil`.

```ruby
# Content-Type: text/html; charset=utf-8
request.is('text/html') # true
request.is('image/png') # false
```

#### #ip

Returns the remote IP address.

```ruby
request.ip # "68.1.8.45"
```

#### #path

Returns the path of the requested URL.

```ruby
# example.com/users?sort=desc
request.path # "/users"
```

#### #host

Returns the hostname from the "Host" header field (without the port).

```ruby
# Host: "example.com:3000"
request.host # "example.com"
```

#### #xhr?

Check whether the request was issued with the "X-Requested-With" header field set to "XMLHttpRequest" (jQuery etc).

```ruby
# Host: "example.com:3000"
request.xhr? # false
```

#### #protocol

Returns the protocol string of the request (e.g. `'http'`, `'https'`).

```ruby
# "http://example.com/"
request.protocol # 'http'
```

#### #secure?

Checks whether a TLS connection is established. This is the equivalent of `request.protocol == 'https'`.

```ruby
# "http://example.com/"
request.secure? # false
```

#### #subdomains

Returns the subdomains as an array

```ruby
# Host: "tobi.ferrets.example.com"
request.subdomains # ["ferrets", "tobi"]
```

#### #original_url

This is similar to `#url`, except that it retains the original URL, allowing you to rewrite `#url` freely.

```ruby
# /search?q=something
request.original_url # "/search?q=something"
```

### Expressr::Response

`Expressr::Response` inherits from (and thus also includes methods from)  `Noder::HTTP::Response`.

#### #set(name, value=nil)

Set a header's value, or pass a hash as a single argument to set multiple headers at once.

```ruby
response.set('Content-Type', 'text/plain')
response.set({
  'Content-Type' => 'text/plain',
  'Content-Length' => '123',
  'ETag' => '12345'
})
```

#### #get(name)

Returns a header's value.

```ruby
response.get('Content-Type') # "text/plain"
```

#### #cookie(name, value, options={})

Sets a cookie. All of the options supported by [CGI::Cookie](http://ruby-doc.org/stdlib-1.9.3/libdoc/cgi/rdoc/CGI/Cookie.html) are supported.

```ruby
response.cookie('user_id', '15')
response.cookie('remember_me', '1', {
  'expires' => Time.now + 14.days,
  'domain' => 'example.com'
})
```

#### #clear_cookie(name, value, options={})

Sets a cookie. All of the options supported by [CGI::Cookie](http://ruby-doc.org/stdlib-1.9.3/libdoc/cgi/rdoc/CGI/Cookie.html) are supported.

```ruby
response.cookie('user_id', '15')
response.clear_cookie('user_id')
```

#### #redirect(status_or_url, url=nil)

Redirects to the specified URL with an optional status (default is `302`).

```ruby
response.redirect('/foo/bar')
response.redirect(303, '/foo/bar')
response.redirect('https://www.google.com')
```

#### #location(url)

Sets the `Location` header's value.

```ruby
response.location('/foo/bar')
response.location('https://www.google.com')
```

#### #out(status_or_content=nil, content=nil)

Sends the response. (This is the equivalent of Express.js's `send` method, which has another use in Ruby.)

```ruby
response.out({ some: 'json' })
response.out('some html')
response.out(404, 'Sorry, we cannot find that!')
response.out(500, { error: 'something blew up' })
response.out(200)
```

When the content is a string, the Content-Type is set to `text/html`.

When the content is a hash, the hash is converted to JSON and the Content-Type is set to `application/json`.

#### #json(status_or_content=nil, content=nil)

Sends a JSON response. This identical to `#out` when an array or object is passed.

```ruby
response.json({ some: 'json' })
response.json(500, { error: 'something blew up' })
```

#### #jsonp(status_or_content=nil, content=nil)

Sends a JSONP response. This identical to `#json`, but it provides JSONP support if the request specifies a JSONP callback.

```ruby
# /?callback=foo
response.jsonp({ some: 'json' }) # "foo({"some":"json"});"
# /
response.jsonp({ some: 'json' }) # "{"some":"json"}"
```

The JSONP callback name defaults to `'callback'`, but it can be set using the app's settings:

```ruby
app.settings.set('jsonp callback name', 'cb')
# /?cb=foo
response.jsonp({ some: 'json' }) # "foo({"some":"json"});"
```

#### #type(value)

Sets the `Content-Type` header to the value.

```ruby
response.type('html')
response.type('application/json')
```

#### #format(hash)

Performs content-negotiation on the request Accept header field when present.

```ruby
response.format({
  'text/html' => proc { |request, response|
    response.out("<h3>Some HTML</h3>")
  },
  'text/plain' => proc { |request, response|
      response.out("Some text")
  },
  'application/json' => proc { |request, response|
    response.out({ some: json })
  },
})
```

Content type synonyms are supported (e.g. `'json'` and `'application/json'` are equivalent):

```ruby
response.format({
  'html' => proc { |request, response|
    response.out("<h3>Some HTML</h3>")
  },
  'text' => proc { |request, response|
      response.out("Some text")
  },
  'json' => proc { |request, response|
    response.out({ some: json })
  },
})
```

#### #attachment(filename=nil)

Sets the Content-Disposition header field to "attachment". If a filename is given then the Content-Type will be automatically set based on the extension via `#type`, and the Content-Disposition's "filename=" parameter will be set.

```ruby
response.attachment
# Content-Disposition: attachment

response.attachment('path/to/logo.png')
# Content-Disposition: attachment; filename="logo.png"
# Content-Type: image/png
```

#### #send_file(path, options={})

Transfers the file at the given path.

Automatically defaults the Content-Type response header field based on the filename's extension.

##### options

  * `root` - Root directory for relative filenames

```ruby
app.get('/user/:uid/photos/:file') do |request, response|
  uid = request.params.uid
  file = request.params.file

  if request.locals.user.may_view_files_from(uid)
    response.sendfile("/uploads/#{uid}/#{file}")
  else
    response.out(403, "Sorry! You can't see that.")
  end
end
```

#### #download(path, filename=nil)

Transfer the file at path as an "attachment". Typically browsers will prompt the user for download. The Content-Disposition "filename=" parameter (the one that will appear in the brower dialog is set to path by default), but you can also provide an override filename.

```ruby
response.download('/report-12345.pdf')
response.download('/report-12345.pdf', 'report.pdf')
```

#### #links(links)

Join the given links to populate the "Link" response header field.

```ruby
response.links({
  next: 'http://api.example.com/users?page=2',
  last: 'http://api.example.com/users?page=5'
})

# Link: <http://api.example.com/users?page=2>; rel="next",
#       <http://api.example.com/users?page=5>; rel="last"
```

#### #locals

Response local variables are scoped to the request, thus only available to the view(s) rendered during that request / response cycle, if any.

This object is useful for exposing request-level information such as the request pathname, authenticated user, user settings, etc.

```ruby
app.use do (request, response)
  response.locals.user = User.find(request.params.user_id)
  response.locals.authenticated = !response.locals.user.is_anonymous?
end
```

#### #render(view, locals=nil, &block)

Renders a `view`. The view's local variables are supplied by both the `locals` argument and the app's `locals` setting. If the rendering raises an exception, the `&block` is called with the exception as an argument.

```ruby
app.get('/users/:id') do (request, response)
  user = User.find(request.params.id)
  response.render('profile', user: user.attributes)
end

app.get('/contact') do (request, response)
  response.render('contact') do |exception|
    response.render('error')
  end
end
```

To set the locals that will be passed to all views, use:

```ruby
app.locals.site_name = 'My Site'
app.locals.contact_email = 'contact@mysite.com'
```

By default, Expressr looks for views in the `views` directory (e.g. `views/profile.slim`).

To set the directory of the views, use:

```ruby
app.set('views', File.expand_path('../my_views', __FILE__))
```

Expressr uses the Slim template engine by default, but it also supports Haml:

```ruby
app.set('view engine', 'haml')
```

If you'd like to add support for other template engines, doing so is fairly straightforward; just grep for `'slim'` in the codebase, and the steps needed to support a new engine should be clear.

### Expressr::Router

`Expressr::App` lets you create routes for your app. An app's router can be accessed at `app.router`.

```ruby
app = Expressr::App.new
app.router.get('/hello.txt') do |request, response|
  response.out('Hello World')
end
```

#### #use(path=nil, &block)

Please see the documentation for `Expressr::App#use`, which has the same behavior.

#### #param(name, &block)

Please see the documentation for `Expressr::App#use`, which has the same behavior.

#### #use(path=nil, &block)

Please see the documentation for `Expressr::App#use`, which has the same behavior.

#### #VERB(path, &block)

Please see the documentation for `Expressr::App#use`, which has the same behavior.

#### #use(path=nil, &block)

Please see the documentation for `Expressr::App#use`, which has the same behavior.

#### #use(path=nil, &block)

Please see the documentation for `Expressr::App#use`, which has the same behavior.

#### #use(path=nil, &block)

Please see the documentation for `Expressr::App#use`, which has the same behavior.

Notes
-----

Expressr is not currently a full implementation of Express.js, and some of its underlying architecture differs from Express.js's. If you see any places where it could be improved or added to, absolutely feel free to submit a PR.

License
-------

Expressr is released under the MIT License. Please see the MIT-LICENSE file for details.
