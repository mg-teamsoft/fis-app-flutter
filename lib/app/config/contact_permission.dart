enum ContactPermission {
  viewReceipts('VIEW_RECEIPTS'),
  downloadFiles('DOWNLOAD_FILES');

  const ContactPermission(this.apiValue);

  final String apiValue;
}
