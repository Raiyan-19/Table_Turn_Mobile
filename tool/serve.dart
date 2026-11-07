// ignore_for_file: avoid_print, prefer_interpolation_to_compose_strings

import 'dart:io';

void main() async {
  const port = 3000;
  final server = await HttpServer.bind(InternetAddress.anyIPv4, port);
  print('Table Turn is running locally at: http://localhost:$port');
  print('Table Turn is accessible on your phone at: http://10.234.16.93:$port');

  await for (HttpRequest request in server) {
    try {
      var path = request.uri.path;
      if (path == '/' || path.isEmpty) path = '/index.html';
      var filePath = 'build/web' + path.replaceAll('/', Platform.pathSeparator);
      var file = File(filePath);

      if (await file.exists() && !(await FileSystemEntity.isDirectory(filePath))) {
        _setContentType(request.response, path);
        await file.openRead().pipe(request.response);
      } else {
        // Fallback to index.html for Flutter web SPA routing
        final indexFile = File('build${Platform.pathSeparator}web${Platform.pathSeparator}index.html');
        if (await indexFile.exists()) {
          request.response.headers.contentType = ContentType.html;
          await indexFile.openRead().pipe(request.response);
        } else {
          request.response.statusCode = HttpStatus.notFound;
          await request.response.close();
        }
      }
    } catch (e) {
      try {
        request.response.statusCode = HttpStatus.internalServerError;
        await request.response.close();
      } catch (_) {}
    }
  }
}

void _setContentType(HttpResponse response, String path) {
  final lower = path.toLowerCase();
  if (lower.endsWith('.html')) {
    response.headers.contentType = ContentType.html;
  } else if (lower.endsWith('.js') || lower.endsWith('.mjs')) {
    response.headers.contentType = ContentType('application', 'javascript', charset: 'utf-8');
  } else if (lower.endsWith('.css')) {
    response.headers.contentType = ContentType('text', 'css', charset: 'utf-8');
  } else if (lower.endsWith('.json')) {
    response.headers.contentType = ContentType.json;
  } else if (lower.endsWith('.png')) {
    response.headers.contentType = ContentType('image', 'png');
  } else if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) {
    response.headers.contentType = ContentType('image', 'jpeg');
  } else if (lower.endsWith('.svg')) {
    response.headers.contentType = ContentType('image', 'svg+xml');
  } else if (lower.endsWith('.wasm')) {
    response.headers.contentType = ContentType('application', 'wasm');
  } else if (lower.endsWith('.ttf') || lower.endsWith('.otf') || lower.endsWith('.woff') || lower.endsWith('.woff2')) {
    response.headers.contentType = ContentType('font', 'ttf');
  }
}

