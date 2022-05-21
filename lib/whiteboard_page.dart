import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// The Main Page (The Scaffold)
class WhiteboardPage extends StatelessWidget {
  const WhiteboardPage({Key? key}) : super(key: key);

  Widget _getConsumerColorIcon(Color iconColor) => Consumer<PaintConfig>(
        builder: (context, selectedComponents, child) => IconButton(
            onPressed: () => selectedComponents.changeColor(iconColor),
            icon: Icon(
              selectedComponents.strokeColor == iconColor
                  ? Icons.circle_outlined
                  : Icons.circle,
              color: iconColor,
            )),
      );

  @override
  Widget build(BuildContext context) {
    const whiteBoard = WhiteBoard();

    return ChangeNotifierProvider(
      create: (context) => PaintConfig(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Whiteboard'),
          actions: [
            _getConsumerColorIcon(Colors.red),
            _getConsumerColorIcon(Colors.green),
            _getConsumerColorIcon(Colors.blue),
            Consumer<PaintConfig>(
              builder: (context, selectedComponents, child) => Slider(
                  min: selectedComponents.minStroke,
                  max: selectedComponents.maxStroke,
                  value: selectedComponents.strokeWidth,
                  onChanged: (newStrokeWidth) =>
                      selectedComponents.changeStrokeWidth(newStrokeWidth)),
            ),
            IconButton(
                //TODO: better method needed, this resets the entire scaffold
                onPressed: () {
                  Navigator.popAndPushNamed(context, '/');
                },
                icon: const Icon(Icons.delete))
          ],
        ),
        body: whiteBoard,
      ),
    );
  }
}

/// The body of the WhiteBoardPage which contains the CustomPainter(uses Painter) and gestureDetector
class WhiteBoard extends StatefulWidget {
  const WhiteBoard({Key? key}) : super(key: key);

  @override
  State<WhiteBoard> createState() => _WhiteBoardState();
}

class _WhiteBoardState extends State<WhiteBoard> {
  /// the painter object which will draw on the CustomPainter
  late final Painter _painter;

  @override
  void initState() {
    super.initState();
    _painter = Painter();
  }

  @override
  Widget build(BuildContext context) {
    /// CustomPaint also has a Listener<CustomPainter>
    /// which allows CustomPainter to extend ChangeNotifier
    return CustomPaint(
      painter: _painter,
      child: Consumer<PaintConfig>(
        builder: (context, paintConfig, child) => GestureDetector(
          /// Pan gives us continuos feedback of where the users pointer is
          /// touching using dragDetail.localPosition, we use this to draw
          /// on that exact spot using the painter
          ///
          /// painter uses a List<Stroke> where a Stroke is the inputs from
          /// a single Pan. A Stroke will have same color and width.
          /// This color and width is taken from Consumer<PaintConfig>
          ///
          /// OnPanStart takes paintConfig to define a stroke with
          /// required config
          onPanStart: (dragStartDetails) {
            _painter.startStroke(dragStartDetails.localPosition, paintConfig);
          },

          /// OnPanUpdate will add the new location of tap to existing Stroke
          /// and hence does not need the paintConfig
          onPanUpdate: (dragUpdateDetails) {
            _painter.addToLastStroke(dragUpdateDetails.localPosition);
          },
        ),
      ),
    );
  }
}

/// The CustomPainter for the WhiteBoard
class Painter extends ChangeNotifier implements CustomPainter {
  /// List of Strokes to draw on the WhiteBoard
  final List<Stroke> _strokeList = [];

  // void clearPaint() {
  //   for (var stroke in _strokes) {
  //     stroke.clearStroke();
  //   }

  //   _strokes.clear();
  // }

  /// Adds a new stroke to end of _strokeList with the given paintConfig
  void startStroke(Offset position, PaintConfig paintConfig) {
    // print("startStroke");
    _strokeList.add(Stroke(
        strokeColor: paintConfig.strokeColor,
        strokeWidth: paintConfig.strokeWidth));
    addToLastStroke(position);
  }

  void addToLastStroke(Offset newPosition) {
    // The existing Stroke will already be present in the last of _strokeList,
    // we just add the newPosition to it
    _strokeList.last.addPosition(newPosition);
    notifyListeners();
  }

  @override
  void paint(Canvas canvas, Size size) {
    //Paint Background White
    canvas.drawRect(
        Offset.zero & size,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill);

    // Draw the Strokes in the canvas
    for (var stroke in _strokeList) {
      stroke.drawPosition(canvas);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // No changes if this return true or false xdd
    return true;
  }

  @override
  bool? hitTest(Offset position) {
    // No changes if this return true or false xdd
    return true;
  }

  // No changes observed if given a not null object
  @override
  SemanticsBuilderCallback? get semanticsBuilder => null;

  @override
  bool shouldRebuildSemantics(covariant CustomPainter oldDelegate) {
    // No changes if this return true or false xdd
    return true;
  }
}

/// Info of a single pan with given config
class Stroke {
  final List<Offset> positions = [];
  final Color strokeColor;
  final double strokeWidth;

  Stroke({
    required this.strokeColor,
    required this.strokeWidth,
  });

  // void clearStroke() {
  //   positions.clear();
  // }

  void addPosition(Offset position) => positions.add(position);

  /// draws the stroke positions into the canvas
  void drawPosition(Canvas canvas) {
    var strokePaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    Path strokePath = Path();
    strokePath.addPolygon(positions, false);
    canvas.drawPath(strokePath, strokePaint);
  }
}

/// Paint Configuration which is accessed by the Painter and can be changes via actions in the Scaffold
class PaintConfig extends ChangeNotifier {
  Color strokeColor = Colors.red;
  double strokeWidth = 2.5;
  final double minStroke = 1;
  final double maxStroke = 7;

  void changeColor(Color newColor) {
    if (newColor != strokeColor) {
      strokeColor = newColor;
      notifyListeners();
    }
  }

  void changeStrokeWidth(double newStrokeWidth) {
    if (strokeWidth != newStrokeWidth) {
      strokeWidth = newStrokeWidth;
      notifyListeners();
    }
  }
}


// extra TODO: an option for user selecting RGBA by their own for stroke color