part of '../../page/receipt_gallery.dart';
@immutable
final class ReceiptGalleryPageState {
  const ReceiptGalleryPageState(
      {this.errorMessage = '',
      this.isLoading = false,
      this.filteredReceipts = const []});

  final String errorMessage;
  final bool isLoading;
  final List<ReceiptSummary> filteredReceipts;

  ReceiptGalleryPageState copyWith(
      {String? errorMessage,
      bool? isLoading,
      List<ReceiptSummary>? filteredReceipts}) {
    return ReceiptGalleryPageState(
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
      filteredReceipts: filteredReceipts ?? this.filteredReceipts,
    );
  }
}
