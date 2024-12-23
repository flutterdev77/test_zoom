import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:zoom_example/method_channel_helper.dart';

class ZoomExample extends StatefulWidget {
  const ZoomExample({super.key});

  @override
  State<ZoomExample> createState() => _ZoomExampleState();
}

class _ZoomExampleState extends State<ZoomExample> {
  final TransformationController _controller = TransformationController();
  var height = 0.0;
  var width = 0.0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Offset getTranslationFromMatrix() {
    final matrix = _controller.value;
    // Translation is stored in the last row (indices 12 and 13 for x, y respectively)
    return Offset(matrix.storage[12], matrix.storage[13]);
  }

  Future<void> applyTransformation() async {
    try {
      final data = await rootBundle.load(
        'assets/fashion_02_background2.jpg',
      );
      final List<int> bytes = data.buffer.asUint8List();
      final tempPath = await getTemporaryDirectory();
      final tempFilename = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final tempFile = File('${tempPath.path}/$tempFilename');

      await tempFile.writeAsBytes(bytes);

      final scale = _controller.value.getMaxScaleOnAxis();
      final translation = getTranslationFromMatrix();
      await MethodChannelHelper().testTransform(
        height: height,
        width: width,
        scale: scale,
        dx: translation.dx,
        dy: translation.dy,
        imagePath: tempFile.path,
      );
    } catch (error, _) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: applyTransformation,
        label: const Text('Save To IOS View'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                ),
              ),
              width: MediaQuery.of(context).size.width,
              child: ClipRRect(
                child: LayoutBuilder(
                  builder: (context, constrains) {
                    width = MediaQuery.of(context).size.width;
                    height = MediaQuery.of(context).size.width * 1920 / 1080;
                    return Stack(
                      children: [
                        InteractiveViewer(
                          transformationController: _controller,
                          minScale: 0.1,
                          maxScale: 10.0,
                          child: SizedBox(
                            width: width,
                            height: height,
                            child: Image.asset(
                              'assets/fashion_02_background2.jpg',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
