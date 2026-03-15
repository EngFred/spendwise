sealed class AppResult<T> {
  const AppResult();

  /// Executes [onSuccess] or [onFailure] based on the result type.
  R when<R>({
    required R Function(T data) success,
    required R Function(String message) failure,
  }) {
    return switch (this) {
      Success<T>(data: final d) => success(d),
      Failure<T>(message: final m) => failure(m),
    };
  }

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T? get dataOrNull => switch (this) {
    Success<T>(data: final d) => d,
    Failure<T>() => null,
  };
}

class Success<T> extends AppResult<T> {
  final T data;
  const Success(this.data);
}

class Failure<T> extends AppResult<T> {
  final String message;
  const Failure(this.message);
}
