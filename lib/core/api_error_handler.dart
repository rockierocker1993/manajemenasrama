import 'dart:convert';

import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../shared/models/base_response.dart';

/// Run an async API action and show a popup dialog if it throws an error.
///
/// - action: a closure that performs the API call and returns a value.
/// - On success the function returns the action's value.
/// - On error the function shows an AlertDialog containing a friendly
///   message derived from the thrown exception and returns null.
///
/// Success UI (toasts/dialogs) should be handled by the caller manually.
Future<T?> runApiCall<T>(
  Future<T> Function() action,
  BuildContext context,
) async {
  try {
    final res = await action();

    // If the action returned a wrapped BaseResponse with explicit status=false,
    // show a popup with backend title/message and treat it as error (return null).
    if (res is BaseResponse) {
      if (res.status == false) {
        final title = res.titleEn ?? res.titleId ?? 'Gagal';
        final message = res.message ?? res.messageId ?? res.messageEn ?? '';
        final nav = Navigator.of(context);
        if (nav.mounted)
          await _showErrorDialog(nav.context, '$title\n\n$message');
        return null;
      }
    }

    return res;
  } on AppAuthException catch (e) {
    final nav = Navigator.of(context);
    if (nav.mounted) await _showErrorDialog(nav.context, e.message);
    return null;
  } catch (e) {
    // If this is a BackendApiException, try to extract title/message from
    // the response body. BackendApiException is defined in BackendApiClient
    // and contains `body` and `message` fields; however we don't import it
    // here to avoid circular deps, so check for the common shape.
    try {
      // Many HTTP client wrappers throw exceptions that have `body` or
      // `response` fields. Try to extract a map-like body.
      final obj = e as dynamic;
      final body = obj.body ?? obj.response?.body ?? obj.bodyBytes;
      if (body != null) {
        // If body is a string, try to decode JSON.
        dynamic decoded = body;
        if (body is String) {
          try {
            decoded = jsonDecode(body);
          } catch (_) {
            decoded = null;
          }
        }
        if (decoded is Map<String, dynamic>) {
          final title = (decoded['title_en'] ?? decoded['title_id'])
              ?.toString();
          final message =
              (decoded['message'] ??
                      decoded['message_id'] ??
                      decoded['message_en'])
                  ?.toString();
          if (title != null || message != null) {
            final nav = Navigator.of(context);
            if (nav.mounted)
              await _showErrorDialog(
                nav.context,
                '${title ?? 'Gagal'}\n\n${message ?? ''}',
              );
            return null;
          }
        }
      }
    } catch (_) {
      // ignore extraction errors and fall back to generic message
    }

    // Fallback: show generic error including exception.toString().
    final nav2 = Navigator.of(context);
    if (nav2.mounted) await _showErrorDialog(nav2.context, e.toString());
    return null;
  }
}

Future<void> _showErrorDialog(BuildContext context, String message) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Terjadi Kesalahan'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Tutup'),
        ),
      ],
    ),
  );
}
