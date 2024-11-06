import 'package:flutter/material.dart';

class StickerPicker extends StatefulWidget {
  final Function(String, bool) onStickerSelected;
  final String _baseUrl = 'https://polydiff.s3.ca-central-1.amazonaws.com';
  static const int _nbDefaultStickersGifs = 10;

  const StickerPicker({super.key, required this.onStickerSelected});

  @override
  State<StickerPicker> createState() => _StickerPickerState();
}

class _StickerPickerState extends State<StickerPicker> {
  late List<String> stickers = [];
  late List<String> gifs = [];

  @override
  void initState() {
    super.initState();
    setStickerGifsUrls();
  }

  setStickerGifsUrls() {
    for (int i = 1; i <= StickerPicker._nbDefaultStickersGifs; i++) {
      stickers.add('${widget._baseUrl}/stickers/image$i.png');
      gifs.add('${widget._baseUrl}/gifs/image$i.gif');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const TabBar(
            tabs: [
              Tab(text: 'Stickers'),
              Tab(text: 'GIFs'),
            ],
          ),
          SizedBox(
            height: 200,
            child: TabBarView(
              children: [
                _buildStickerGrid(stickers, true),
                _buildStickerGrid(gifs, false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickerGrid(List<String> items, bool isSticker) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => widget.onStickerSelected(items[index], isSticker),
          child: Image.network(items[index]),
        );
      },
    );
  }
}
