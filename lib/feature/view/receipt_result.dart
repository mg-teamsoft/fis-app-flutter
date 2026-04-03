part of '../page/receipt_result.dart';

class _ReceiptResultView extends StatefulWidget {
  const _ReceiptResultView({
    required this.errors,
    required this.rotateImage,
    required this.removeItem,
    required this.approveAll,
    required this.jobs,
    required this.excel,
    required this.submitting,
    required this.hasSuccessfulSubmission,
    required this.showOnlySelected,
    required this.bytesCache,
    required this.itemList,
    required this.state,
    required this.startTicker,
    required this.pollOne,
    required this.tick,
  });

  final JobService jobs;
  final ExcelService excel;
  final bool submitting;
  final bool? hasSuccessfulSubmission;
  final bool showOnlySelected;
  final Map<String, Future<Uint8List>> bytesCache;
  final List<SelectedItem> itemList;
  final Map<String, _ItemState> state;
  final void Function(_ItemState) rotateImage;
  final void Function(SelectedItem) removeItem;
  final Future<void> Function() approveAll;
  final List<String> Function(Map<String, dynamic>?) errors;
  final Future<dynamic> Function(_ItemState s) pollOne;
  final Future<dynamic> Function() startTicker;
  final Timer? tick;

  @override
  State<_ReceiptResultView> createState() => __ReceiptResultViewState();
}

class __ReceiptResultViewState extends State<_ReceiptResultView> {
  late List<SelectedItem> _items;

  @override
  void initState() {
    super.initState();
    _items = widget.itemList.where((it) {
      final jobId = it.jobId;
      if (jobId == null) return false;
      if (!widget.showOnlySelected) return true;
      final s = widget.state[jobId];
      return s?.selected ?? s?.receipt != null;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _ReceiptResultAppbar(showOnlySelected: widget.showOnlySelected),
      body: Padding(
        padding: const ThemePadding.all10(),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _items.length,
                itemBuilder: (_, i) {
                  final it = _items[i];
                  final jobId = it.jobId!;
                  final s = widget.state
                      .putIfAbsent(jobId, () => _ItemState(item: it));
                  final wide = MediaQuery.of(context).size.width > 700;
                  final isSelected = s.selected ?? (s.receipt != null);
                  final submitted = widget.hasSuccessfulSubmission == true;
                  final controller =
                      s.photoController ??= PhotoViewController();

                  final image = _ReceiptResultClipRect(
                    item: it,
                    bytesCache: widget.bytesCache,
                    photoController: controller,
                  );

                  final editor = _ReceiptResultEditorArea(
                    state: s,
                    submitted: submitted,
                    errors: widget.errors,
                  );
                  final showControls = !submitted;

                  return _ReceiptResultListViewReturner(
                    i: i,
                    showControls: showControls,
                    isSelected: isSelected,
                    wide: wide,
                    state: s,
                    rotateImage: widget.rotateImage,
                    removeItem: widget.removeItem,
                    item: it,
                    image: image,
                    editor: editor,
                  );
                },
              ),
            ),
            _ReceiptResultButtonArea(
              hasSuccessfulSubmission: widget.hasSuccessfulSubmission,
              submitting: widget.submitting,
              state: widget.state,
              approveAll: widget.approveAll,
            ),
          ],
        ),
      ),
    );
  }
}
