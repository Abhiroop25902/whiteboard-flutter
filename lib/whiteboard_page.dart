import 'package:flutter/material.dart';

class WhiteboardPage extends StatefulWidget {
  const WhiteboardPage({Key? key}) : super(key: key);

  @override
  State<WhiteboardPage> createState() => _WhiteboardPageState();
}

class _WhiteboardPageState extends State<WhiteboardPage> {
  Color _strokeColor = Colors.green;

  void updateStrokeColor(Color newStrokeColor) {
    setState(() {
      _strokeColor = newStrokeColor;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Whiteboard'),
        actions: [
          IconButton(
              onPressed: () => updateStrokeColor(Colors.red),
              icon: const Icon(
                Icons.circle,
                color: Colors.red,
              )),
        ],
      ),
      body: const WhiteBoard(),
    );
  }
}

class WhiteBoard extends StatefulWidget {
  const WhiteBoard({Key? key}) : super(key: key);

  @override
  State<WhiteBoard> createState() => _WhiteBoardState();
}

class _WhiteBoardState extends State<WhiteBoard> {
  void showInfo(double dx, double dy) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text('dx: $dx dy: $dy')));
  }

  late final Painter kanjiPainter;

  @override
  void initState() {
    super.initState();
    kanjiPainter = Painter(Colors.black);
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      //also has a listener
      painter: kanjiPainter,
      child: GestureDetector(
        onPanStart: (dragStartDetails) {
          kanjiPainter.startStroke(dragStartDetails.localPosition);
        },
        onPanUpdate: (dragUpdateDetails) {
          kanjiPainter.appendStroke(dragUpdateDetails.localPosition);
        },
        onPanEnd: (dragEndDetails) {
          kanjiPainter.endStroke();
        },
      ),
    );
  }
}

class Painter extends ChangeNotifier implements CustomPainter {
  Color strokeColor;
  final List<Stroke> _strokes = [];

  Painter(this.strokeColor);

  void startStroke(Offset position) {
    // print("startStroke");
    _strokes.add(Stroke(strokeColor: Colors.red, strokeWidth: 2.5));
    appendStroke(position);
  }

  void appendStroke(Offset position) {
    // print("appendStroke");
    _strokes.last.addPosition(position);
    notifyListeners();
  }

  void endStroke() {
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

    for (var stroke in _strokes) {
      stroke.drawPosition(canvas);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  @override
  bool? hitTest(Offset position) {
    return true;
  }

  @override
  SemanticsBuilderCallback? get semanticsBuilder => null;

  @override
  bool shouldRebuildSemantics(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class Stroke {
  final List<Offset> positions = [];
  final Color strokeColor;
  final double strokeWidth;

  Stroke({
    required this.strokeColor,
    required this.strokeWidth,
  });

  void addPosition(Offset position) => positions.add(position);

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
