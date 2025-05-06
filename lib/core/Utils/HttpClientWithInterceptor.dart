import 'dart:convert';
import 'package:http/http.dart' as http;

/// A custom HTTP client that provides interception capabilities for HTTP requests.
/// This allows debugging, logging, and modifying requests and responses.
class HttpClientWithInterceptor {
  /// The underlying HTTP client
  final http.Client _client;

  /// Callback that intercepts and potentially modifies outgoing requests
  final Function(http.Request)? onRequest;

  /// Callback that intercepts incoming responses
  final Function(http.Response)? onResponse;

  /// Callback that handles errors during request processing
  final Function(dynamic)? onError;

  /// Creates a new HTTP client with interceptor capabilities
  ///
  /// Parameters:
  /// - `client`: Optional custom HTTP client; if not provided, a new client is created
  /// - `onRequest`: Optional callback to intercept and potentially modify outgoing requests
  /// - `onResponse`: Optional callback to process incoming responses
  /// - `onError`: Optional callback to handle errors
  HttpClientWithInterceptor({
    http.Client? client,
    this.onRequest,
    this.onResponse,
    this.onError,
  }) : _client = client ?? http.Client();

  /// Performs a GET request with optional headers
  Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
    final request = http.Request('GET', url);
    if (headers != null) request.headers.addAll(headers);
    return _sendRequest(request);
  }

  /// Performs a POST request with optional headers and body
  Future<http.Response> post(Uri url, {Map<String, String>? headers, Object? body}) async {
    final request = http.Request('POST', url);
    if (headers != null) request.headers.addAll(headers);
    if (body != null) {
      if (body is String) {
        request.body = body;
      } else {
        request.body = jsonEncode(body);
      }
    }
    return _sendRequest(request);
  }

  /// Performs a PUT request with optional headers and body
  Future<http.Response> put(Uri url, {Map<String, String>? headers, Object? body}) async {
    final request = http.Request('PUT', url);
    if (headers != null) request.headers.addAll(headers);
    if (body != null) {
      if (body is String) {
        request.body = body;
      } else {
        request.body = jsonEncode(body);
      }
    }
    return _sendRequest(request);
  }

  /// Performs a DELETE request with optional headers
  Future<http.Response> delete(Uri url, {Map<String, String>? headers}) async {
    final request = http.Request('DELETE', url);
    if (headers != null) request.headers.addAll(headers);
    return _sendRequest(request);
  }

  /// Performs a PATCH request with optional headers and body
  Future<http.Response> patch(Uri url, {Map<String, String>? headers, Object? body}) async {
    final request = http.Request('PATCH', url);
    if (headers != null) request.headers.addAll(headers);
    if (body != null) {
      if (body is String) {
        request.body = body;
      } else {
        request.body = jsonEncode(body);
      }
    }
    return _sendRequest(request);
  }

  /// Internal method to send the request with interceptor logic
  Future<http.Response> _sendRequest(http.Request request) async {
    try {
      // Call the request interceptor if provided
      if (onRequest != null) {
        onRequest!(request);
      }

      // Convert the request to a StreamedResponse
      final streamedResponse = await _client.send(request);

      // Convert the StreamedResponse to a Response
      final response = await http.Response.fromStream(streamedResponse);

      // Call the response interceptor if provided
      if (onResponse != null) {
        onResponse!(response);
      }

      return response;
    } catch (error) {
      // Call the error interceptor if provided
      if (onError != null) {
        onError!(error);
      }
      rethrow;
    }
  }

  /// Adds custom query parameters to a URI
  Uri addQueryParameters(Uri uri, Map<String, String> parameters) {
    return uri.replace(
      queryParameters: {
        ...uri.queryParameters,
        ...parameters,
      },
    );
  }

  /// Closes the client when it's no longer needed
  void close() {
    _client.close();
  }
}