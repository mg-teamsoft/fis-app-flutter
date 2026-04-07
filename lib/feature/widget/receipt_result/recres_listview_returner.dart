part of '../../page/receipt_result_page.dart';

class _ReceiptResultListViewReturner extends StatefulWidget {
  const _ReceiptResultListViewReturner({
    required this.i,
    required this.showControls,
    required this.isSelected,
    required this.wide,
    required this.state,
    required this.rotateImage,
    required this.removeItem,
    required this.item,
    required this.image,
    required this.editor,
  });

  final int i;
  final bool showControls;
  final bool isSelected;
  final bool wide;
  final _ItemState state;
  final void Function(_ItemState) rotateImage;
  final void Function(SelectedItem) removeItem;
  final SelectedItem item;
  final _ReceiptResultClipRect image;
  final _ReceiptResultEditorArea editor;

  @override
  State<_ReceiptResultListViewReturner> createState() =>
      __ReceiptResultListViewReturnerState();
}

class __ReceiptResultListViewReturnerState
    extends State<_ReceiptResultListViewReturner> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              if (widget.showControls) ...[
                Checkbox(
                  value: widget.isSelected,
                  onChanged: (v) {
                    setState(() {
                      widget.state.selected = v ?? false;
                    });
                  },
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  'Fiş ${widget.i + 1}',
                  style: context.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              IconButton(
                tooltip: 'Döndür',
                onPressed: () => widget.rotateImage(widget.state),
                icon: const Icon(Icons.rotate_right),
              ),
              if (widget.showControls)
                IconButton(
                  tooltip: 'Sil',
                  onPressed: () => widget.removeItem(widget.item),
                  icon: const Icon(Icons.delete_outline),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (widget.wide)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AspectRatio(aspectRatio: 3 / 4, child: widget.image),
                ),
                const SizedBox(width: 12),
                Expanded(child: widget.editor),
              ],
            )
          else
            Column(
              children: [
                AspectRatio(aspectRatio: 3 / 4, child: widget.image),
                const SizedBox(height: 12),
                widget.editor,
              ],
            ),
        ],
      ),
    );
  }
}
