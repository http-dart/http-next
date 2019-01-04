# HTTP Client Middleware for Dart

[![Build Status](https://cloud.drone.io/api/badges/http-dart/http-next/status.svg)](https://cloud.drone.io/http-dart/http-next)

## Introduction

A composable, Future-based library for making HTTP requests.

This package contains a set of high-level functions and classes that make it
easy to consume HTTP resources. It's platform-independent, and can be used on
both the command-line and the browser.

## Using

The easiest way to use this library is via the top-level functions. They allow
you to make individual HTTP requests with minimal hassle:

```dart
import 'package:http_next/http.dart' as http;

Future<void> main() async {
  const url = 'https://httpbin.org/post';
  final response = await http.post(url, <String, String>{
    'name': 'doodle',
    'color': 'blue',
  });
  final responseText = await response.readAsString();

  print(response.statusCode);
  print(responseText);
}
```

If you're making multiple requests to the same server, you can keep open a
persistent connection by using a [Client]() rather than making one-off requests.
If you do this, make sure to close the client when you're done:

```dart
const url = 'https://httpbin.org/post';
final client = http.Client();
final response = await client.post(url, <String, String>{
  'name': 'doodle',
  'color': 'blue',
});
final responseText = await response.readAsString();

print(response.statusCode);
print(responseText);

client.close();
```

You can also exert more fine-grained control over your requests and responses by
creating [Request][] or [StreamedRequest][] objects yourself and passing them to
[Client.send][].

[Request]: https://www.dartdocs.org/documentation/http/latest/http/Request-class.html
[StreamedRequest]: https://www.dartdocs.org/documentation/http/latest/http/StreamedRequest-class.html
[Client.send]: https://www.dartdocs.org/documentation/http/latest/http/Client/send.html

This package is designed to be composable. This makes it easy for external
libraries to work with one another to add behavior to it. Libraries wishing to
add behavior should create a subclass of [BaseClient][] that wraps another
[Client][] and adds the desired behavior:

[BaseClient]: https://www.dartdocs.org/documentation/http/latest/http/BaseClient-class.html
[Client]: https://www.dartdocs.org/documentation/http/latest/http/Client-class.html

```dart
class UserAgentClient extends http.BaseClient {
  final String userAgent;
  final http.Client _inner;

  UserAgentClient(this.userAgent, this._inner);

  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['user-agent'] = userAgent;
    return _inner.send(request);
  }
}
```

## Origins

Originally `http_next` was a reworking of the original
[http](https://github.com/dart-lang/http) package to provide an interface
similar to [shelf](https://github.com/dart-lang/shelf). After the reworking was
completed the Dart team decided to stick with the original implementation, due
to the large amount of breaking changes, and moved the work to an
[experimental branch](https://github.com/dart-lang/http/tree/experimental). The
`http_next` library is a fork of that branch.

Thanks go out to @nex3 who supervised the reworking.