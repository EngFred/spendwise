sealed class AppResult<T> {
  const AppResult();
}

class Success<T> extends AppResult<T> {
  final T data;
  const Success(this.data);
}

class Failure<T> extends AppResult<T> {
  final String message;
  const Failure(this.message);
}
