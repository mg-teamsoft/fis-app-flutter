enum ErrorType {
  error('❌', 'Error'),
  warning('⚠️', 'Warning'),
  info('ℹ️', 'Info');

  const ErrorType(this.icon, this.text);
  final String icon;
  final String text;
}

class ErrorFlag {
  ErrorFlag({
    required ErrorType type,
    required int code,
    required String errorName,
    required String message,
    required String details,
  })  : _type = type,
        _code = code,
        _errorName = errorName,
        _message = message,
        _details = details;

  final ErrorType _type;
  final int _code;
  final String _errorName;
  final String _message;
  final String _details;

  String get showError =>
      '${_type.icon} ${_type.text} | $_code | $_errorName : $_message ';
  String get showErrorDebug =>
      '${_type.icon} ${_type.text} | Error Code: $_code | Error Name: $_errorName | Message: $_message | Details: $_details';
  String get errorCode => '${_type.text}_${_code}_${_errorName}_$_details';
}
